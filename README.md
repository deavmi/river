![](branding/logo.png)

River
=====

[![D](https://github.com/deavmi/river/actions/workflows/d.yml/badge.svg)](https://github.com/deavmi/river/actions/workflows/d.yml)

River provides a base interface describing a so-called _"stream"_ interface, this entails the following methods:

1. `read(byte[] buff)`
    * Reads into the provided buffer, `buff`, at most the number of bytes equal to the length of `buff` and at least 1 byte
    * On any error a `StreamException` is thrown
2. `readFully(byte[] buff)`
    * Similar to `read(byte[])` except it will block until the number of bytes read is exactly equal to the length of `buff`
    * On any error a `StreamException` is thrown
3. `write(byte[] buff)`
    * Writes from the provided buffer, `buff`, at most the number of bytes equal to the length of `buff` and at least 1 byte
    * On any error a `StreamException` is thrown
4. `writeFully(byte[] buff)`
    * Similar to `write(byte[])` except it will block until the number of bytes written is exactly equal to the length of `buff`
    * On any error a `StreamException` is thrown
5. `close()`
    * Closes the stream
    * On any error a `StreamException` is thrown

Checkout the [Streams API](https://river.dpldocs.info/river.core.html).

## Implementations

To go along with the streams API we also offer a few implementations of useful stream-types which you can use right away (or extend) within your application, these include:

1. [SockStream](https://river.dpldocs.info/river.impls.sock.SockStream.html)
    * Provides a streamable access to a `Socket`
    * Note, only works with `SocketType.STREAM`
2. [PipeStream](https://river.dpldocs.info/river.impls.pipe.PipeStream.html)
    * Prvodes a streamable access to a pipe pair of file descriptors
    * Note, only supports POSIX-like systems to far

... see [the rest](https://river.dpldocs.info/river.impls.html);