package com.rdisnfor.plugins.capacitornotifypersistent;

import android.content.Context;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.os.Vibrator;

import java.lang.ref.WeakReference;

public class NotifyPersistentVibrationService {
    private static Vibrator vibrator = null;
    private static MediaPlayer mediaPlayer = null;
    private static final Handler handler = new Handler(Looper.getMainLooper());
    private static boolean isVibrating = false;
    private static Runnable vibrationRunnable;
    private static Runnable soundRunnable;

    public static void startContinuousVibration(Context context) {
        stopContinuousVibration(true);

        vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        Uri notificationUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        WeakReference<Context> contextRef = new WeakReference<>(context); //  leakMemory clear

        // Definindo um padrão de vibração longo com leves pausas
        long[] vibrationPattern = {0, 1000, 500, 1000, 500}; // Vibra 1 segundo, pausa 0.5 segundos, repete

        // Runnable para gerenciar a vibração
        vibrationRunnable = new Runnable() {
            @Override
            public void run() {
                if (vibrator != null) {
                    vibrator.vibrate(vibrationPattern, 0); // Vibração com padrão
                }
            }
        };

        // Runnable para gerenciar o som
        soundRunnable = new Runnable() {
            @Override
            public void run() {
                Context ctx = contextRef.get();
                if (ctx == null) return; // Evitar vazamento de memória

                if (mediaPlayer != null && mediaPlayer.isPlaying()) {
                    mediaPlayer.stop();
                    mediaPlayer.reset();
                }
                mediaPlayer = MediaPlayer.create(ctx, notificationUri);
                if (mediaPlayer != null) {
                    mediaPlayer.start(); // Tocar som de notificação
                    int duration = mediaPlayer.getDuration();
                    handler.postDelayed(this, duration); // Repetir o som após a duração
                }
            }
        };

        isVibrating = true;
        handler.post(vibrationRunnable);
        handler.post(soundRunnable);
    }


    public static boolean stopContinuousVibration(Boolean Stop) {
        boolean wasVibrating = Stop;
        if (wasVibrating) {
            handler.removeCallbacks(vibrationRunnable);
            handler.removeCallbacks(soundRunnable);
            if (vibrator != null) {
                vibrator.cancel();
            }
            if (mediaPlayer != null) {
                if (mediaPlayer.isPlaying()) {
                    mediaPlayer.stop();
                }
                mediaPlayer.release();
                mediaPlayer = null;
            }
            isVibrating = false;
        }
        return wasVibrating;
    }
}
