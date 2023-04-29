/** 
 * `File`-based stream
 */
module river.impls.file;

import river.impls.fd : FDStream;
import std.stdio : File;

/**
 * `File`-backed stream
 */
public class FileStream : FDStream
{
    /** 
     * Constructs a new file stream on the provided file
     *
     * Params:
     *   file = the `File` to use
     */
    this(File file)
    {
        super(file.fileno());
    }
}

unittest
{
    // TODO: Open a file here
}