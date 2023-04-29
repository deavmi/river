module river.impls.fd;

import river.core;

/** 
 * Provides a base for streams based on a file descriptor
 */
public abstract class FDStream : Stream
{
    /** 
     * Underlying file descriptor
     */
    protected const int fd;

    /** 
     * Creates a new `FDStream` with the backing read/write file
     * descriptor being the one provided
     *
     * Params:
     *   fd = the read/write file descriptor
     */
    this(int fd)
    {
        this.fd = fd;
    }

    /**
     * Closes the file descriptor
     */
    public override void close()
    {
        version(Posix)
        {
            import core.sys.posix.unistd : close;

            // TODO: Do something with the error code of both calls to `close`
            close(fd);
        }
        else
        {
            pragma(msg, "FDStream: The close() call is not implemented for your platform");
            static assert(false);
        }
    }
}