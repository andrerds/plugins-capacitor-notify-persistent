package com.rdisnfor.plugins.capacitornotifypersistent;

import static com.rdisnfor.plugins.capacitornotifypersistent.NotifyPersistentPlugin.TAG;

import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;


import com.getcapacitor.Logger;

public class MyBroadcastReceiver extends BroadcastReceiver {
    NotifyPersistentPlugin plugin = NotifyPersistentPlugin.getInstance();



    @Override
    public void onReceive(Context context, Intent intent) {
        Logger.debug(TAG, "MyBroadcastReceiver");
        String actionIdentifier = intent.getStringExtra("actionIdentifier");
        int notificationId = intent.getIntExtra("notificationId", -1);
        Bundle data = intent.getExtras();

        if (notificationId != -1) {
            NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancel(notificationId);
        }
        if(data !=null){
            plugin.handleNotificationActionPerformed(data);
            // Aqui você pode chamar os listeners específicos com base na ação recebida
            if ("ACCEPT_ACTION".equals(actionIdentifier)) {

            } else if ("REJECT_ACTION".equals(actionIdentifier)) {
                // Chame seu listener de rejeição
                plugin.handleNotificationActionPerformed(data);
            } else if ("NOTIFICATION_TAPPED".equals(actionIdentifier)) {
                // Chame seu listener de notificação tocada
                plugin.handleNotificationActionPerformed(data);
            }
        }


        Intent mainIntent = launchIntent(context);
        context.startActivity(mainIntent);
    }
    private static Intent launchIntent(Context context) {
        try {
            Intent launchIntent =
                    context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);

                return launchIntent;
            }
        } catch (Exception e) {
            e.printStackTrace();
            Logger.debug(TAG + e.getLocalizedMessage());
        }
        return null;
    }
}