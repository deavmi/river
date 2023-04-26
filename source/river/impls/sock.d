module river.impls.sock;

import river.core;

import std.socket;

public class SockStream : Stream
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
        // TODO: ENsure that this socket is open in stream mode
        this.socket = socket;
    }

    public override void open()
    {

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

    private void openCheck()
    {
        if(!socket.isAlive())
        {
            throw new StreamException(StreamError.CLOSED);
        }
    }

    public override ulong readFully(ref byte[] toArray)
    {
        // Ensure the stream is open
        openCheck();

        // TODO: recv can only read a certain number of max bytes, we should
        // ... decide what to do in such a case
        ptrdiff_t status = socket.receive(toArray, cast(SocketFlags)MSG_WAITALL);

        // TODO: Handle closed socket, set status and then throw exception
        if(status == 0)
        {

        }
        // TODO: Handle like above, but some custom error message, then throw exception
        else if(status < 0)
        {

        }
        // If the message was correctly received
        else
        {
            if(status == toArray.length)
            {

            }
            return status;
        }

        // TODO: If system does nto support MSG_FULLWAIT?

        // TODO: Ensure read count > 0 and count == toArray.length (full amount requested was read)


        return 0;
    }

    public override ulong read(ref byte[] toArray)
    {
        // Ensure the stream is open
        openCheck();

        // TODO: Implement me
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

    public override ulong writeFully(ref byte[] fromoArray)
    {
        // Ensure the stream is open
        openCheck();

        // TODO: Implement me
        return 0;
    }

    public override ulong write(ref byte[] fromArray)
    {
        // Ensure the stream is open
        openCheck();

        // TODO: Implement me
        return 0;
    }

   

    
}

version(unittest)
{
    import std.socket;
    import core.thread;
    import std.file;
    import std.stdio : writeln;
}

unittest
{
    import river.impls.sock;

    // FIXME: Make this randomnly generated
    string testDomainStr = "/tmp/testdomnain8.sock";
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
            
            Socket clientSocket = serverSocket.accept();

            ubyte[] data = [69,255,21];
            clientSocket.send(data);


            Thread.sleep(dur!("seconds")(2));
            // yield();
            data = [1,2,3,4,5,5,4,3,2,1];
            clientSocket.send(data);
            
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



    // server.close();

    
}
