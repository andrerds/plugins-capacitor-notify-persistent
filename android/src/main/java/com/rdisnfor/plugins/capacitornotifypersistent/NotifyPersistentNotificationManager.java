package com.rdisnfor.plugins.capacitornotifypersistent;

import android.os.Build;

import androidx.annotation.RequiresApi;

import java.util.LinkedList;
import java.util.List;

public class NotifyPersistentNotificationManager {
    private static final int MAX_NOTIFICATIONS = 50;
    private static NotifyPersistentNotificationManager instance;
    private final List<InMemoryNotification> notifications;

    private NotificationManager() {
        notifications = new LinkedList<>();
    }

    public static synchronized NotifyPersistentNotificationManager getInstance() {
        if (instance == null) {
            instance = new NotifyPersistentNotificationManager();
        }
        return instance;
    }

    public void addNotification(InMemoryNotification notification) {
        if (notifications.size() >= MAX_NOTIFICATIONS) {
            notifications.remove(0); // Remove a notificação mais antiga
        }
        notifications.add(notification);
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    public void removeNotificationByEid(String eid) {
        notifications.removeIf(notification -> eid.equals(notification.getEid()));
    }

    public List<InMemoryNotification> getNotifications() {
        return new LinkedList<>(notifications); // Retorna uma cópia da lista
    }
}

