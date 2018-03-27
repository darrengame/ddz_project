using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LuaFramework;

public class UpdateCommand : ControllerCommand {

    public override void Execute(IMessage message) {
        object data = message.Body;
        if (data == null) return;
        KeyValuePair<string, string> buffer = (KeyValuePair<string, string>)data;
        switch (buffer.Key) {
            default: Util.CallMethod("UpdateCtrl", "onUpdateMsg", buffer.Key, buffer.Value); break;
        }
	}
}