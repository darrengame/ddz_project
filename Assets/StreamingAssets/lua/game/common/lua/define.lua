
DISPATCH_MSG = {
	UPDATE_CHECK = "UpdateCheck",
	UPDATE_EXTRACT = "UpdateExtract",
	UPDATE_DOWNLOAD = "UpdateDownload",
}

--协议类型--
ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 2,
	SPROTO = 3,
}
--当前使用的协议类型--
TestProtoType = ProtocalType.BINARY;

-- ugui类型
UText = UnityEngine.UI.Text
UImage = UnityEngine.UI.Image
UButton = UnityEngine.UI.Button
Toggle = UnityEngine.UI.Toggle
Slider = UnityEngine.UI.Slider

Screen = UnityEngine.Screen
PlayerPrefs = UnityEngine.PlayerPrefs;

Util = LuaFramework.Util;
AppConst = LuaFramework.AppConst;
LuaHelper = LuaFramework.LuaHelper;
ByteBuffer = LuaFramework.ByteBuffer;

resMgr = LuaHelper.GetResManager();
panelMgr = LuaHelper.GetPanelManager();
soundMgr = LuaHelper.GetSoundManager();
networkMgr = LuaHelper.GetNetManager();
updateMgr = LuaHelper.GetUpdateManager();
timerMgr = LuaHelper.GetTimerManager();
threadMgr = LuaHelper.GetThreadManager();
touchMgr = LuaHelper.GetTouchManager();

WWW = UnityEngine.WWW;
GameObject = UnityEngine.GameObject;
DOTween = DG.Tweening.DOTween;
