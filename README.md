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
* [`addListener('notificationLocalActionPerformed', ...)`](#addlistenernotificationlocalactionperformed-)
* [`addListener('notificationReceived', ...)`](#addlistenernotificationreceived-)
* [`addListener('tokenReceived', ...)`](#addlistenertokenreceived-)
* [`removeAllListeners()`](#removealllisteners)
* [`checkPermissions()`](#checkpermissions)
* [`requestPermissions()`](#requestpermissions)
* [`getToken(...)`](#gettoken)
* [`deleteToken()`](#deletetoken)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

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

| Param              | Type                                        | Description                                                               |
| ------------------ | ------------------------------------------- | ------------------------------------------------------------------------- |
| **`eventName`**    | <code>'notificationActionPerformed'</code>  | O nome do evento ('notificationActionPerformed' ou 'notificationAction'). |
| **`listenerFunc`** | <code>(notification: any) =&gt; void</code> | A função que será chamada quando o evento ocorrer.                        |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### addListener('notificationLocalActionPerformed', ...)

```typescript
addListener(eventName: 'notificationLocalActionPerformed', listenerFunc: (action: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Adds a listener for the notification action event.

| Param              | Type                                            | Description                                                                           |
| ------------------ | ----------------------------------------------- | ------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'notificationLocalActionPerformed'</code> | - The name of the event ('notificationLocalActionPerformed' or 'notificationAction'). |
| **`listenerFunc`** | <code>(action: any) =&gt; void</code>           | - The function that will be called when the event occurs.                             |

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


### addListener('tokenReceived', ...)

```typescript
addListener(eventName: 'tokenReceived', listenerFunc: TokenReceivedListener) => Promise<PluginListenerHandle> & PluginListenerHandle
```

Called when a new FCM token is received.

Only available for Android and iOS.

| Param              | Type                                                                    |
| ------------------ | ----------------------------------------------------------------------- |
| **`eventName`**    | <code>'tokenReceived'</code>                                            |
| **`listenerFunc`** | <code><a href="#tokenreceivedlistener">TokenReceivedListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

**Since:** 0.2.2

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------


### checkPermissions()

```typescript
checkPermissions() => Promise<PermissionStatus>
```

Check permission to receive push notifications.

On **Android**, this method only needs to be called on Android 13+.

**Returns:** <code>Promise&lt;<a href="#permissionstatus">PermissionStatus</a>&gt;</code>

**Since:** 0.2.2

--------------------


### requestPermissions()

```typescript
requestPermissions() => Promise<PermissionStatus>
```

Request permission to receive push notifications.

On **Android**, this method only needs to be called on Android 13+.

**Returns:** <code>Promise&lt;<a href="#permissionstatus">PermissionStatus</a>&gt;</code>

**Since:** 0.2.2

--------------------


### getToken(...)

```typescript
getToken(options?: GetTokenOptions | undefined) => Promise<GetTokenResult>
```

| Param         | Type                                                        |
| ------------- | ----------------------------------------------------------- |
| **`options`** | <code><a href="#gettokenoptions">GetTokenOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#gettokenresult">GetTokenResult</a>&gt;</code>

--------------------


### deleteToken()

```typescript
deleteToken() => Promise<void>
```

Delete the FCM token and unregister the app to stop receiving push notifications.
Can be called, for example, when a user signs out.

**Since:** 0.2.2

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### TokenReceivedEvent

| Prop        | Type                | Since |
| ----------- | ------------------- | ----- |
| **`token`** | <code>string</code> | 0.2.2 |


#### PermissionStatus

| Prop          | Type                                                        | Since |
| ------------- | ----------------------------------------------------------- | ----- |
| **`receive`** | <code><a href="#permissionstate">PermissionState</a></code> | 0.2.2 |


#### GetTokenResult

| Prop        | Type                | Since |
| ----------- | ------------------- | ----- |
| **`token`** | <code>string</code> | 0.2.2 |


#### GetTokenOptions

| Prop                            | Type                                   | Description                                                                                                                                                                                                |
| ------------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`vapidKey`**                  | <code>string</code>                    | Your VAPID public key, which is required to retrieve the current registration token on the web. Only available for Web.                                                                                    |
| **`serviceWorkerRegistration`** | <code>ServiceWorkerRegistration</code> | The service worker registration for receiving push messaging. If the registration is not provided explicitly, you need to have a `firebase-messaging-sw.js` at your root location. Only available for Web. |


### Type Aliases


#### TokenReceivedListener

Callback to receive the token received event.

<code>(event: <a href="#tokenreceivedevent">TokenReceivedEvent</a>): void</code>


#### PermissionState

<code>'prompt' | 'prompt-with-rationale' | 'granted' | 'denied'</code>

</docgen-api>
