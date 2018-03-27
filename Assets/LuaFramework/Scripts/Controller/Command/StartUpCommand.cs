using UnityEngine;
using System.Collections;
using LuaInterface;
using LuaFramework;

public class StartUpCommand : ControllerCommand {

    public override void Execute(IMessage message) {
        if (!Util.CheckEnvironment()) return;

        GameObject gameMgr = GameObject.Find("GlobalGenerator");
        if (gameMgr != null) {
            AppView appView = gameMgr.AddComponent<AppView>();
        }
        //-----------------关联命令-----------------------
        AppFacade.Instance.RegisterCommand(NotiConst.DISPATCH_MESSAGE, typeof(SocketCommand));
        AppFacade.Instance.RegisterCommand(NotiConst.DISPATCH_UPDATE_MESSAGE, typeof(UpdateCommand));

        //-----------------初始化管理器-----------------------
        AppFacade.Instance.AddManager<LuaManager>(ManagerName.Lua);
		AppFacade.Instance.AddManager<PanelManager>(ManagerName.Panel);
        AppFacade.Instance.AddManager<SoundManager>(ManagerName.Sound);
        AppFacade.Instance.AddManager<TimerManager>(ManagerName.Timer);
        AppFacade.Instance.AddManager<NetworkManager>(ManagerName.Network);
        AppFacade.Instance.AddManager<ResourceManager>(ManagerName.Resource);
        AppFacade.Instance.AddManager<ThreadManager>(ManagerName.Thread);
        AppFacade.Instance.AddManager<ObjectPoolManager>(ManagerName.ObjectPool);
		AppFacade.Instance.AddManager<UpdateManager>(ManagerName.Update);
		AppFacade.Instance.AddManager<TouchManager>(ManagerName.Touch);
		AppFacade.Instance.AddManager<PackageUPKManager>(ManagerName.Packager);

		//-----------------最后添加游戏管理器-----------------------
        AppFacade.Instance.AddManager<GameManager>(ManagerName.Game);
    }
}