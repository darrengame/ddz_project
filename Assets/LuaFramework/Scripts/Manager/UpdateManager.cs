using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using System.Reflection;
using System.IO;

namespace LuaFramework {
	public class UpdateManager : Manager
	{
		private List<string> download_files = new List<string>();
        private Dictionary<string, string> to_download_files = new Dictionary<string, string>();
        private readonly object m_lockObject = new object();
        private Queue<KeyValuePair<string, string>> mEvents = new Queue<KeyValuePair<string, string>>();

        public const string UPDATE_CHECK = "UpdateCheck";           //更新消息
        public const string UPDATE_EXTRACT = "UpdateExtract";           //更新解包
        public const string UPDATE_DOWNLOAD = "UpdateDownload";         //更新下载

		public void Awake()
		{	

		}
        /// <summary>
        /// 交给Command，这里不想关心发给谁。
        /// </summary>
        void Update() {
            if (mEvents.Count > 0) {
                while (mEvents.Count > 0) {
                    KeyValuePair<string, string> event_msg = mEvents.Dequeue();
                    facade.SendMessageCommand(NotiConst.DISPATCH_MESSAGE, event_msg);
                }
            }
        }

        public void AddEvent(string event_name, string data) {
            lock (m_lockObject) {
                mEvents.Enqueue(new KeyValuePair<string, string>(event_name, data));
            }
        }
		/// <summary>
        /// 检查释放资源
        /// </summary>
        public void CheckExtractResource() {
            bool isExists = Directory.Exists(Util.DataPath) &&
              				Directory.Exists(Util.DataPath + "lua/") && 
							File.Exists(Util.DataPath + "files.txt");
			
            if (isExists || AppConst.DebugMode) {
                StartCoroutine(OnCheckUpdate());
                return;   //文件已经解压过了，自己可添加检查文件列表逻辑
            }
            StartCoroutine(OnExtractResource());    //启动释放协成 
        }
        /// <summary>
        /// 释放资源
        /// </summary>
        IEnumerator OnExtractResource() {
            string dataPath = Util.DataPath;  //数据目录
            string resPath = Util.AppContentPath(); //游戏包资源目录

            if (Directory.Exists(dataPath)) Directory.Delete(dataPath, true);
            Directory.CreateDirectory(dataPath);

            string infile = resPath + "files.txt";
            string outfile = dataPath + "files.txt";
            if (File.Exists(outfile)) File.Delete(outfile);

            string message = "正在解包文件:>files.txt";
            Debug.Log(message);
            this.AddEvent(UPDATE_EXTRACT, "begin");

            if (Application.platform == RuntimePlatform.Android) {
                WWW www = new WWW(infile);
                yield return www;

                if (www.isDone) {
                    File.WriteAllBytes(outfile, www.bytes);
                }
                yield return 0;
            } else {
                File.Copy(infile, outfile, true);
            }
            yield return new WaitForEndOfFrame();

            //释放所有文件到数据目录
            string[] files = File.ReadAllLines(outfile);
            foreach (var file in files) {
                string[] fs = file.Split('|');
                infile = resPath + fs[0];  //
                outfile = dataPath + fs[0];

                message = "正在解包文件:>" + fs[0];
                Debug.Log("正在解包文件:>" + infile);

                string dir = Path.GetDirectoryName(outfile);
                if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

                message = "progressing|" + infile;
                this.AddEvent(UPDATE_EXTRACT, message);

                if (Application.platform == RuntimePlatform.Android) {
                    WWW www = new WWW(infile);
                    yield return www;

                    if (www.isDone) {
                        File.WriteAllBytes(outfile, www.bytes);
                    }
                    yield return 0;
                } else {
                    if (File.Exists(outfile)) {
                        File.Delete(outfile);
                    }
                    File.Copy(infile, outfile, true);
                }
                yield return new WaitForEndOfFrame();
            }
            message = "解包完成!!!";
            this.AddEvent(UPDATE_EXTRACT, "end");

            yield return new WaitForSeconds(0.1f);
            message = string.Empty;

            //释放完成，开始启动检查更新资源
            StartCoroutine(OnCheckUpdate());
        }

        /// <summary>
        /// 检测对比文件是否要更新
        /// </summary>
        IEnumerator OnCheckUpdate()
        {
            if (!AppConst.UpdateMode) {
                 //ResManager.initialize(Facade.m_GameManager.OnResourceInited);
                yield break;
            }
            to_download_files.Clear();

            this.AddEvent(UPDATE_CHECK, "begin");

            string dataPath = Util.DataPath;  //数据目录
            string url = AppConst.WebUrl;
            string random = DateTime.Now.ToString("yyyymmddhhmmss");
            string listUrl = url + "files.txt?v=" + random;
            Debug.LogWarning("LoadUpdate---->>>" + listUrl);

            WWW www = new WWW(listUrl); yield return www;
            if (www.error != null) {
                string message = "下载版本信息失败!>files.txt";
                this.AddEvent(UPDATE_CHECK, "error|"+message);
                yield break;
            }
            if (!Directory.Exists(dataPath)) {
                Directory.CreateDirectory(dataPath);
            }
            File.WriteAllBytes(dataPath + "files.txt", www.bytes);

            string filesText = www.text;
            string[] files = filesText.Split('\n');

            for (int i = 0; i < files.Length; i++) {
                if (string.IsNullOrEmpty(files[i])) continue;
                string[] keyValue = files[i].Split('|');
                string f = keyValue[0];
                string localfile = (dataPath + f).Trim();
                string path = Path.GetDirectoryName(localfile);
                if (!Directory.Exists(path)) {
                    Directory.CreateDirectory(path);
                }
                string fileUrl = url + keyValue[0] + "?v=" + random;
                bool canUpdate = !File.Exists(localfile);
                if (!canUpdate) {
                    string remoteMd5 = keyValue[1].Trim();
                    string localMd5 = Util.md5file(localfile);
                    canUpdate = !remoteMd5.Equals(localMd5);
                    if (canUpdate) File.Delete(localfile);
                }
                //本地缺少文件
                if (canUpdate) 
                {
                    to_download_files[fileUrl] = localfile;
                }
            }
            yield return new WaitForEndOfFrame();
            // "检查更新完成!!"
            this.AddEvent(UPDATE_CHECK, "end|" + to_download_files.Count);
            // 对比完成 是否去下载
            if(to_download_files.Count > 0)
            {
                StartCoroutine(OnUpdateResource());
            }
        }

        /// <summary>
        /// 启动更新下载，启动线程下载更新
        /// </summary>
        IEnumerator OnUpdateResource() {
            download_files.Clear();

            this.AddEvent(UPDATE_DOWNLOAD, "begin");

            string message = string.Empty;
            foreach(KeyValuePair<string, string> kvp in to_download_files)
            {
                Debug.Log(kvp.Key);
                message = "progressing|" + kvp.Key;
                this.AddEvent(UPDATE_DOWNLOAD, message);

                //这里都是资源文件，用线程下载
                BeginDownload(kvp.Key, kvp.Value);
                while (!(IsDownOK(kvp.Value))) 
                { 
                    yield return new WaitForEndOfFrame(); 
                }
            }
            yield return new WaitForEndOfFrame();
            this.AddEvent(UPDATE_DOWNLOAD, "end");
        }

        /// <summary>
        /// 是否下载完成
        /// </summary>
        bool IsDownOK(string file) {
            return download_files.Contains(file);
        }

        /// <summary>
        /// 线程下载
        /// </summary>
        void BeginDownload(string url, string file) {     //线程下载
            object[] param = new object[2] {url, file};

            ThreadEvent ev = new ThreadEvent();
            ev.Key = NotiConst.UPDATE_DOWNLOAD;
            ev.evParams.AddRange(param);
            ThreadManager.AddEvent(ev, OnThreadCompleted);   //线程下载
        }

        /// <summary>
        /// 线程完成
        /// </summary>
        /// <param name="data"></param>
        void OnThreadCompleted(NotiData data) {
            switch (data.evName) {
                case NotiConst.UPDATE_EXTRACT:  //解压一个完成
                    //
                break;
                case NotiConst.UPDATE_DOWNLOAD: //下载一个完成
                    download_files.Add(data.evParam.ToString());
                break;
            }
        }
	}
}