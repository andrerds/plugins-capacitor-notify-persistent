package com.rdisnfor.plugins.capacitornotifypersistent;

import static com.rdisnfor.plugins.capacitornotifypersistent.NotifyPersistentPlugin.myPluginEnabledKey;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;

import androidx.annotation.NonNull;

import com.getcapacitor.Logger;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

public class MessagingService extends FirebaseMessagingService {
    private final String TAG = "NotifyPersistent";
    public static final String CHANNEL_ID = "SILENT_MESSAGE_CHANNEL";
    private NotifyPersistentPlugin plugin = NotifyPersistentPlugin.getInstance();

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
            handleSilentMessage(remoteMessage);
        } else {
            NotifyPersistentPlugin.onMessageReceived(remoteMessage);
        }
    }

    private boolean isSilent(RemoteMessage remoteMessage) {
        Map<String, String> data = remoteMessage.getData();

        // Obter o valor de 'content_available'
        String contentAvailableString = data.get("content_available");

        // Verificar se 'content_available' existe e converter para booleano
        boolean isContentAvailable = false;
        if (contentAvailableString != null) {
            isContentAvailable = Boolean.parseBoolean(contentAvailableString);
        }

        // Determinar se a notificação é silenciosa
        boolean isSilent = remoteMessage.getNotification() == null && !data.isEmpty();

        // Log para debug
        Logger.debug(TAG, "Content available exists: " + (contentAvailableString != null));
        Logger.debug(TAG, "Content available value: " + contentAvailableString);
        Logger.debug(TAG, "Content available as boolean: " + isContentAvailable);
        Logger.debug(TAG, "Notification is silent due to notification being null and data not empty: " + isSilent);

        return isSilent;
    }


    private void handleSilentMessage(RemoteMessage data) {
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