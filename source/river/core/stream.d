module river.core.stream;

/** 
 * Defines a stream which can be read fro
 * and written to
 */
public interface Stream
{
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

    /** 
     * Writes bytes to the stream from the provided array
     * and returns without any further waiting, at most the
     * number of bytes written will be the length of the provided
     * array, at minimum a single byte
     *
     * Params:
     *   fromArray = the buffer to write from
     * Returns: the number of bytes written
     */
    public ulong write(ref byte[] fromArray);

    /** 
     * Writes bytes to the stream from the provided array
     * until the array has been fully written
     *
     * Params:
     *   fromArray = the buffer to write from
     * Returns: the number of bytes written
     */
    public ulong writeFully(ref byte[] fromArray);

    /** 
     * Closes the stream
     */
    public void close();
}