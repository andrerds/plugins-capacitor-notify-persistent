package com.rdisnfor.plugins.capacitornotifypersistent



import android.content.Context
import android.content.Context.VIBRATOR_SERVICE
import android.os.Vibrator

object NotifyPersistentVibrationService {
    private var vibrator: Vibrator? = null

    fun startContinuousVibration(context: Context) {
        vibrator = context.getSystemService(VIBRATOR_SERVICE) as Vibrator
        val pattern = longArrayOf(0, 100, 1000)
        vibrator?.vibrate(pattern, 0)
    }

    fun stopContinuousVibration(context: Context) {
        vibrator?.cancel()
    }
}