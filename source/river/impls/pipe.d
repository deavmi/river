/** 
 * Pipe-based stream
 */
module river.impls.pipe;

import river.core;
import std.exception : ErrnoException;
import std.conv : to;
import river.impls.fd : FDStream;

/** 
 * Provides a stream interface to a UNIX pipe fd-pair
 */
public class PipeStream : Stream
{
    /** 
     * Underlying FDStreams for the read and write fds
     * making up the pipe
     */
    private FDStream readStream, writeStream;

    /** 
     * Constructs a new piped-stream with the file descriptors of the
     * read and write ends provided
     *
     * Params:
     *   readEnd = the fd of the pipe's read end
     *   writeEnd = the fd of the pipe's write end
     */
	this(int readEnd, int writeEnd)
	{
        this.readStream = new FDStream(readEnd);
        this.writeStream = new FDStream(writeEnd);
	}

    /** 
     * Creates a new anonymous pipe and attaches it to a newly created
     * `PipeStream`
     *
     * Returns: the created `PipeStream`, `null` on failure to create
     * the pipe
     */
    public static PipeStream newPipe()
    {
        version(Posix)
        {
            import core.sys.posix.unistd : pipe;

            /* Open the pipe */
            int[2] pipeFd;

            // Successful pipe creation
            if(pipe(pipeFd) == 0)
            {
                return new PipeStream(pipeFd[0], pipeFd[1]);
            }
            // Failure to create a pipe
            else
            {
                return null;
            }
        }
        else
        {
            pragma(msg, "PipeStream: Cannot construct pipes on this platform");
            static assert(false);
        }
    }

    /** 
     * Reads bytes from the pipe into the provided array
     * and returns without any further waiting, at most the
     * number of bytes read will be the length of the provided
     * array, at minimum a single byte
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read
     */
    public override ulong read(byte[] toArray)
    {
        return readStream.read(toArray);
    }

    /** 
     * Reads bytes from the pipe into the provided array
     * until the array is fully-filled
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read
     */
    public override ulong readFully(byte[] toArray)
    {
        return readStream.readFully(toArray);
    }

    public override ulong write(byte[] fromArray)
    {
        return writeStream.write(fromArray);
    }

    public override ulong writeFully(byte[] fromArray)
    {
        return writeStream.writeFully(fromArray);
    }

    /** 
     * Closes both pipe pairs
     */
    public override void close()
    {
        readStream.close();
        writeStream.close();
    }
}

version(unittest)
{
    import core.thread;
}

/**
 * Create a new `PipeStream` where one thread writes to it
 * and another thread (the main thread) reads from it.
 *
 * We have added in some pauses to add entropy to show
 * how it could go either way and how `read(byte[])`
 * and `readFully(byte[])` can be used in such situations
 */
unittest
{
    PipeStream myPipe = PipeStream.newPipe();
    assert(myPipe !is null);

    class WriterThread : Thread
    {
        private PipeStream myPipeStream;

        this(PipeStream myPipeStream)
        {
            this.myPipeStream = myPipeStream;
            super(&run);
        }

        private void run()
        {
            byte[] data = [0,69,55];
            myPipeStream.write(data);

            Thread.sleep(dur!("seconds")(2));

            data = [42, 80, 99];
            myPipeStream.write(data);

            Thread.sleep(dur!("seconds")(2));

            data = [100, 102];
            myPipeStream.write(data);
        }
    }

    Thread writerThread = new WriterThread(myPipe);
    writerThread.start();

    Thread.sleep(dur!("seconds")(2));

    byte[] myReceivedData;
    myReceivedData.length = 4;
    ulong cnt = myPipe.read(myReceivedData);
    assert(cnt == 3 || cnt == 4);
    assert(myReceivedData == [0, 69,55, 0] || myReceivedData == [0, 69,55, 42]);


    // By now either [42, 80, 99, 100, 102] or [80, 99, 100, 102]

    byte[] myReceivedData2;
    myReceivedData2.length = 4;
    cnt = myPipe.readFully(myReceivedData2);
    import std.stdio;
    writeln(cnt);
    assert(cnt == 4);
    import std.stdio;
    writeln(myReceivedData2);
    assert(myReceivedData2 == [42, 80, 99, 100] || myReceivedData2 == [80, 99, 100, 102]);

    // Close the stream
    myPipe.close();
}