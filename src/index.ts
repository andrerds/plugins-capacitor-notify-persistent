/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
import { registerPlugin } from '@capacitor/core';

import type { NotifyPersistentPlugin } from './definitions';

const NotifyPersistent = registerPlugin<NotifyPersistentPlugin>('NotifyPersistent', {});
export * from './definitions';
export { NotifyPersistent };

// Função para registrar os listeners no aplicativo Ionic
export function registerNotificationListeners() {
 
  NotifyPersistent.removeAllListeners();  
  
  NotifyPersistent.addListener('notificationLocalActionPerformed', (action) => {
    console.log('Ação de notificação:', action);
    // Aqui você pode manipular a ação da notificação conforme necessário
  });

  NotifyPersistent.addListener('notificationReceived', (action) => {
    console.log('Ação de notificação:', action);
    // Aqui você pode manipular a ação da notificação conforme necessário
  });

  NotifyPersistent.addListener('notificationActionPerformed', (notification) => {
    console.log('notificationActionPerformed:', notification);
    // Aqui você pode manipular a ação da notificação conforme necessário
  });

 
}
