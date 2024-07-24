package com.rdisnfor.plugins.capacitornotifypersistent;

import static com.rdisnfor.plugins.capacitornotifypersistent.NotifyPersistentPlugin.myPluginEnabledKey;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;
import androidx.core.app.PendingIntentCompat;
import com.getcapacitor.BridgeActivity;


import com.getcapacitor.Logger;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

public class MessagingService extends FirebaseMessagingService {
    private final String TAG = "NotifyPersistent";
    public static final String CHANNEL_ID = "SILENT_MESSAGE_CHANNEL";
    private NotifyPersistentPlugin plugin = new NotifyPersistentPlugin();

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        NotifyPersistentPlugin.onNewToken(token);
    }

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        Logger.debug(TAG, "ONMESSAGERECEIVED 38 SERVICE MESSAGE");

        super.onMessageReceived(remoteMessage);

        if (isSilent(remoteMessage)) {
            Logger.debug(TAG, "Mensagem silenciosa recebida");
            handleSilentMessage(remoteMessage.getData());
        } else {
            NotifyPersistentPlugin.onMessageReceived(remoteMessage);
        }

    }

    private boolean isSilent(RemoteMessage remoteMessage) {
        Map<String, String> data = remoteMessage.getData();
        if (data.containsKey("content_available")) {
            boolean contentAvailable = Boolean.parseBoolean(data.get("content_available"));
            return contentAvailable;
        }
        return remoteMessage.getNotification() == null && !data.isEmpty();
    }

    private void handleSilentMessage(Map<String, String> data) {
        Logger.debug(TAG, "Dados da mensagem silenciosa: " + data.toString());

        SharedPreferences sharedPreferences = getSharedPreferences(myPluginEnabledKey, Context.MODE_PRIVATE);
        boolean isPluginEnabled = sharedPreferences.getBoolean(myPluginEnabledKey, false);


        if (isPluginEnabled) {
            NotifyPersistentVibrationService.startContinuousVibration(this);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
           NotifyPersistentHelper.createLocalNotification(this, data);
        }

        Logger.debug(TAG, "isPluginEnabled: " + isPluginEnabled);


    }
}