module river.core.result;

import river.core.exceptions : StreamError;

public struct Result
{
    public const bool good = true;
    public const StreamError error;
    public ulong byteCount = 0;
}