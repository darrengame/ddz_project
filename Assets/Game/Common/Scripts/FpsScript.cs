using UnityEngine;
using System.Collections;

public class FpsScript : MonoBehaviour
{
	public float f_updataInterval = 0.5f; // 在每个updateInterval间隔处计算，帧/秒
	private float f_lastInterval; // last interval end time 最后间隔结束时间
	private int i_frames = 0; // frames over current interval 超过当前间隔帧
	private float f_fps;	// 当前fps

	void Start()
	{
		f_lastInterval = Time.realtimeSinceStartup;	// 游戏开始实时时间
		i_frames = 0;
	}

	void OnGUI()
	{
		GUI.Label(new Rect(Screen.width/2,0,100,100),"FPS: " + f_fps);  
	}

	void Update()
	{
		++i_frames;
		if(Time.realtimeSinceStartup > f_lastInterval + f_updataInterval)
		{
			f_fps = i_frames/(Time.realtimeSinceStartup - f_lastInterval);
			i_frames = 0;
			f_lastInterval = Time.realtimeSinceStartup;
		}
	}
}