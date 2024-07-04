# capacitor-notify-persistent

Notification Persistent

## Install

```bash
npm install capacitor-notify-persistent
npx cap sync
```

## API

<docgen-index>

* [`stopContinuousVibration()`](#stopcontinuousvibration)
* [`enablePlugin()`](#enableplugin)
* [`disablePlugin()`](#disableplugin)
* [`isEnabled()`](#isenabled)
* [`addListener('notificationActionPerformed', ...)`](#addlistenernotificationactionperformed-)
* [`addListener('notificationActionNotifyPersistentPlugin', ...)`](#addlistenernotificationactionnotifypersistentplugin-)
* [`addListener('notificationReceived', ...)`](#addlistenernotificationreceived-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

Interface para gerenciar o plugin de notificações persistentes.

### stopContinuousVibration()

```typescript
stopContinuousVibration() => Promise<{ value: boolean; }>
```

Interrompe a vibração contínua.

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### enablePlugin()

```typescript
enablePlugin() => Promise<void>
```

Habilita o plugin.

--------------------


### disablePlugin()

```typescript
disablePlugin() => Promise<void>
```

Desabilita o plugin.

--------------------


### isEnabled()

```typescript
isEnabled() => Promise<{ value: boolean; }>
```

Verifica se o plugin está habilitado.

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### addListener('notificationActionPerformed', ...)

```typescript
addListener(eventName: 'notificationActionPerformed', listenerFunc: (notification: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Adiciona um listener para o evento de notificação recebida.

| Param              | Type                                        | Description                                                                              |
| ------------------ | ------------------------------------------- | ---------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'notificationActionPerformed'</code>  | O nome do evento ('notificationReceivedNotifyPersistentPlugin' ou 'notificationAction'). |
| **`listenerFunc`** | <code>(notification: any) =&gt; void</code> | A função que será chamada quando o evento ocorrer.                                       |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### addListener('notificationActionNotifyPersistentPlugin', ...)

```typescript
addListener(eventName: 'notificationActionNotifyPersistentPlugin', listenerFunc: (action: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Adds a listener for the notification action event.

| Param              | Type                                                    | Description                                                                                   |
| ------------------ | ------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'notificationActionNotifyPersistentPlugin'</code> | - The name of the event ('notificationActionNotifyPersistentPlugin' or 'notificationAction'). |
| **`listenerFunc`** | <code>(action: any) =&gt; void</code>                   | - The function that will be called when the event occurs.                                     |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

**Since:** 0.2.2

--------------------


### addListener('notificationReceived', ...)

```typescript
addListener(eventName: 'notificationReceived', listenerFunc: (action: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                  |
| ------------------ | ------------------------------------- |
| **`eventName`**    | <code>'notificationReceived'</code>   |
| **`listenerFunc`** | <code>(action: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |

</docgen-api>
