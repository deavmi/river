module river.core.stream;

/** 
 * Defines a stream which can be read fro
 * and written to
 */
public interface Stream
{
    public void open();

    public void close();

    public ulong read(ref byte[] toArray);

    public ulong readFully(ref byte[] toArray);

    public ulong write(ref byte[] fromArray);

    public ulong writeFully(ref byte[] fromArray);

    public ulong getAvailableBytes();

    public bool hasAvailable();
}