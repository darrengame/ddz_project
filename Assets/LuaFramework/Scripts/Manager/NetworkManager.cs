using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

namespace LuaFramework {
    public class NetworkManager : Manager {

		private Dictionary<String, SocketClient> m_sockets = new Dictionary<String, SocketClient>();

        void Awake() {
        }

        /// <summary>
        /// 
        /// </summary>
        void Update() {
			foreach(var socket in m_sockets)
			{
				SocketData m_socketdata = socket.Value.SocketData;
				if(m_socketdata != null && m_socketdata.recv_data.Count > 0)
				{
					//Debug.Log ("OnReceve recv count:" + m_socketdata.recv_data.Count);
					LuaByteBuffer data = m_socketdata.recv_data.Dequeue();
					LuaFunction func = m_socketdata.luafunc;
					if(func != null)
					{
						func.BeginPCall();
						func.Push("");
						func.Push(data);
						func.PCall();
						func.EndPCall();
					}
				}
				if(m_socketdata != null && m_socketdata.status_data.Count > 0)
				{
					Debug.Log ("OnReceve status count:" + m_socketdata.status_data.Count);
					int status = m_socketdata.status_data.Dequeue();
//					Debug.Log("status:"+status);
					LuaFunction func = m_socketdata.luafunc;
					if(func != null)
					{
						func.BeginPCall();
						func.Push(status);
						func.PCall();
						func.EndPCall();
					}
				}
			}
        }

        /// <summary>
        /// 创建socket连接
        /// </summary>
		public SocketClient CreateSocekt(String name) {
			if(m_sockets.ContainsKey(name))
			{
				this.OnRemove(name);
			}
			SocketClient socket = new SocketClient();
			m_sockets.Add (name, socket);
            return socket;
        }

		/// <summary>
		/// register callback
		/// </summary>
		public void OnRegister(String name, LuaFunction func) {
			if(m_sockets.ContainsKey(name))
			{
				m_sockets [name].OnRegister (func);
			}
		}
        /// <summary>
        /// 发送connect
		/// </summary>
        public void SendConnect(String name, string addr, int port) {
			if(m_sockets.ContainsKey(name))
			{
				m_sockets[name].SendConnect(addr, port);
			}
        }

        /// <summary>
        /// 发送SOCKET消息
        /// </summary>
        public void SendMessage(String name, ByteBuffer buffer) {
			if(m_sockets.ContainsKey(name))
			{
				m_sockets [name].SendMessage (buffer);
			}
		}

        /// <summary>
        /// close socket connect
        /// </summary>
		public void OnRemove(String name) {
			if(m_sockets.ContainsKey(name))
			{
				m_sockets [name].OnRemove ();
				m_sockets.Remove (name);
			}
        }
    }
}