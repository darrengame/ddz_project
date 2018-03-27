using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Collections;
using System.Collections.Generic;
using LuaFramework;
using LuaInterface;
using System.Threading;

public enum DisType {
    Exception = 0,
    Disconnect = 1,
    Connect = 2,
    TimeOut = 3,
    Close = 4,
}

public class SocketData
{
	private LuaFunction m_func;
	public Queue<LuaByteBuffer> recv_data = new Queue<LuaByteBuffer>();
	public Queue<int> status_data = new Queue<int>();

	public LuaFunction luafunc
	{
		get{ 
			return m_func;
		}
	}
	public SocketData(LuaFunction func)
	{
		m_func = func;
	}
}

public class SocketClient {
    public static bool loggedIn = false;

    private TcpClient client = null;
    private NetworkStream outStream = null;
    private MemoryStream memStream;
    private BinaryReader reader;
	private SocketData m_socketdata;

    private const int MAX_READ = 8192;
    private byte[] byteBuffer = new byte[MAX_READ];

    // Use this for initialization
    public SocketClient() {
    }

	public SocketData SocketData
	{
		get
		{
			return m_socketdata;
		}
	}

    /// <summary>
    /// 注册代理
    /// </summary>
    public void OnRegister(LuaFunction func) {
		Debug.Log("SocketClient OnRegister" + func);
        memStream = new MemoryStream();
        reader = new BinaryReader(memStream);
		m_socketdata = new SocketData (func);
    }

    /// <summary>
    /// 移除代理
    /// </summary>
    public void OnRemove() {
        this.Close();
        reader.Close();
        memStream.Close();
    }

	/// <summary>
	/// 关闭链接
	/// </summary>
	public void Close() {
		if (client != null) {
			if (client.Connected) client.Close();
			client = null;
		}
		loggedIn = false;
	}

	/// <summary>
	/// 发送连接请求
	/// </summary>
	public void SendConnect(string addr, int port) {
		ConnectServer(addr, port);
	}

	/// <summary>
	/// 发送消息
	/// </summary>
	public void SendMessage(ByteBuffer buffer) {
		SessionSend(buffer.ToBytes());
		buffer.Close();
	}

	/// <summary>
	/// 发送消息
	/// </summary>
	public void SendMessage(string buffer) {
        byte[] bytebuffer = System.Text.Encoding.UTF8.GetBytes(buffer);
		SessionSend(bytebuffer);
	}

    /// <summary>
    /// 连接服务器
    /// </summary>
    void ConnectServer(string host, int port) {
		Debug.Log("SocketClient ConnectServer");
        client = null;
        client = new TcpClient();
        client.SendTimeout = 1000;
        client.ReceiveTimeout = 1000;
        client.NoDelay = true;
        try {
            Debug.Log("host:" + host + "port;" + port);
            client.BeginConnect(host, port, new AsyncCallback(OnConnect), null);
        } catch (Exception e) {
            Close(); 
			m_socketdata.status_data.Enqueue ((int)DisType.TimeOut);
            Debug.LogError(e.Message);
        }
    }

    /// <summary>
    /// 连接上服务器
    /// </summary>
    void OnConnect(IAsyncResult asr) {
        outStream = client.GetStream();
        client.GetStream().BeginRead(byteBuffer, 0, MAX_READ, new AsyncCallback(OnRead), null);
        // NetworkManager.AddEvent(Protocal.Connect, new ByteBuffer());
		Debug.Log("SocketClient OnConnect");
		m_socketdata.status_data.Enqueue ((int)DisType.Connect);
    }

    /// <summary>
    /// 写数据
    /// </summary>
    void WriteMessage(byte[] message) {
        MemoryStream ms = null;
        using (ms = new MemoryStream()) {
            ms.Position = 0;
            BinaryWriter writer = new BinaryWriter(ms);
            ushort msglen = (ushort)message.Length;
            //writer.Write((ushort)IPAddress.HostToNetworkOrder(msglen));
			writer.Write((byte)(msglen / 256));
			writer.Write((byte)(msglen % 256));

            writer.Write(message);
            writer.Flush();
            if (client != null && client.Connected) {
                //NetworkStream stream = client.GetStream(); 
                byte[] payload = ms.ToArray();
//				Debug.Log("WriteMessage ByteBuffer:" + payload.Length);
				this.PrintBytes(payload);
                outStream.BeginWrite(payload, 0, payload.Length, new AsyncCallback(OnWrite), null);
            } else {
                OnDisconnected(DisType.Exception, "WriteMessage msg failse");
                Debug.LogError("client.connected----->>false");
            }
        }
    }

    /// <summary>
    /// 读取消息
    /// </summary>
    void OnRead(IAsyncResult asr) {
        int bytesRead = 0;
        try {
            lock (client.GetStream()) {         //读取字节流到缓冲区
                bytesRead = client.GetStream().EndRead(asr);
            }
            if (bytesRead < 1) {                //包尺寸有问题，断线处理
                OnDisconnected(DisType.Disconnect, "bytesRead < 1");
                return;
            }

            OnReceive(byteBuffer, bytesRead);   //分析数据包内容，抛给逻辑层
            lock (client.GetStream()) {         //分析完，再次监听服务器发过来的新消息
                Array.Clear(byteBuffer, 0, byteBuffer.Length);   //清空数组
                client.GetStream().BeginRead(byteBuffer, 0, MAX_READ, new AsyncCallback(OnRead), null);
            }
        } catch (Exception ex) {
            OnDisconnected(DisType.Exception, ex.Message);
        }
    }

    /// <summary>
    /// 丢失链接
    /// </summary>
    void OnDisconnected(DisType dis, string msg) {
        Close();   //关掉客户端链接
        int protocal = dis == DisType.Exception ?
        Protocal.Exception : Protocal.Disconnect;

        ByteBuffer buffer = new ByteBuffer();
        buffer.WriteShort((ushort)protocal);
        // NetworkManager.AddEvent(protocal, buffer);
		m_socketdata.status_data.Enqueue ((int)dis);
        Debug.Log("Connection was closed by the server:>" + msg + " Distype:>" + dis);
    }

    /// <summary>
    /// 打印字节
    /// </summary>
    /// <param name="bytes"></param>
	void PrintBytes(byte[] bytes) {
        string returnStr = string.Empty;
		for (int i = 0; i < bytes.Length; i++) {
			returnStr += bytes[i].ToString("X2");
			returnStr += " ";
        }
		Debug.LogWarning(returnStr);
    }

    /// <summary>
    /// 向链接写入数据流
    /// </summary>
    void OnWrite(IAsyncResult r) {
        try {
            outStream.EndWrite(r);
        } catch (Exception ex) {
            OnDisconnected(DisType.Exception, "OnWrite msg failse");
            Debug.LogError("OnWrite--->>>" + ex.Message);
        }
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    void OnReceive(byte[] bytes, int length) {
        memStream.Seek(0, SeekOrigin.End);
        memStream.Write(bytes, 0, length);
        //Reset to beginning
        memStream.Seek(0, SeekOrigin.Begin);
//		Debug.Log ("RemainingBytes:" + RemainingBytes());
        while (RemainingBytes() > 2) {
            ushort messageLen = (ushort)(reader.ReadByte() * 10 + reader.ReadByte());//(ushort)IPAddress.NetworkToHostOrder(reader.ReadUInt16());

//			Debug.Log ("OnReceive:" + RemainingBytes() + ", messageLen:" + messageLen);
            if (RemainingBytes() >= messageLen) {
                MemoryStream ms = new MemoryStream();
                BinaryWriter writer = new BinaryWriter(ms);
				writer.Write(reader.ReadBytes(messageLen));
                ms.Seek(0, SeekOrigin.Begin);
                OnReceivedMessage(ms);
            } else {
                //Back up the position two bytes
                memStream.Position = memStream.Position - 2;
                break;
            }
        }
        //Create a new stream with any leftover bytes
        byte[] leftover = reader.ReadBytes((int)RemainingBytes());
        memStream.SetLength(0);     //Clear
        memStream.Write(leftover, 0, leftover.Length);
    }

    /// <summary>
    /// 剩余的字节
    /// </summary>
    private long RemainingBytes() {
        return memStream.Length - memStream.Position;
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    /// <param name="ms"></param>
    void OnReceivedMessage(MemoryStream ms) {
        BinaryReader r = new BinaryReader(ms);
        byte[] message = r.ReadBytes((int)(ms.Length - ms.Position));
		//Debug.Log("message msglen:" + message.Length);
		PrintBytes(message);

		LuaByteBuffer buffer = new LuaByteBuffer(message);
		
		m_socketdata.recv_data.Enqueue (buffer);
    }

    /// <summary>
    /// 会话发送
    /// </summary>
    void SessionSend(byte[] bytes) {
        WriteMessage(bytes);
    }
}
