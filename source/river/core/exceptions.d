/** 
 * Error handling
 */
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

/** 
 * Used for any operations on streams whenever an error occurs
 */
public class StreamException : Exception
{
    /** 
     * The type of error
     */
    private StreamError error;
    
    /** 
     * Constructs a new `StreamException` of the given sub-error type
     * and allows an optional message to go along with it
     *
     * Params:
     *   error = the `StreamError` describing the kind of error
     */
    this(StreamError error, string msg = "")
    {
        string helperMessage = msg.length ? msg : "No further information available";
        super("StreamException("~to!(string)(error)~"): "~helperMessage);
        this.error = error;
    }

    /** 
     * Returns the type of error that occurred
     *
     * Returns: the error as a `StreamError`
     */
    public StreamError getError()
    {
        return error;
    }
}