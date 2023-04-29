module river.impls.file;

import river.impls.fd : FDStream;
import std.stdio : File;

/**
 * `File`-backed stream
 */
public class FileStream : FDStream
{
    this(File file)
    {
        super(file.fileno());
    }
}