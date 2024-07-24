package com.rdisnfor.plugins.capacitornotifypersistent;



import static com.rdisnfor.plugins.capacitornotifypersistent.MessagingService.CHANNEL_ID;
import static com.rdisnfor.plugins.capacitornotifypersistent.NotifyPersistentPlugin.TAG;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.service.notification.StatusBarNotification;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.getcapacitor.JSObject;
import com.getcapacitor.Logger;
import com.getcapacitor.PluginCall;
import com.getcapacitor.util.WebColor;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;
import java.util.Objects;

public class NotifyPersistentHelper {

    public static JSObject createNotificationResult(@NonNull RemoteMessage remoteMessage) {
        JSObject notificationResult = new JSObject();
        notificationResult.put("id", remoteMessage.getMessageId());

        JSObject data = new JSObject();
        for (String key : remoteMessage.getData().keySet()) {
            Object value = remoteMessage.getData().get(key);
            data.put(key, value);
        }
        notificationResult.put("data", data);

        RemoteMessage.Notification notification = remoteMessage.getNotification();
        if (notification != null) {
            notificationResult.put("title", notification.getTitle());
            notificationResult.put("body", notification.getBody());
            notificationResult.put("clickAction", notification.getClickAction());
            notificationResult.put("tag", notification.getTag());

            Uri link = notification.getLink();
            if (link != null) {
                notificationResult.put("link", link.toString());
            }
        }
        return notificationResult;
    }

    public static JSObject createNotificationResult(@NonNull Bundle bundle) {
        JSObject notificationResult = new JSObject();
        JSObject data = new JSObject();
        for (String key : bundle.keySet()) {
            if (key.equals("google.message_id")) {
                notificationResult.put("id", "" + bundle.get(key).toString());
            } else {
                data.put(key, bundle.get(key));
            }
        }
        notificationResult.put("data", data);
        return notificationResult;
    }

    public static JSObject createNotificationResult(@NonNull StatusBarNotification statusBarNotification) {
        JSObject notificationResult = new JSObject();
        notificationResult.put("id", "" + statusBarNotification.getId());
        notificationResult.put("tag", statusBarNotification.getTag());

        Notification notification = statusBarNotification.getNotification();
        if (notification != null) {
            notificationResult.put("title", notification.extras.getCharSequence(Notification.EXTRA_TITLE));
            notificationResult.put("body", notification.extras.getCharSequence(Notification.EXTRA_TEXT));

            JSObject extras = new JSObject();
            for (String key : notification.extras.keySet()) {
                extras.put(key, notification.extras.get(key));
            }
            notificationResult.put("data", extras);
        }

        return notificationResult;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Nullable
    public static NotificationChannel createNotificationChannelFromPluginCall(PluginCall call, String packageName) {
        String id = call.getString("id");
        if (id == null) {
            return null;
        }
        String name = call.getString("name");
        if (name == null) {
            return null;
        }
        int importance = call.getInt("importance", NotificationManager.IMPORTANCE_DEFAULT);
        String description = call.getString("description", "");
        int visibility = call.getInt("visibility", NotificationCompat.VISIBILITY_PUBLIC);
        boolean vibrate = call.getBoolean("vibrate", false);
        boolean lights = call.getBoolean("lights", false);
        String lightColor = call.getString("lightColor", null);
        String sound = call.getString("sound", null);

        NotificationChannel notificationChannel = new NotificationChannel(id, name, importance);
        notificationChannel.setDescription(description);
        notificationChannel.setLockscreenVisibility(visibility);
        notificationChannel.enableVibration(vibrate);
        notificationChannel.enableLights(lights);
        if (lightColor != null) {
            try {
                notificationChannel.setLightColor(WebColor.parseColor(lightColor));
            } catch (Exception exception) {
                Logger.error(TAG, "setLightColor failed.", exception);
            }
        }
        if (sound != null && !sound.isEmpty()) {
            if (sound.contains(".")) {
                sound = sound.substring(0, sound.lastIndexOf('.'));
            }
            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build();
            Uri soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + packageName + "/raw/" + sound);
            notificationChannel.setSound(soundUri, audioAttributes);
        }
        return notificationChannel;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    public static JSObject createChannelResult(@NonNull NotificationChannel notificationChannel) {
        JSObject channelResult = new JSObject();
        channelResult.put("id", notificationChannel.getId());
        channelResult.put("name", notificationChannel.getName());
        channelResult.put("description", notificationChannel.getDescription());
        channelResult.put("importance", notificationChannel.getImportance());
        channelResult.put("visibility", notificationChannel.getLockscreenVisibility());
        channelResult.put("sound", notificationChannel.getSound());
        channelResult.put("vibration", notificationChannel.shouldVibrate());
        channelResult.put("lights", notificationChannel.shouldShowLights());
        channelResult.put("lightColor", String.format("#%06X", (0xFFFFFF & notificationChannel.getLightColor())));
        return channelResult;
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    public static void createLocalNotification(Context context, Map<String, String> data) {
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Silent Message Channel",
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription("Canal para mensagens silenciosas");
            notificationManager.createNotificationChannel(channel);
        }

        String title = data.getOrDefault("title", "Mensagem Silenciosa");
        String body = data.getOrDefault("body", "Você recebeu uma mensagem silenciosa.");

        // Create notification default intent to open the MainActivity from Capacitor app when tapped.
        Intent intent = launchIntent(context);

        // Intents para interações da notificação
        Intent notificationTapIntent = new Intent(intent);
        notificationTapIntent.setAction("NOTIFICATION_TAPPED");
        notificationTapIntent.putExtra("stopVibrationAndSound", true);
        notificationTapIntent.putExtra("act", "NOTIFICATION_TAPPED");
        for (Map.Entry<String, String> entry : data.entrySet()) {
            notificationTapIntent.putExtra(entry.getKey(), entry.getValue());
        }
        PendingIntent notificationTapPendingIntent = PendingIntent.getActivity(context, 0, notificationTapIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Intent acceptActionIntent = new Intent(intent);
        acceptActionIntent.setAction("ACCEPT_ACTION");
        acceptActionIntent.putExtra("stopVibrationAndSound", true);
        acceptActionIntent.putExtra("act", "ACCEPT_ACTION");
        for (Map.Entry<String, String> entry : data.entrySet()) {
            acceptActionIntent.putExtra(entry.getKey(), entry.getValue());
        }
        PendingIntent acceptPendingIntent = PendingIntent.getActivity(context, 1, acceptActionIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        Intent rejectActionIntent = new Intent(intent);
        rejectActionIntent.setAction("REJECT_ACTION");
        rejectActionIntent.putExtra("stopVibrationAndSound", true);
        rejectActionIntent.putExtra("act", "REJECT_ACTION");
        for (Map.Entry<String, String> entry : data.entrySet()) {
            rejectActionIntent.putExtra(entry.getKey(), entry.getValue());
        }
        PendingIntent rejectPendingIntent = PendingIntent.getActivity(context, 2, rejectActionIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);

        @SuppressLint("NotificationTrampoline")
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setContentIntent(notificationTapPendingIntent)
                .addAction(0, "Aceitar", acceptPendingIntent)
                .addAction(0, "Rejeitar", rejectPendingIntent);

        notificationManager.notify(0, notificationBuilder.build());

        // Adicionar logs para depuração
        Log.d("NotifyPersistentHelper", "createLocalNotification: Notificação criada");
        Log.d("NotifyPersistentHelper", "createLocalNotification: Title - " + title);
        Log.d("NotifyPersistentHelper", "createLocalNotification: Body - " + body);
        Log.d("NotifyPersistentHelper", "createLocalNotification: Notification tap intent - " + notificationTapIntent);
        Log.d("NotifyPersistentHelper", "createLocalNotification: Accept action intent - " + acceptActionIntent);
        Log.d("NotifyPersistentHelper", "createLocalNotification: Reject action intent - " + rejectActionIntent);
    }

    private static Intent launchIntent(Context context) {
        //package br.com.keyaccess.keyaccesspass;
        try {
            Intent launchIntent =
                    context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);

                return launchIntent;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}