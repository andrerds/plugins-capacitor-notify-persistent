import type { PluginListenerHandle } from '@capacitor/core';

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
   * @param {string} eventName O nome do evento ('notificationReceivedNotifyPersistentPlugin' ou 'notificationAction').
   * @param {(notification: any) => void} listenerFunc A função que será chamada quando o evento ocorrer.
   * @returns {Promise<PluginListenerHandle> & PluginListenerHandle} Uma promessa que resolve para PluginListenerHandle e também implementa PluginListenerHandle.
   */
  addListener(eventName: 'notificationActionPerformed', listenerFunc: (notification: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;

  /**
   * Adds a listener for the notification action event.
   * @param {string} eventName - The name of the event ('notificationActionNotifyPersistentPlugin' or 'notificationAction').
   * @param {(action: any) => void} listenerFunc - The function that will be called when the event occurs.
   * @returns {Promise<PluginListenerHandle> & PluginListenerHandle} A promise that resolves to PluginListenerHandle and also implements PluginListenerHandle.
   * @since 0.2.2
   * @example
   * NotifyPersistent.addListener('notificationActionNotifyPersistentPlugin', (action) => {
   *   console.log('Notification action:', action);
   * });
   */
  addListener(eventName: 'notificationActionNotifyPersistentPlugin', listenerFunc: (action: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;

  addListener(eventName: 'notificationReceived', listenerFunc: (action: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;


  removeAllListeners(): Promise<void>;

}
