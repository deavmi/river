module river.stream;

public interface Stream
{
    public void close();

    public ulong read(ref byte[] toArray);

    public ulong readFully(ref byte[] toArray);

    public ulong write(ref byte[] fromArray);

    public ulong writeFully(ref byte[] fromArray);

    public ulong getAvailableBytes();

    public bool hasAvailable();
}