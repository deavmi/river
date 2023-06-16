/** 
 * Socket stream
 */
module river.impls.sock;

import river.core;
import std.socket;

/** 
 * Provides a stream interface to a `Socket` which has 
 */
public class SockStream : Stream, Peakable
{
    /** 
     * Underlying socket
     */
    private Socket socket;

    /** 
     * Constructs a new `SockStream` from the provided socket
     *
     * Params:
     *   socket = the `Socket` to use as the underlying source/sink
     */
    this(Socket socket)
    {
        this.socket = socket;
    }

    /** 
     * Ensures that the socket is open, if not, then throws an
     * exception
     */
    private void openCheck()
    {
        if(!socket.isAlive())
        {
            throw new StreamException(StreamError.CLOSED);
        }
    }

    /** 
     * Reads bytes from the socket into the provided array
     * and returns without any further waiting, at most the
     * number of bytes read will be the length of the provided
     * array, at minimum a single byte
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read
     */
    public override ulong read(byte[] toArray)
    {
        // Ensure the stream is open
        openCheck();

        // Receive from the socket (at most `toArray.length`)
        ptrdiff_t status = socket.receive(toArray);

        // If the remote end closed the connection
        if(status == 0)
        {
            throw new StreamException(StreamError.CLOSED);
        }
        // TODO: Handle like above, but some custom error message, then throw exception
        else if(status < 0)
        {
            // TODO: We should examine the error
            throw new StreamException(StreamError.OPERATION_FAILED);
        }
        // If the message was correctly received
        else
        {
            return status;
        }
    }

    // TODO: We should not allow toArray.length == 0 below
    // ... confusing between our internal socket closing
    // ... and hence returning 0 or 0 bytes read
    // ... WHEN we request with 0 length (occuring because
    // ... of the toArray.length == 0)

    /** 
     * Reads bytes from the socket into the provided array
     * until the array is fully-filled
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read
     */
    public override ulong readFully(byte[] toArray)
    {
        // Ensure the stream is open
        openCheck();

        // Receive from the socket `toArray.length`
        ptrdiff_t status = socket.receive(toArray, cast(SocketFlags)MSG_WAITALL);

        // If the remote end closed the connection
        if(status == 0)
        {
            throw new StreamException(StreamError.CLOSED);
        }
        // TODO: Handle like above, but some custom error message, then throw exception
        else if(status < 0)
        {
            // TODO: We should examine the error
            throw new StreamException(StreamError.OPERATION_FAILED);
        }
        // If the message was correctly received
        else
        {
            return status;
        }
    }

    /** 
     * Writes bytes to the socket from the provided array
     * and returns without any further waiting, at most the
     * number of bytes written will be the length of the provided
     * array, at minimum a single byte.
     *
     * Be aware that is the kernsl's internal buffer is full
     * and if the `Socket` is in blocking mode that this wil
     * block until space is available to send at most some of
     * the bytes in `fromArray`.
     *
     * Params:
     *   fromArray = the buffer to write from
     * Returns: the number of bytes written
     */
    public override ulong write(byte[] fromArray)
    {
        // Ensure the stream is open
        openCheck();

        // Write to the socket (at most `fromArray.length`)
        ptrdiff_t status = socket.send(fromArray);

        // On an error
        if(status < 0)
        {
            // TODO: We should examine the error
            throw new StreamException(StreamError.OPERATION_FAILED);
        }
        // If the message was correctly sent
        else
        {
            return status;
        }
    }

    /** 
     * Writes bytes to the socket from the provided array
     * until the array has been fully written
     *
     * Params:
     *   fromArray = the buffer to write from
     * Returns: the number of bytes written
     */
    public override ulong writeFully(byte[] fromArray)
    {
        // Ensure the stream is open
        openCheck();

        /** 
         * Perform a write till the number of bytes requested is fulfilled,
         * we have to do it in this matter as it doesn't seem that MSG_WAITALL
         * will work as done in `socket.receive()`
         */
        long totalBytesRequested = fromArray.length;
        long totalBytesGot = 0;
        while(totalBytesGot < totalBytesRequested)
        {
            /* Write remaining bytes into correct offset */
            ptrdiff_t status = socket.send(fromArray[0+totalBytesGot..totalBytesRequested]);

            // On successful write
            if(status > 0)
            {
                totalBytesGot += status;
            }
            // On write error
            else if(status == 0)
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Could not write, status 0");
            }
            // On write error
            else
            {
                throw new StreamException(StreamError.OPERATION_FAILED, "Could not write, status <0");
            }
        }

        assert(totalBytesGot == totalBytesRequested);
        
        return totalBytesGot;
    }

    /** 
     * Closes the stream
     */
    public override void close()
    {
        /* Unblocks any current calls to receive/send and prevents and futher ones */
        socket.shutdown(SocketShutdown.BOTH);

        /* Closes the connection */
        socket.close();
    }

    /** 
     * Reads bytes from the stream into the provided array
     * and returns without any further waiting, at most the
     * number of bytes read will be the length of the provided
     * array, at minimum a single byte.
     *
     * The underlying buffer of the `Stream` will not have
     * said bytes removed from it however.
     *
     * Params:
     *   toArray = the buffer to read into
     * Returns: the number of bytes read 
     */
    public override ulong peak(byte[] toArray)
    {
        // Ensure the stream is open
        openCheck();

        // Receive from the socket `toArray.length`
        ptrdiff_t status = socket.receive(toArray, SocketFlags.PEEK);

        // If the remote end closed the connection
        if(status == 0)
        {
            throw new StreamException(StreamError.CLOSED);
        }
        // TODO: Handle like above, but some custom error message, then throw exception
        else if(status < 0)
        {
            // TODO: We should examine the error
            throw new StreamException(StreamError.OPERATION_FAILED);
        }
        // If the message was correctly received
        else
        {
            return status;
        }
    }

    // TODO: Comment
    public override ulong peakFully(byte[] toArray)
    {
        // Ensure the stream is open
        openCheck();

        // Receive from the socket `toArray.length`
        ptrdiff_t status = socket.receive(toArray, SocketFlags.PEEK | cast(SocketFlags)MSG_WAITALL);

        // If the remote end closed the connection
        if(status == 0)
        {
            throw new StreamException(StreamError.CLOSED);
        }
        // TODO: Handle like above, but some custom error message, then throw exception
        else if(status < 0)
        {
            // TODO: We should examine the error
            throw new StreamException(StreamError.OPERATION_FAILED);
        }
        // If the message was correctly received
        else
        {
            return status;
        }
    }
}

version(unittest)
{
    import core.thread;
    import std.file;
    import std.stdio : writeln;
    import river.impls.sock;
}

/**
 * Tests using `read(ref byte[])` and `readFully(ref byte[])`
 * on a `SockStream`
 */
unittest
{
    string testDomainStr = "/tmp/riverTestUNIXSock.sock";
    UnixAddress testDomain = new UnixAddress(testDomainStr);

    scope(exit)
    {
        // Remove the UNIX domain file, else we will get a problem
        // ... creating it next time we run
        remove(testDomainStr);
    }

    Socket server = new Socket(AddressFamily.UNIX, SocketType.STREAM);
    server.bind(testDomain);
    server.listen(0);
    
    class ServerThread : Thread
    {
        private Socket serverSocket;

        this(Socket serverSocket)
        {
            super(&run);
            this.serverSocket = serverSocket;
        }

        private void run()
        {
            /** 
             * Accept the socket and create a `SockStream`
             * from it to test out writing
             */   
            Socket clientSocket = serverSocket.accept();
            Stream clientStream = new SockStream(clientSocket);

            ubyte[] data = [69,255,21];
            clientStream.writeFully(cast(byte[])data);


            Thread.sleep(dur!("seconds")(2));
            // yield();
            data = [1,2,3,4,5,5,4,3,2,1];

            // We catch an exception here as sometimes the main
            // ... thread may reach the stream.close() which
            // ... causes the connection to close and 
            // ... -1 internally returned hence throwing
            // ... this error. This is fine as we are really
            // ... testing reads below. WriteFully is being
            // ... tested so much so as to just test if it works
            try
            {
                clientStream.writeFully(cast(byte[])data);
            }
            catch(StreamException e)
            {
                
            }
        }
    }

    Thread serverThread = new ServerThread(server);
    serverThread.start();

    Socket clientConnection = new Socket(AddressFamily.UNIX, SocketType.STREAM);
    clientConnection.connect(testDomain);

    Stream stream = new SockStream(clientConnection);

    // TODO: The below can technically be mixed-in

    byte[] receivedData;
    receivedData.length = 2;
    ulong cnt = stream.readFully(receivedData);
    assert(cnt == 2);
    assert(receivedData == [69,-1]);


    Thread.sleep(dur!("seconds")(2));
    byte[] receivedData2;
    receivedData2.length = 3;
    cnt = stream.read(receivedData2);
    writeln(cnt);
    writeln(receivedData2);
    assert(cnt >= 1 && cnt <= 3);
    assert(receivedData2 == [21, 0, 0] || receivedData2 == [21, 1, 0] || receivedData2 == [21, 1, 2]);

    // Finally close the stream
    stream.close();
}

/**
 * This tests the `Peekable` capability of `SockStream`
 */
unittest
{
    string testDomainStr = "/tmp/riverTestUNIXSock.sock";
    UnixAddress testDomain = new UnixAddress(testDomainStr);

    scope(exit)
    {
        // Remove the UNIX domain file, else we will get a problem
        // ... creating it next time we run
        remove(testDomainStr);
    }

    Socket server = new Socket(AddressFamily.UNIX, SocketType.STREAM);
    server.bind(testDomain);
    server.listen(0);
    
    class ServerThread : Thread
    {
        private Socket serverSocket;

        this(Socket serverSocket)
        {
            super(&run);
            this.serverSocket = serverSocket;
        }

        private void run()
        {
            /** 
             * Accept the socket and create a `SockStream`
             * from it to test out writing
             */   
            Socket clientSocket = serverSocket.accept();
            Stream clientStream = new SockStream(clientSocket);

           
            try
            {
                ubyte[] data = [65];
                clientStream.writeFully(cast(byte[])data);

                Thread.sleep(dur!("seconds")(2));

                data = [66, 66, 65];
                clientStream.writeFully(cast(byte[])data);
            }
            catch(StreamException e)
            {

            }
            
        }
    }

    Thread serverThread = new ServerThread(server);
    serverThread.start();

    Socket clientConnection = new Socket(AddressFamily.UNIX, SocketType.STREAM);
    clientConnection.connect(testDomain);

    Stream stream = new SockStream(clientConnection);

    byte[] receivedData;
    receivedData.length = 4;
    ulong cnt = (cast(Peakable)stream).peak(receivedData);
    writeln(cnt);
    writeln("peek (least): ", receivedData);

    // Give the server some time to send the [66, 66, 65]
    Thread.sleep(dur!("seconds")(3));

    /** 
     * By now we hope all the data we wanted has arrived
     * FULLY and let's do a few `peak()`s then
     */
    for(int i = 0; i < 2; i++)
    {
        byte[] receivedData2;
        receivedData2.length = 4;
        cnt = (cast(Peakable)stream).peak(receivedData2);
        writeln(cnt);
        writeln("peek (least,arrivedFully): ", receivedData2);
    }
    
    /** 
     * Now let's dequeue it all
     */
    byte[] receivedData3;
    receivedData3.length = 4;
    cnt = stream.readFully(receivedData3);
    writeln(cnt);
    writeln("read (fully): ", receivedData3);
}