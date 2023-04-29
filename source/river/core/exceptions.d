module river.core.exceptions;

import std.conv : to;

/** 
 * The type of error that occured
 */
public enum StreamError
{
    /** 
     * If an operation was attempted on a closed stream
     */
    CLOSED,

    /** 
     * FIXME: Not yet used
     */
    READ_REQUEST_TOO_BIG,

    /** 
     * On a failed operation, can be `read`, `write` etc.
     */
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