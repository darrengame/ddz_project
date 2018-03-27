using UnityEngine;
using System.Collections.Generic;
using System.Reflection;
using LuaInterface;
using System;

namespace LuaFramework {
    public static class LuaHelper {

        /// <summary>
        /// getType
        /// </summary>
        /// <param name="classname"></param>
        /// <returns></returns>
        public static System.Type GetType(string classname) {
            Assembly assb = Assembly.GetExecutingAssembly();  //.GetExecutingAssembly();
            System.Type t = null;
            t = assb.GetType(classname); ;
            if (t == null) {
                t = assb.GetType(classname);
            }
            return t;
        }

        /// <summary>
        /// 面板管理器
        /// </summary>
        public static PanelManager GetPanelManager() {
            return AppFacade.Instance.GetManager<PanelManager>(ManagerName.Panel);
        }

        /// <summary>
        /// 资源管理器
        /// </summary>
        public static ResourceManager GetResManager() {
            return AppFacade.Instance.GetManager<ResourceManager>(ManagerName.Resource);
        }

        /// <summary>
        /// 网络管理器
        /// </summary>
        public static NetworkManager GetNetManager() {
            return AppFacade.Instance.GetManager<NetworkManager>(ManagerName.Network);
        }

        /// <summary>
        /// 音乐管理器
        /// </summary>
        public static SoundManager GetSoundManager() {
            return AppFacade.Instance.GetManager<SoundManager>(ManagerName.Sound);
        }
        /// <summary>
        /// 游戏管理器
        /// </summary>
        /// <returns></returns>
        public static GameManager GetGameManager()
        {
            return AppFacade.Instance.GetManager<GameManager>(ManagerName.Game);
        }
        /// <summary>
        /// 时间管理器
        /// </summary>
        /// <returns></returns>
        public static TimerManager GetTimerManager()
        {
            return AppFacade.Instance.GetManager<TimerManager>(ManagerName.Timer);
        }

        /// <summary>
        /// 对象池管理器
        /// </summary>
        /// <returns></returns>
        public static ObjectPoolManager GetObjectPoolManager()
        {
            return AppFacade.Instance.GetManager<ObjectPoolManager>(ManagerName.ObjectPool);
        }

        /// <summary>
        /// 更新管理器
        /// </summary>
        /// <returns></returns>
        public static UpdateManager GetUpdateManager()
        {
            return AppFacade.Instance.GetManager<UpdateManager>(ManagerName.Update);
        }

		/// <summary>
		/// 线程管理器
		/// </summary>
		/// <returns></returns>
		public static ThreadManager GetThreadManager()
		{
			return AppFacade.Instance.GetManager<ThreadManager>(ManagerName.Thread);
		}

		/// <summary>
		/// 触摸管理器
		/// </summary>
		/// <returns></returns>
		public static TouchManager GetTouchManager()
		{
			return AppFacade.Instance.GetManager<TouchManager>(ManagerName.Touch);
		}

		/// <summary>
		/// 压缩管理器
		/// </summary>
		/// <returns></returns>
		public static PackageUPKManager GetPackgeManager()
		{
			return AppFacade.Instance.GetManager<PackageUPKManager>(ManagerName.Packager);
		}

        /// <summary>
        /// pbc/pblua函数回调
        /// </summary>
        /// <param name="func"></param>
        public static void OnCallLuaFunc(LuaByteBuffer data, LuaFunction func) {
            if (func != null) func.Call(data);
            Debug.LogWarning("OnCallLuaFunc length:>>" + data.buffer.Length);
        }

        /// <summary>
        /// cjson函数回调
        /// </summary>
        /// <param name="data"></param>
        /// <param name="func"></param>
        public static void OnJsonCallFunc(string data, LuaFunction func) {
            Debug.LogWarning("OnJsonCallback data:>>" + data + " lenght:>>" + data.Length);
            if (func != null) func.Call(data);
        }
    }
}