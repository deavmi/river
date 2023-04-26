module river.core.stream;

/** 
 * Defines a stream which can be read fro
 * and written to
 */
public interface Stream
{
    /** 
     * Closes the stream
     */
    public void close();

    /** 
     * Reads bytes from the stream into the provided array
     * and returns without any further waiting, at most the
     * number of bytes read will be the length of the provided
     * array, at minimum a single byte
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read
     */
    public ulong read(ref byte[] toArray);

    /** 
     * Reads bytes from the stream into the provided array
     * until the array is fully-filled
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read
     */
    public ulong readFully(ref byte[] toArray);

    public ulong write(ref byte[] fromArray);

    public ulong writeFully(ref byte[] fromArray);

    // public ulong getAvailableBytes();

    // public bool hasAvailable();
}