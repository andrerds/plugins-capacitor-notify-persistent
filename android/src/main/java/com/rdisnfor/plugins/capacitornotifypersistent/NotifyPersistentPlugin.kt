package com.rdisnfor.plugins.capacitornotifypersistent


import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

import com.getcapacitor.*


@CapacitorPlugin
class NotifyPersistentPlugin : Plugin() {

    private val channelId = "visitor_request_channel"
    private val notifyListenerReceived = "notificationReceived"
    private val notifyListenerAction = "notificationActionPerformed"
    private val notificationButtonTapped = "notificationButtonTapped"
    private val preferencesName = "NotifyPersistentPreferences"
    private val pluginEnabledKey = "NotifyPersistentPluginEnabled"

    override fun load() {
        super.load()
        createNotificationChannel()
    }

    @PluginMethod
    fun enablePlugin(call: PluginCall) {
        setPluginEnabled(true)
        call.resolve(JSObject().apply { put("value", true) })
    }

    @PluginMethod
    fun disablePlugin(call: PluginCall) {
        setPluginEnabled(false)
        call.resolve(JSObject().apply { put("value", false) })
    }

    @PluginMethod
    fun isEnabled(call: PluginCall) {
        val isEnabled = isPluginEnabled()
        call.resolve(JSObject().apply { put("value", isEnabled) })
    }


    @PluginMethod
    fun stopContinuousVibration(call: PluginCall) {
        NotifyPersistentVibrationService.stopContinuousVibration(context)
        call.resolve(JSObject().apply { put("value", true) })
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Visitor Request"
            val descriptionText = "Channel for visitor request notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun sendLocalNotification(title: String, body: String, idPushNotification: String, additionalData: Map<String, Any>) {

        NotifyPersistentVibrationService.stopContinuousVibration(context)
        NotifyPersistentVibrationService.startContinuousVibration(context)

        val builder = NotificationCompat.Builder(context, channelId)
//            .setSmallIcon(R.mipmap.icon_launcher)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        with(NotificationManagerCompat.from(context)) {


            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
            this.notify(idPushNotification.hashCode(), builder.build())
        }
    }

    private fun setPluginEnabled(enabled: Boolean) {
        val sharedPreferences: SharedPreferences = context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putBoolean(pluginEnabledKey, enabled)
        editor.apply()
    }

    private fun isPluginEnabled(): Boolean {
        val sharedPreferences: SharedPreferences = context.getSharedPreferences(preferencesName, Context.MODE_PRIVATE)
        return sharedPreferences.getBoolean(pluginEnabledKey, false)
    }

}