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
   * @param {string} eventName O nome do evento ('notificationReceived' ou 'notificationAction').
   * @param {(notification: any) => void} listenerFunc A função que será chamada quando o evento ocorrer.
   * @returns {Promise<PluginListenerHandle> & PluginListenerHandle} Uma promessa que resolve para PluginListenerHandle e também implementa PluginListenerHandle.
   */
  addListener(eventName: 'notificationReceived', listenerFunc: (notification: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;

  /**
   * Adiciona um listener para o evento de ação de notificação.
   * @param {string} eventName O nome do evento ('notificationReceived' ou 'notificationAction').
   * @param {(action: any) => void} listenerFunc A função que será chamada quando o evento ocorrer.
   * @returns {Promise<PluginListenerHandle> & PluginListenerHandle} Uma promessa que resolve para PluginListenerHandle e também implementa PluginListenerHandle.
   */
  addListener(eventName: 'notificationAction', listenerFunc: (action: any) => void): Promise<PluginListenerHandle> & PluginListenerHandle;
}
