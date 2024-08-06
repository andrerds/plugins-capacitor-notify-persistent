import type { PermissionState, PluginListenerHandle } from '@capacitor/core';

/**
 * Interface para gerenciar o plugin de notificações persistentes.
 */
export interface NotifyPersistentPlugin {
  /**
   * Interrompe a vibração contínua.
   * @returns {Promise<{value: boolean}>} Uma promessa que resolve para um objeto contendo a propriedade 'value' indicando se a operação foi bem-sucedida.
   */
  stopContinuousVibration(): Promise<{ value: boolean }>;
  /**
   * Habilita o plugin.
   * @returns {Promise<void>} Uma promessa que resolve quando o plugin é habilitado.
   */
  enablePlugin(): Promise<void>;

  /**
   * Desabilita o plugin.
   * @returns {Promise<void>} Uma promessa que resolve quando o plugin é desabilitado.
   */
  disablePlugin(): Promise<void>;

  /**
   * Verifica se o plugin está habilitado.
   * @returns {Promise<{value: boolean}>} Uma promessa que resolve para um objeto contendo a propriedade 'value' indicando se o plugin está habilitado.
   */
  isEnabled(): Promise<{ value: boolean }>;

  /**
   * Adiciona um listener para o evento de notificação recebida.
   * @param {string} eventName O nome do evento ('notificationActionPerformed' ou 'notificationAction').
   * @param {(notification: any) => void} listenerFunc A função que será chamada quando o evento ocorrer.
   * @returns {Promise<PluginListenerHandle> & PluginListenerHandle} Uma promessa que resolve para PluginListenerHandle e também implementa PluginListenerHandle.
   */
  addListener(eventName: 'notificationActionPerformed', listenerFunc: (notification: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;

  /**
   * Adds a listener for the notification action event.
   * @param {string} eventName - The name of the event ('notificationLocalActionPerformed' or 'notificationAction').
   * @param {(action: any) => void} listenerFunc - The function that will be called when the event occurs.
   * @returns {Promise<PluginListenerHandle> & PluginListenerHandle} A promise that resolves to PluginListenerHandle and also implements PluginListenerHandle.
   * @since 0.2.2
   * @example
   * NotifyPersistent.addListener('notificationLocalActionPerformed', (action) => {
   *   console.log('Notification action:', action);
   * });
   */
  addListener(eventName: 'notificationLocalActionPerformed', listenerFunc: (action: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;

  addListener(eventName: 'notificationReceived', listenerFunc: (action: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;

  /**
     * Called when a new FCM token is received.
     *
     * Only available for Android and iOS.
     *
     * @since 0.2.2
     */
  addListener(eventName: 'tokenReceived', listenerFunc: TokenReceivedListener): Promise<PluginListenerHandle> & PluginListenerHandle;
  removeAllListeners(): Promise<void>;

  /**
      * Check permission to receive push notifications.
      *
      * On **Android**, this method only needs to be called on Android 13+.
      *
      * @since 0.2.2
      */
  checkPermissions(): Promise<PermissionStatus>;
  /**
   * Request permission to receive push notifications.
   *
   * On **Android**, this method only needs to be called on Android 13+.
   *
   * @since 0.2.2
   */
  requestPermissions(): Promise<PermissionStatus>;

  getToken(options?: GetTokenOptions): Promise<GetTokenResult>;

  /**
     * Delete the FCM token and unregister the app to stop receiving push notifications.
     * Can be called, for example, when a user signs out.
     *
     * @since 0.2.2
     */
  deleteToken(): Promise<void>;
 
}
export interface GetTokenOptions {
  /**
   * Your VAPID public key, which is required to retrieve the current registration token on the web.
   *
   * Only available for Web.
   */
  vapidKey?: string;
  /**
   * The service worker registration for receiving push messaging.
   * If the registration is not provided explicitly, you need to have a `firebase-messaging-sw.js` at your root location.
   *
   * Only available for Web.
   */
  serviceWorkerRegistration?: ServiceWorkerRegistration;
}

export interface GetTokenResult {
  /**
   * @since 0.2.2
   */
  token: string;
}

export interface PermissionStatus {
  /**
   * @since 0.2.2
   */
  receive: PermissionState;
}
/**
 * Callback to receive the token received event.
 *
 * @since 0.2.2
 */
export declare type TokenReceivedListener = (event: TokenReceivedEvent) => void;
export interface TokenReceivedEvent {
  /**
   * @since 0.2.2
   */
  token: string;
}