module river.core.exceptions;

import std.conv : to;

public enum StreamError
{
    CLOSED,
    READ_REQUEST_TOO_BIG,
    OPERATION_FAILED
}

public class StreamException : Exception
{
    private StreamError error;
    
    this(StreamError error, string msg = "")
    {
        string helperMessage = msg.length ? msg : "No further information available";
        super("StreamException("~to!(string)(error)~"): "~helperMessage);
        this.error = error;
    }

    public StreamError getError()
    {
        return error;
    }
}