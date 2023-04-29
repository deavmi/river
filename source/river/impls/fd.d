module river.impls.fd;

import river.core;

/** 
 * Provides a base for streams based on file descriptor
 * pairs (a read fd and a write fd; where they can be
 * the same fd)
 */
public abstract class FDStream : Stream
{
    /** 
     * Read/Write file descriptors
     */
    protected const int readEndFd, writeEndFd;

    /** 
     * Creates a new `FDStream` with the given read and write
     * file descriptors (they may be the same)
     *
     * Params:
     *   readEndFd = the file descriptor to read from
     *   writeEndFd = the file descriptor to write to
     */
    this(int readEndFd, int writeEndFd)
    {
        this.readEndFd = readEndFd;
        this.writeEndFd = writeEndFd;
    }

    /** 
     * Creates a new `FDStream` with the backing read/write file
     * descriptor being the one provided
     *
     * Params:
     *   fd = the read/write file descriptor
     */
    this(int fd)
    {
        this(fd, fd);
    }

    /**
     * Closes the file descriptors
     */
    public override void close()
    {
        version(Posix)
        {
            import core.sys.posix.unistd : close;

            // TODO: Do something with the error code of both calls to `close`
            if(readEndFd == writeEndFd)
            {
                close(readEndFd);
            }
            else
            {
                close(readEndFd);
                close(writeEndFd);
            } 
        }
        else
        {
            pragma(msg, "FDStream: The close() call is not implemented for your platform");
            static assert(false);
        }
    }
}