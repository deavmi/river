/** 
 * FD-based stream
 */
module river.impls.fd;

import river.core;

/** 
 * Provides a base for streams based on a file descriptor
 */
public class FDStream : Stream
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
     * Reads bytes from the file descriptor into the provided array
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
        version(Posix)
        {
            import core.sys.posix.unistd : read, ssize_t;

            ssize_t status = read(fd, toArray.ptr, toArray.length);

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
            pragma(msg, "FDStream: The read() call is not implemented for your platform");
            static assert(false);
        }
    }

    /** 
     * Reads bytes from the file descriptor into the provided array
     * until the array is fully-filled
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read
     */
    public override ulong readFully(byte[] toArray)
    {
        version(Posix)
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
                ssize_t status = read(fd, toArray.ptr+totalBytesGot, totalBytesRequested-totalBytesGot);

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

            assert(totalBytesGot == totalBytesRequested);
            return totalBytesGot;
        }
        else
        {
            pragma(msg, "FDStream: The readFully() call is not implemented for your platform");
            static assert(false);
        }
    }

    public override ulong write(byte[] fromArray)
    {
        version(Posix)
        {
            import core.sys.posix.unistd : write, ssize_t;

            ssize_t status = write(fd, fromArray.ptr, fromArray.length);

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
        else
        {
            pragma(msg, "FDStream: The write() call is not implemented for your platform");
            static assert(false);
        }
    }

    public override ulong writeFully(byte[] fromArray)
    {
        // TODO: Add a unit test for this, we should do it in something that
        // ... has a fixed internal buffer
        // TODO: Implement me, use the code that readFully uses but for writing
        version(Posix)
        {
            import core.sys.posix.unistd : write, ssize_t;

            /** 
            * Perform a write till the number of bytes requested is fulfilled
            */
            long totalBytesRequested = fromArray.length;
            long totalBytesGot = 0;
            while(totalBytesGot < totalBytesRequested)
            {
                /* Write remaining bytes into correct offset */
                ssize_t status = write(fd, fromArray.ptr+totalBytesGot, totalBytesRequested-totalBytesGot);

                if(status > 0)
                {
                    totalBytesGot += status;
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

            assert(totalBytesGot == totalBytesRequested);
            return totalBytesGot;
        }
        else
        {
            pragma(msg, "FDStream: The writeFully() call is not implemented for your platform");
            static assert(false);
        }
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