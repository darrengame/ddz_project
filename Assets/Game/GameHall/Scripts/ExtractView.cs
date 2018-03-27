using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;
using System.IO;
using UnityEngine.UI;

public class ExtractView : MonoBehaviour {

	// Use this for initialization
	Text text_progress = null;
	Slider slider_progress = null;

	int ntotal_package = 0;
	int ncur_package = 0;

	void Start () {
		
	}

	void Awake()
	{
		slider_progress = transform.Find("sd_download").GetComponent<Slider> ();
		text_progress = slider_progress.transform.Find("Text_progress").GetComponent<Text> ();

//		StartExtract ();
		StartCoroutine (StartExtract());
//		text_progress.text = "50%";
	}

	IEnumerator ExtraUpk()
	{
		while(true)
		{
			Debug.Log (" coroutine extra upk ");
			yield return new WaitForSeconds (2.0f);
		}
	}

	IEnumerator StartExtract()
	{
		Debug.Log("--------- StartExtract ---------");
		string dataPath = Util.DataPath;  //数据目录
        string resPath = Util.AppContentPath(); //游戏包资源目录
        Debug.Log("--------- dataPath:" + dataPath);
        Debug.Log("--------- resPath:" + resPath);

        string[] files = Directory.GetFiles(resPath, "*.upk");
		yield return new WaitForEndOfFrame ();

        foreach (string file in files)
        {
			ntotal_package += 1;
            string name = Path.GetFileNameWithoutExtension(file);
            UnityEngine.Debug.Log("un upk file name:" + file+"/"+name);
			LuaHelper.GetPackgeManager().ExtraUPKAsync(file, dataPath + name, new CodeProgress(ShowProgress));

			yield return new WaitForEndOfFrame ();
        }
	}

	void ShowProgress(long all,long now)
    {
		float progress = (float)now /all;
		Debug.Log("当前进度为 progress: " + progress);

		float total_progress = progress / (float)ntotal_package + (float)ncur_package / ntotal_package;
		Debug.Log ("total_progress:" + total_progress);

		text_progress.text = Mathf.RoundToInt (100.0f*total_progress) + "%";
		slider_progress.value = total_progress;

		if(progress >= 1.0)
		{
			ncur_package += 1;
			Debug.Log ( "ShowProgress ncur_package:" + ncur_package + ", ntotal_package:" + ntotal_package);
			if(ncur_package == ntotal_package)
			{
				LuaHelper.GetGameManager ().OnResourceInited ();
			}
		}
    }

}
