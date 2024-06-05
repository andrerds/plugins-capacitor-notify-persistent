/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import { registerPlugin } from '@capacitor/core';

import type { NotifyPersistentPlugin } from './definitions';

const NotifyPersistent = registerPlugin<NotifyPersistentPlugin>('NotifyPersistent',{});
export * from './definitions';
export { NotifyPersistent };

// Função para registrar os listeners no aplicativo Ionic
// Função para registrar os listeners no aplicativo Ionic
export function registerNotificationListeners() {
  NotifyPersistent.addListener('notificationReceived', (notification) => {
    console.log('Notificação recebida:', notification);
    // Aqui você pode manipular a notificação conforme necessário
  });

  NotifyPersistent.addListener('notificationAction', (action) => {
    console.log('Ação de notificação:', action);
    // Aqui você pode manipular a ação da notificação conforme necessário
  });
}
