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

### stopContinuousVibration()

```typescript
stopContinuousVibration() => Promise<{ value: boolean; }>
```

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### enablePlugin()

```typescript
enablePlugin() => Promise<void>
```

--------------------


### disablePlugin()

```typescript
disablePlugin() => Promise<void>
```

--------------------


### isEnabled()

```typescript
isEnabled() => Promise<{ value: boolean; }>
```

**Returns:** <code>Promise&lt;{ value: boolean; }&gt;</code>

--------------------


### addListener('notificationReceived', ...)

```typescript
addListener(eventName: 'notificationReceived', listenerFunc: (notification: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                        |
| ------------------ | ------------------------------------------- |
| **`eventName`**    | <code>'notificationReceived'</code>         |
| **`listenerFunc`** | <code>(notification: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### addListener('notificationAction', ...)

```typescript
addListener(eventName: 'notificationAction', listenerFunc: (action: any) => void) => Promise<PluginListenerHandle> & PluginListenerHandle
```

| Param              | Type                                  |
| ------------------ | ------------------------------------- |
| **`eventName`**    | <code>'notificationAction'</code>     |
| **`listenerFunc`** | <code>(action: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt; & <a href="#pluginlistenerhandle">PluginListenerHandle</a></code>

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |

</docgen-api>
