import type { PluginListenerHandle } from '@capacitor/core';

 export interface NotifyPersistentPlugin {
  stopContinuousVibration(): Promise<{value: boolean}>;
  enablePlugin(): Promise<void>;
  disablePlugin(): Promise<void>;
  isEnabled(): Promise<{ value: boolean }>;
  addListener(eventName: 'notificationReceived', listenerFunc: (notification: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;
  addListener(eventName: 'notificationAction', listenerFunc: (action: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;
}
 