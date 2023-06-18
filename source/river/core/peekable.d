/** 
 * Peek-supporting trait
 */
module river.core.peekable;

/** 
 * A stream which implements `Peakable` means that one
 * can do a read in a manner which copies the length of
 * data requested into a buffer but without removing it
 * from the `Stream`'s underlying buffer
 */
public interface Peekable
{
    /** 
     * Reads bytes from the stream into the provided array
     * and returns without any further waiting, at most the
     * number of bytes read will be the length of the provided
     * array, at minimum a single byte.
     *
     * The underlying buffer of the `Stream` will not have
     * said bytes removed from it however.
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read 
     */
    public ulong peek(byte[] toArray);

    /** 
     * Reads bytes from the stream into the provided array
     * until the array is fully-filled
     *
     * The underlying buffer of the `Stream` will not have
     * said bytes removed from it however.
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read
     */
    public ulong peekFully(byte[] toArray);
}