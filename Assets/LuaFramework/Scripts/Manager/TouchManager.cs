using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

namespace LuaFramework {
	public class TouchEvent
	{
		public String touchEvent;
	    public Vector2 uguiPoint;
		public TouchEvent(string _event,Vector2 _uguiPoint)
		{
			touchEvent = _event;
			uguiPoint = _uguiPoint;
	    }
	}

	public class TouchManager : Manager {

		// Use this for initialization
		private Dictionary<string, LuaFunction> touchEventCallBack = new Dictionary<string, LuaFunction>();
		private bool isTouchBegan = false;
	    private static Canvas _canvas;
	    public static Canvas canvas
	    {
	        get
	        {
	            if (_canvas == null)
	            {
	                _canvas = GameObject.Find("Canvas").GetComponent<Canvas>();
	            }
	            return _canvas;
	        }
	    }

	    void Start () {
			Input.simulateMouseWithTouches = true;
	    }
		
		void Update () {
	        if (Input.GetAxis("Fire1") != 0)
	        {
	            if (!isTouchBegan)
	            {
	                isTouchBegan = true;
	                foreach (var v in touchEventCallBack)
	                {
	                    LuaFunction func = v.Value;
	                    Vector2 localPosition;
	                    RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform, Input.mousePosition, canvas.worldCamera, out localPosition);
	                    func.BeginPCall();
	                    func.Push(new TouchEvent(TouchPhase.Began.ToString(), localPosition));
	                    func.PCall();
	                    func.EndPCall();
	                }
	            }

	            if (isTouchBegan && (Input.GetAxis("Mouse X") != 0 || Input.GetAxis("Mouse Y") != 0))
	            {
	                foreach (var v in touchEventCallBack)
	                {
	                    LuaFunction func = v.Value;
	                    Vector2 localPosition;
	                    RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform, Input.mousePosition, canvas.worldCamera, out localPosition);
	                    func.BeginPCall();
	                    func.Push(new TouchEvent(TouchPhase.Moved.ToString(), localPosition));
	                    func.PCall();
	                    func.EndPCall();
	                }
	            }
	        }
	        else
	        {
	            if (isTouchBegan)
	            {
	                isTouchBegan = false;
	                foreach (var v in touchEventCallBack)
	                {
	                    LuaFunction func = v.Value;
	                    Vector2 localPosition;
	                    RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform, Input.mousePosition, canvas.worldCamera, out localPosition);
	                    func.BeginPCall();
	                    func.Push(new TouchEvent(TouchPhase.Ended.ToString(), localPosition));
	                    func.PCall();
	                    func.EndPCall();
	                }
	            }
	        }

	        if (Input.touchCount == 0)
				return;
			

			foreach(Touch t in Input.touches)
			{
	            TouchPhase phase = t.phase;

	            switch (phase)
	            {
	                case TouchPhase.Began:
	                    // print("New touch detected at position " + t.position + " , index " + t.fingerId);
	                    break;
	                case TouchPhase.Moved:
	                    // print("Touch index " + t.fingerId + " has moved by " + t.deltaPosition);
	                    break;
	                case TouchPhase.Stationary:
	                    // print("Touch index " + t.fingerId + " is stationary at position " + t.position);
	                    break;
	                case TouchPhase.Ended:
	                    // print("Touch index " + t.fingerId + " ended at position " + t.position);
	                    break;
	                case TouchPhase.Canceled:
	                    // print("Touch index " + t.fingerId + " cancelled");
	                    break;
	            }


	            foreach (var v in touchEventCallBack)
	            {
	                LuaFunction func = v.Value;
	                Vector2 localPosition;
	                RectTransformUtility.ScreenPointToLocalPointInRectangle(canvas.transform as RectTransform, Input.mousePosition, canvas.worldCamera, out localPosition);
	                func.BeginPCall();
	                func.Push(new TouchEvent(t.phase.ToString(), localPosition));
	                func.PCall();
					func.EndPCall();
				}
			}
		}

		public void SetMultiTouchEnabled(bool enable)
		{
			Input.multiTouchEnabled = enable;
		}

		public void RegisterTouchEvent(string name, LuaFunction func)
		{
			this.UnRegisterTouchEvent(name);

			this.touchEventCallBack.Add(name, func);
		}

		public void UnRegisterTouchEvent(string name)
		{
			if(this.touchEventCallBack.ContainsKey(name))
			{
				this.touchEventCallBack[name].Dispose();
				this.touchEventCallBack[name] = null;
				this.touchEventCallBack.Remove(name);
			}
		}

		protected void OnDestroy() {
			foreach(var v in touchEventCallBack)
			{
				v.Value.Dispose();
			}
			touchEventCallBack.Clear();
		}
	}
}