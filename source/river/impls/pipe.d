module river.impls.pipe;

import river.core;

import std.stdio : File;
import std.exception : ErrnoException;
import std.conv : to;
// import river.impls.linux;

public class PipeStream : Stream
{
    /** 
     * Pipe endpoints
     */
    private int readEndFd, writeEndFd;

    /** 
     * Pipe endpoints (attached to File)
     */
    private File readEnd, writeEnd;
    

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
       this.readEndFd = readEnd;
       this.writeEndFd = writeEnd;
	}

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
            pragma(msg, "Cannot use newPipe() on platforms other than Posix");
            // static assert(false);
            return null;
        }
    }

    public override void open()
    {
        try
        {
            this.readEnd.fdopen(readEndFd);
            this.writeEnd.fdopen(writeEndFd);
        }
        catch(ErrnoException fileError)
        {
            throw new StreamException(StreamError.OPEN_FAIL, "Errno: "~to!(string)(fileError.errno()));
        }
        
    }

    public override ulong read(byte[] toArray)
    {
        version(Posix)
        {
            import core.sys.posix.unistd : read, ssize_t;

            ssize_t status = read(readEndFd, toArray.ptr, toArray.length);

            if(status > 0)
            {
                return status;
            }
            else if(status == 0)
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Could not read, status 0");
            }
            else
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Could not read, status <0");
            }
        }
        else
        {
            try
            {
                return readEnd.rawRead(toArray).length;
            }
            catch(ErrnoException fileError)
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Errno: "~to!(string)(fileError.errno()));
            }
        }
    }

    // TODO: Look into how we can accomplish full read,
    // ... may be good to call a helper function for this
    // ... seeing as this code can apply to a file-backed fd
    // ... as well
    // ...
    // We may be able to use `select` to do the job, that
    // ... way sleeping correctly
    public override ulong readFully(byte[] toArray)
    {
        import core.sys.posix.unistd : read, ssize_t;

        /** 
         * Perform a read till the number of bytes requested is fulfilled
         */
        long totalBytesRequested = toArray.length;
        long totalBytesGot = 0;
        while(totalBytesGot < totalBytesRequested)
        {
            /* Read remaining bytes into correct offset */
            ssize_t status = read(readEndFd, toArray.ptr+totalBytesGot, totalBytesRequested-totalBytesGot);

            if(status > 0)
            {
                totalBytesGot += status;
            }
            else if(status == 0)
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Could not read, status 0");
            }
            else
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Could not read, status <0");
            }
        }

       


        // TODO: Implement me
        return 0;
    }

    public override void close()
    {
        // TODO: Implement me
    }

    public override ulong write(byte[] fromArray)
    {
        // TODO: Implement me

        version(Posix)
        {
            import core.sys.posix.unistd : write, ssize_t;

            ssize_t status = write(writeEndFd, fromArray.ptr, fromArray.length);

            if(status > 0)
            {
                return status;
            }
            else if(status == 0)
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Could not write, status 0");
            }
            else
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Could not write, status <0");
            }
        }

        // return 0;
    }

    public override ulong writeFully(byte[] fromArray)
    {
        // TODO: Implement me
        return 0;
    }
}

version(unittest)
{
    import core.thread;
}

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
        }
    }


    Thread writerThread = new WriterThread(myPipe);
    writerThread.start();



}