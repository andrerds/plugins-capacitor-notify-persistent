package com.rdisnfor.plugins.capacitornotifypersistent;

import android.util.Log;

public class NotifyPersistent {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }

    public boolean isEnabled(boolean value) {
        Log.i("isEnabled", String.valueOf(value));
        return value;
    }

    public boolean enablePlugin(boolean value) {
        Log.i("enablePlugin", String.valueOf(value));
        return value;
    }

    public boolean disablePlugin(boolean value) {
        Log.i("disablePlugin", String.valueOf(value));
        return value;
    }

    public boolean stopContinuousVibration(boolean value) {
        Log.i("stopContinuousVibration", String.valueOf(value));
        return value;
    }

    public void removeAllListeners() {
        Log.i("removeAllListeners", "removeAllListeners");
    }

}
