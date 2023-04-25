module river.core.exceptions;

public enum StreamError
{
    OPEN_FAIL,
    CLOSED,
    READ_REQUEST_TOO_BIG
}

public class StreamException : Exception
{
    private StreamError error;
    
    this(StreamError error)
    {
        super("TODO: Add this");
        this.error = error;
    }

    public StreamError getError()
    {
        return error;
    }
}