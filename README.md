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
* [`addListener('notificationReceived', ...)`](#addlistenernotificationreceived-)
* [`addListener('notificationAction', ...)`](#addlistenernotificationaction-)
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


### addListener('notificationReceived', ...)

```typescript
addListener(eventName: 'notificationReceived', listenerFunc: (notification: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Adiciona um listener para o evento de notificação recebida.

| Param              | Type                                        | Description                                                        |
| ------------------ | ------------------------------------------- | ------------------------------------------------------------------ |
| **`eventName`**    | <code>'notificationReceived'</code>         | O nome do evento ('notificationReceived' ou 'notificationAction'). |
| **`listenerFunc`** | <code>(notification: any) =&gt; void</code> | A função que será chamada quando o evento ocorrer.                 |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### addListener('notificationAction', ...)

```typescript
addListener(eventName: 'notificationAction', listenerFunc: (action: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Adiciona um listener para o evento de ação de notificação.

| Param              | Type                                  | Description                                                        |
| ------------------ | ------------------------------------- | ------------------------------------------------------------------ |
| **`eventName`**    | <code>'notificationAction'</code>     | O nome do evento ('notificationReceived' ou 'notificationAction'). |
| **`listenerFunc`** | <code>(action: any) =&gt; void</code> | A função que será chamada quando o evento ocorrer.                 |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |

</docgen-api>
