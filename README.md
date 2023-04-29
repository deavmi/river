![](branding/logo.png)

River
=====

River provides a base interface describing a so-called _"stream"_ interface, this entails the following methods:

1. `read(byte[] buff)`
    * Reads into the provided buffer, `buff`, at most the number of bytes equal to the length of `buff` and at least 1 byte
    * On any error a `StreamException` is thrown
2. `readFully(byte[] buff)`
    * Similar to `read(byte[])` except it will block until the number of bytes read is exactly equal to the length of `buff`
    * On any error a `StreamException` is thrown