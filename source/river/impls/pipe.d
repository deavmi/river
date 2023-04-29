module river.impls.pipe;

import river.core;

import std.stdio : File;
import std.exception : ErrnoException;

public class Pipe : Stream
{
    /** 
     * Pipe endpoints
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
        this.readEnd.fdopen(readEnd);
        this.writeEnd.fdopen(writeEnd);
	}

    public override ulong read(ref byte[] toArray)
    {
        try
        {
            return readEnd.rawRead(toArray).length;
        }
        catch(ErrnoException fileError)
        {
            throw new StreamException(StreamError.OPERATION_FAILED);
        }
    }
}
