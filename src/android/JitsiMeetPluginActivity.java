package com.cordova.plugin.jitsi;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.os.Bundle;
import com.cordova.plugin.jitsi.JitsiPlugin;//.JITSI_PLUGIN_TAG
import org.jitsi.meet.sdk.JitsiMeetActivity;
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions;

import java.util.HashMap;
import java.util.Map;

public class JitsiMeetPluginActivity extends JitsiMeetActivity {

    public static void launchActivity(Context context, JitsiMeetConferenceOptions options) {
        Intent intent = new Intent(context, JitsiMeetPluginActivity.class);
        intent.setAction("org.jitsi.meet.CONFERENCE");
        intent.putExtra("JitsiMeetConferenceOptions", options);
        context.startActivity(intent);

    }

    @Override
    public void onDestroy() {
        JitsiPluginModel.getInstance().changeState("onConferenceDestroyed");
        super.onDestroy();
    }

    @Override
    public void finish() {
        JitsiPluginModel.getInstance().changeState("onConferenceFinished");
        super.finish();
    }

    @Override
    protected void onConferenceJoined(HashMap<String, Object> extraData) {
        JitsiPluginModel.getInstance().changeState("onConferenceJoined");
        super.onConferenceJoined(extraData);
    }

    @Override
    protected void onConferenceTerminated(HashMap<String, Object> extraData) {
        JitsiPluginModel.getInstance().changeState("onConferenceTerminated");
        super.onConferenceTerminated(extraData);
    }

    @Override
    protected void onConferenceWillJoin(HashMap<String, Object> extraData) {
        JitsiPluginModel.getInstance().changeState("onConferenceWillJoin");
        super.onConferenceWillJoin(extraData);
    }
}
