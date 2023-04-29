module river.impls.pipe;

import river.core;

import std.stdio : File;
import std.exception : ErrnoException;
import std.conv : to;

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
        version(Linux)
        {
            import core.sys.posix.unistd : pipe;

            /* Open the pipe */
            int[] pipeFd;

            // Successful pipe creation
            if(pipe(pipeFd))
            {
                return new PipeStream(pipeFd[0], pipeFd[1]);
            }
            // Failure to create a pipe
            else
            {
                return null;
            }
            pragma(msg, "Naai");
        }
        // TODO: FIx, Idk why this below static else is running
        else
        {
            pragma(msg, "Cannot use newPipe() on platforms other than Linux");
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
        import core.sys.posix.unistd;

        try
        {
            return readEnd.rawRead(toArray).length;
        }
        catch(ErrnoException fileError)
        {
            throw new StreamException(StreamError.OPERATION_FAILED, "Errno: "~to!(string)(fileError.errno()));
        }
    }

    // TODO: Look into how we can accomplish full read,
    // ... may be good to call a helper function for this
    // ... seeing as this code can apply to a file-backed fd
    // ... as well
    public override ulong readFully(byte[] toArray)
    {
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
        return 0;
    }

    public override ulong writeFully(byte[] fromArray)
    {
        // TODO: Implement me
        return 0;
    }
}

unittest
{
    import std.stdio;
    import std.file;
    import std.process;
    // Pipe createdPipe = pipe();
    // int pipeRead = createdPipe.readEnd().fileno(), pipeWrite = createdPipe.readEnd().fileno();
    
    import core.stdc.stdio;

}