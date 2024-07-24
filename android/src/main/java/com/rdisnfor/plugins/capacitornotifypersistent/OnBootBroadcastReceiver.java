package com.rdisnfor.plugins.capacitornotifypersistent;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class OnBootBroadcastReceiver extends BroadcastReceiver  {
    /**
     * @param context The Context in which the receiver is running.
     * @param intent  The Intent being received.
     */
    @Override
    public void onReceive(Context context, Intent intent) {
        Intent i = new Intent("com.rdisnfor.plugins.capacitornotifypersistent");
        i.setClass(context, MessagingService.class);
        context.startService(i);
    }
}
