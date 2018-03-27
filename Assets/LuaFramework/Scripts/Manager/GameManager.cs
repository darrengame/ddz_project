using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using System.Reflection;
using System.IO;

namespace LuaFramework {
    public class GameManager : Manager {
        protected static bool initialize = false;

        /// <summary>
        /// 初始化游戏管理器
        /// </summary>
        void Awake() {
            Init();
        }

        /// <summary>
        /// 初始化
        /// </summary>
        void Init() {
            DontDestroyOnLoad(gameObject);  //防止销毁自己
            Screen.sleepTimeout = SleepTimeout.NeverSleep;
            Application.targetFrameRate = AppConst.GameFrameRate;
            
			// PlayerPrefs.SetInt("cur_version", 0);
            int cur_version = PlayerPrefs.GetInt("cur_version", 0);
            Debug.Log("cur_version:" + cur_version + ", Version:" + AppConst.Version);
            if (AppConst.Version <= cur_version || AppConst.DebugMode) 
            {
    			this.OnResourceInited ();
            }
            else {
				GameObject go = GameObject.FindWithTag("Extract");
				go.AddComponent<ExtractView>() ;
            }
        }

        /// <summary>
        /// 资源初始化结束
        /// </summary>
        public void OnResourceInited() {
#if ASYNC_MODE
            ResManager.Initialize(AppConst.AssetDir, delegate() {
                Debug.Log("Initialize OK!!!");
                this.OnInitialize();
            });
#else
            ResManager.Initialize();
            this.OnInitialize();
#endif
        }
        void OnInitialize() {

            LuaManager.InitStart();

            initialize = true;
			LuaHelper.GetPanelManager ().ClosePanel("Extract");

//            //类对象池测试
//            var classObjPool = ObjPoolManager.CreatePool<TestObjectClass>(OnPoolGetElement, OnPoolPushElement);
//            //方法1
//            //objPool.Release(new TestObjectClass("abcd", 100, 200f));
//            //var testObj1 = objPool.Get();
//
//            //方法2
//            ObjPoolManager.Release<TestObjectClass>(new TestObjectClass("abcd", 100, 200f));
//            var testObj1 = ObjPoolManager.Get<TestObjectClass>();
//
//            Debugger.Log("TestObjectClass--->>>" + testObj1.ToString());
//
//            //游戏对象池测试
//            var prefab = Resources.Load("TestGameObjectPrefab", typeof(GameObject)) as GameObject;
//            var gameObjPool = ObjPoolManager.CreatePool("TestGameObject", 5, 10, prefab);
//
//            var gameObj = Instantiate(prefab) as GameObject;
//            gameObj.name = "TestGameObject_01";
//            gameObj.transform.localScale = Vector3.one;
//            gameObj.transform.localPosition = Vector3.zero;
//
//            ObjPoolManager.Release("TestGameObject", gameObj);
//            var backObj = ObjPoolManager.Get("TestGameObject");
//            backObj.transform.SetParent(null);
//
//            Debug.Log("TestGameObject--->>>" + backObj);
         }

        /// <summary>
        /// 析构函数
        /// </summary>
        void OnDestroy() {
            
            Debug.Log("~GameManager was destroyed");
        }

    }
}