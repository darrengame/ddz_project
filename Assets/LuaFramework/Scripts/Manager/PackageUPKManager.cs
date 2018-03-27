using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using UnityEngine;
using SevenZip;

namespace LuaFramework {

	public class OneFileInfor
	{
		public int m_id=0;
		public int m_StartPos=0;
		public int m_Size=0;
		public int m_PathLength = 0;
		public string m_Path="";
		public byte[] m_data = null;
	};

	public class CodeProgress:ICodeProgress
	{
		public delegate void ProgressDelegate(Int64 fileSize,Int64 processSize);
		
		public ProgressDelegate m_ProgressDelegate=null;
		
		public CodeProgress(ProgressDelegate del)
		{
			m_ProgressDelegate=del;
		}
		
		public void SetProgress(Int64 inSize, Int64 outSize)
		{
			
		}
		
		public void SetProgressPercent(Int64 fileSize,Int64 processSize)
		{
			m_ProgressDelegate(fileSize,processSize);
		}
	}

	public class PackageUPKManager:Manager
	{
		int m_id=0;
		int m_totalSize = 0;
		string m_outputpath = "";
		string m_upkfilepath = "";
		
		Dictionary<int,OneFileInfor> m_allFileInfoDic = new Dictionary<int,OneFileInfor>();	

		CodeProgress m_progress = null;

		/** 遍历文件夹获取所有文件信息 **/
		void TraverseFolder(string folderpath)
		{
	        DirectoryInfo tmpDirectoryInfo = new DirectoryInfo(folderpath);
	        folderpath = tmpDirectoryInfo.FullName.Replace("\\","/");
	        folderpath = folderpath + "/";

	        Debug.Log("遍历文件夹 " + folderpath);

			string sourceDirpath=folderpath.Substring(0,folderpath.LastIndexOf('/'));
			
			/** 读取文件夹下面所有文件的信息 **/
			DirectoryInfo dirInfo = new DirectoryInfo(folderpath);
			
			foreach (FileInfo fileinfo in dirInfo.GetFiles("*.*",SearchOption.AllDirectories))
			{
				if (fileinfo.Extension == ".meta")
				{
					continue;
				}

				string filename = fileinfo.FullName.Replace("\\","/");
				filename = filename.Replace(sourceDirpath+"/","");

				int filesize = (int)fileinfo.Length;
				
				Debug.Log(m_id + " : " + filename + " 文件大小: " + filesize);
				
				OneFileInfor info = new OneFileInfor();
				info.m_id = m_id;
				info.m_Size = filesize;
				info.m_Path = filename;
				info.m_PathLength = new UTF8Encoding().GetBytes(filename).Length;
				
				/**  读取这个文件  **/
				FileStream fileStreamRead = new FileStream(fileinfo.FullName, FileMode.Open, FileAccess.Read);
				if (fileStreamRead == null)
				{
					Debug.Log("读取文件失败 ： "+fileinfo.FullName);
					return;
				}
				else
				{
					byte[] filedata = new byte[filesize];
					fileStreamRead.Read(filedata, 0, filesize);
					info.m_data = filedata;
				}
				fileStreamRead.Close();
				
				
				m_allFileInfoDic.Add(m_id,info);
				
				m_id++;
				m_totalSize += filesize;
			}
		}
		
		/**  打包一个文件夹  **/
		public void OnPackFolder(string folderpath,string upkfilepath, CodeProgress progress)
		{
			m_allFileInfoDic.Clear ();
			TraverseFolder(folderpath);
			
			Debug.Log("文件数量 : " + m_id);
			Debug.Log("文件总大小 : " + m_totalSize);
			
			/**  更新文件在UPK中的起始点  **/
			int firstfilestartpos = 0+4;
			for (int index = 0; index < m_allFileInfoDic.Count; index++)
			{
				firstfilestartpos += 4 + 4 + 4 + 4+m_allFileInfoDic[index].m_PathLength;
			}
			
			int startpos = 0;
			for (int index = 0; index < m_allFileInfoDic.Count; index++)
			{
				if (index == 0)
				{
					startpos = firstfilestartpos;
				}
				else
				{
					startpos = m_allFileInfoDic[index - 1].m_StartPos + m_allFileInfoDic[index - 1].m_Size;//上一个文件的开始+文件大小;
				}
				
				m_allFileInfoDic[index].m_StartPos = startpos;
			}
			
			/**  写文件  **/
			FileStream fileStream = new FileStream(upkfilepath,FileMode.Create);
			
			/**  文件总数量  **/
			byte[] totaliddata=System.BitConverter.GetBytes(m_id);
			fileStream.Write(totaliddata, 0, totaliddata.Length);
			
			for (int index = 0; index < m_allFileInfoDic.Count;index++ )
			{
				/** 写入ID **/
				byte[] iddata = System.BitConverter.GetBytes(m_allFileInfoDic[index].m_id);
				fileStream.Write(iddata, 0, iddata.Length);
				
				/**  写入StartPos  **/
				byte[] startposdata = System.BitConverter.GetBytes(m_allFileInfoDic[index].m_StartPos);
				fileStream.Write(startposdata, 0, startposdata.Length);
				
				/**  写入size  **/
				byte[] sizedata = System.BitConverter.GetBytes(m_allFileInfoDic[index].m_Size);
				fileStream.Write(sizedata, 0, sizedata.Length);
				
				/**  写入pathLength  **/
				byte[] pathLengthdata = System.BitConverter.GetBytes(m_allFileInfoDic[index].m_PathLength);
				fileStream.Write(pathLengthdata, 0, pathLengthdata.Length);
				
				/**  写入path  **/
				byte[] mypathdata = new UTF8Encoding().GetBytes(m_allFileInfoDic[index].m_Path);
				
				fileStream.Write(mypathdata, 0, mypathdata.Length);
			}
			
			/**  写入文件数据  **/
	//		for (int index = 0; index < m_allFileInfoDic.Count; index++)
	//		{
	//			fileStream.Write(m_allFileInfoDic[index].m_data, 0, m_allFileInfoDic[index].m_Size);
	//		}
			int totalprocessSize=0;
			foreach(var infopair in m_allFileInfoDic)
			{
				OneFileInfor info=infopair.Value;
				int size=info.m_Size;
				byte[] tmpdata=null;
				int processSize=0;
				while(processSize<size)
				{
					if(size-processSize<1024)
					{
						tmpdata=new byte[size-processSize];
					}
					else
					{
						tmpdata=new byte[1024];
					}
					fileStream.Write(info.m_data,processSize,tmpdata.Length);

					processSize+=tmpdata.Length;
					totalprocessSize+=tmpdata.Length;
					if(progress != null){
						progress.SetProgressPercent(m_totalSize,totalprocessSize);
					}
				}
			}
			
			fileStream.Flush();
			fileStream.Close();
			
			
			/** 重置数据 **/
			m_id = 0;
			m_totalSize = 0;
			m_allFileInfoDic.Clear();	
		}

		public void ExtraUPKAsync(string upkfilepath,string outputpath,CodeProgress progress)
		{
			m_upkfilepath = upkfilepath;
			m_outputpath = outputpath + "/";
			m_progress = progress;
//			ExtraUPK ();
			m_allFileInfoDic.Clear ();
			StartCoroutine (ExtraUPK());
		}

		IEnumerator ExtraUPK()
		{
	        int totalsize=0;
			Dictionary<int,OneFileInfor> dir_file_info = new Dictionary<int,OneFileInfor>();
			string output_path = m_outputpath;

			FileStream upkFilestream=new FileStream(m_upkfilepath, FileMode.Open, FileAccess.Read, FileShare.Read);
			upkFilestream.Seek(0,SeekOrigin.Begin);
			
			int offset=0;
			
			//读取文件数量;
			byte[] totaliddata=new byte[4];
			upkFilestream.Read(totaliddata,0,4);
			int filecount=BitConverter.ToInt32(totaliddata,0);
			offset+=4;
			Debug.Log("filecount="+filecount);
			
			//读取所有文件信息;
			for(int index=0;index<filecount;index++)
			{
				//读取id;
				byte[] iddata=new byte[4];
				upkFilestream.Seek(offset,SeekOrigin.Begin);
				upkFilestream.Read(iddata,0,4);
				int id=BitConverter.ToInt32(iddata,0);
				offset+=4;
				
				//读取StartPos;
				byte[] startposdata=new byte[4];
				upkFilestream.Seek(offset,SeekOrigin.Begin);
				upkFilestream.Read(startposdata,0,4);
				int startpos=BitConverter.ToInt32(startposdata,0);
				offset+=4;
				
				//读取size;
				byte[] sizedata=new byte[4];
				upkFilestream.Seek(offset,SeekOrigin.Begin);
				upkFilestream.Read(sizedata,0,4);
				int size=BitConverter.ToInt32(sizedata,0);
				offset+=4;
				
				//读取pathLength;
				byte[] pathLengthdata=new byte[4];
				upkFilestream.Seek(offset,SeekOrigin.Begin);
				upkFilestream.Read(pathLengthdata,0,4);
				int pathLength=BitConverter.ToInt32(pathLengthdata,0);
				offset+=4;
				
				//读取path;
				byte[] pathdata=new byte[pathLength];
				upkFilestream.Seek(offset,SeekOrigin.Begin);
				upkFilestream.Read(pathdata,0,pathLength);
				string path=new UTF8Encoding().GetString(pathdata);
				offset+=pathLength;
				
				
				//添加到Dic;
				OneFileInfor info=new OneFileInfor();
				info.m_id=id;
				info.m_Size=size;
				info.m_PathLength=pathLength;
				info.m_Path=path;
				info.m_StartPos=startpos;
				dir_file_info.Add(id,info);
				
				totalsize+=size;
				
				Debug.Log("id="+id+" startPos="+startpos+" size="+size+" pathLength="+pathLength+" path="+path);

//				yield return new WaitForEndOfFrame();
			}
			
			//释放文件;
			int totalprocesssize=0;
//			foreach(OneFileInfor infopair in m_allFileInfoDic.Values)
			for(int i=0; i < dir_file_info.Count; ++i)
			{
				OneFileInfor info = dir_file_info.ElementAt(i).Value;
				
				int startPos = info.m_StartPos;
				int size = info.m_Size;
				string path = info.m_Path;
				
				//创建文件;
				string dirpath = output_path;
				if(path.LastIndexOf('/') > 0){
					dirpath += path.Substring(0,path.LastIndexOf('/'));
				}
				string filepath=output_path + path;
				if(Directory.Exists(dirpath)==false)
				{
					Directory.CreateDirectory(dirpath);
				}
				if(File.Exists(filepath))
				{
					File.Delete(filepath);
				}
				
				FileStream fileStream = new FileStream(filepath, FileMode.Create);
				
				byte[] tmpfiledata;
				int processSize=0;

//				yield return new WaitForEndOfFrame();

				while(processSize<size)
				{
					if(size-processSize<1024)
					{
						tmpfiledata=new byte[size-processSize];
					}
					else
					{
						tmpfiledata=new byte[1024];
					}
					
					//读取;
					upkFilestream.Seek(startPos+processSize,SeekOrigin.Begin);
					upkFilestream.Read(tmpfiledata,0,tmpfiledata.Length);
					
					//写入;
					fileStream.Write(tmpfiledata,0,tmpfiledata.Length);
					
					processSize += tmpfiledata.Length;
					totalprocesssize += tmpfiledata.Length;

					if(m_progress != null){
						m_progress.SetProgressPercent((long)totalsize,(long)totalprocesssize);
					}
				}
				fileStream.Flush();
				fileStream.Close();
				yield return new WaitForEndOfFrame();
			}

			/** 重置数据 **/
			m_id = 0;
			m_totalSize = 0;
			m_allFileInfoDic.Clear();
			yield break;
		}
	}
}