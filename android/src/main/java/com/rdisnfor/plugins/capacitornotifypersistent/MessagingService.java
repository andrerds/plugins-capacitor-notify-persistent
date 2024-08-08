package com.rdisnfor.plugins.capacitornotifypersistent;

import static com.rdisnfor.plugins.capacitornotifypersistent.NotifyPersistentPlugin.ERROR_NOTIFICATIONS_INVALID;
import static com.rdisnfor.plugins.capacitornotifypersistent.NotifyPersistentPlugin.ERROR_NOTIFICATIONS_MISSING;
import static com.rdisnfor.plugins.capacitornotifypersistent.NotifyPersistentPlugin.myPluginEnabledKey;

import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.service.notification.StatusBarNotification;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Logger;
import com.getcapacitor.PluginCall;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class MessagingService extends FirebaseMessagingService {
    private final String TAG = "NotifyPersistent";
    public static final String CHANNEL_ID = "SILENT_MESSAGE_CHANNEL";
    public NotifyPersistentPlugin plugin = NotifyPersistentPlugin.getInstance();
    private final NotifyPersistentNotificationManager notificationManager = NotifyPersistentNotificationManager.getInstance();

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
            handleRemoveNotification(remoteMessage);
        } else {
            NotifyPersistentPlugin.onMessageReceived(remoteMessage);
        }
    }

    private boolean isSilent(RemoteMessage remoteMessage) {
        Map<String, String> data = remoteMessage.getData();
        String contentAvailableString = data.get("content_available");
        boolean isContentAvailable = contentAvailableString != null && Boolean.parseBoolean(contentAvailableString);
        boolean isSilent = remoteMessage.getNotification() == null && !data.isEmpty();
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

    private void handleRemoveNotification(RemoteMessage remoteMessage) {
        Map<String, String> data = remoteMessage.getData();
        NotificationManager notificationManager = (NotificationManager) getApplicationContext().getSystemService(Context.NOTIFICATION_SERVICE);

        if (!data.isEmpty() && "REMOVE".equals(data.get("type")) && data.containsKey("eid")) {
            int eid;
            try {
                eid = Integer.parseInt(data.get("eid"));
            } catch (NumberFormatException e) {
                Logger.debug(TAG, "Invalid EID format: " + data.get("eid"));
                return;
            }

            if (notificationManager != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                StatusBarNotification[] activeNotifications = notificationManager.getActiveNotifications();
                boolean notificationFound = false;

                for (StatusBarNotification sbn : activeNotifications) {
                    Logger.debug(TAG, "StatusBarNotification: " + sbn);
                    int notificationEid = sbn.getId();
                    if (eid == notificationEid) {
                        notificationManager.cancel(sbn.getId());
                        Logger.debug(TAG, "Notification with EID " + eid + " removed.");
                        notificationFound = true;
                        break;
                    }
                }

                // Verificar se ainda há notificações restantes
                if (notificationFound) {
                    boolean hasMoreNotifications = false;
                    for (StatusBarNotification sbn : activeNotifications) {
                        if (sbn.getId() != eid) {
                            hasMoreNotifications = true;
                            break;
                        }
                    }

                    if (!hasMoreNotifications) {
                        // Se não houver mais notificações, pare o som e a vibração
                        NotifyPersistentVibrationService.stopContinuousVibration(true);
                    }
                } else {
                    // Se nenhuma notificação foi encontrada com o EID especificado com type remove
                    NotifyPersistentVibrationService.startContinuousVibration(this);
                }
            }
        } else {
            handleSilentMessage(remoteMessage);
        }
    }
//    TODO: Remover  showToast
    /*
     private void showToast(){
        try{Looper.prepare();

            new Handler(Looper.getMainLooper()).post(() -> {
                Context context = getApplicationContext();
                if (context != null) {
                    Toast.makeText(context, "Notification removed successfully!", Toast.LENGTH_SHORT).show();
                }
            });}
        catch (Exception e){
        }
    }
    */
}
