import Foundation
import FirebaseMessaging
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

@objc(
    NotifyPersistentPlugin
)
public class NotifyPersistentPlugin: CAPPlugin, CAPBridgedPlugin, UNUserNotificationCenterDelegate {
    private var implementation: NotifyPersistent?
    
    public let identifier = "NotifyPersistentPlugin"
    public let jsName = "NotifyPersistent"
    public let tag = "NotifyPersistentPlugin"
    
    public let notifyListenerReceived = "notificationReceived"
    public let notifyListenerAction = "notificationActionPerformed"
    public let didReceiveRemoteNotificationName = "didReceiveRemoteNotification"
    public let notificationButtonTapped = "notificationButtonTapped"
    public let config = NotifyPersistentConfig()
    private let categoryLocalNotificationName = "VISITOR_REQUEST"
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(
            name: "isEnabled",
            returnType: CAPPluginReturnPromise
        ),
        CAPPluginMethod(
            name: "enablePlugin",
            returnType: CAPPluginReturnPromise
        ),
        CAPPluginMethod(
            name: "disablePlugin",
            returnType: CAPPluginReturnPromise
        ),
        CAPPluginMethod(
            name: "stopContinuousVibration",
            returnType: CAPPluginReturnPromise
        ),
        CAPPluginMethod(
            name: "removeAllListeners",
            returnType: CAPPluginReturnPromise
        ),
        
        CAPPluginMethod(
            name: "checkPermissions",
            returnType: CAPPluginReturnPromise
        ),
        
        CAPPluginMethod(
            name: "requestPermissions",
            returnType: CAPPluginReturnPromise
        ),
        
        CAPPluginMethod(
            name: "getToken",
            returnType: CAPPluginReturnPromise
        ),
        
        CAPPluginMethod(
            name: "deleteToken",
            returnType: CAPPluginReturnPromise
        ),
        
    ]
    
    
    let vibrationService = NotifyPersistentVibrationService.shared
    
    let myPluginEnabledKey = "NotifyPersistentPluginEnabled"  // Definindo a constante para a chave de UserDefaults
    // Padrão é false
    var isEnabledPlugin: Bool = false
    
    override public func load() {
        implementation = NotifyPersistent(plugin: self, config: NotifyPersistentConfig())
        isEnabledPlugin = isPluginEnabled()
        
        configureNotificationActions()
        
        // MARK:     Observers
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveRemoteNotification(notification:)),
                                               name: Notification.Name(didReceiveRemoteNotificationName.self),
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.processNotificationAction(notification:)),
                                               name: Notification.Name(notificationButtonTapped),
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.stopVibrationOnNotificationsCleared),
                                               name: Notification.Name("NotificationsCleared"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didRegisterForRemoteNotifications(notification:)), name: .capacitorDidRegisterForRemoteNotifications, object: nil)
        
        UIApplication.shared.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
    }
    
    
    //    MARK: DESTROY
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc public func configureNotificationActions(){
        // Definir as ações e a categoria
        let acceptActionTitle = NSLocalizedString(
            "ACCEPT_ACTION_TITLE",
            comment: "Title for Accept action"
        )
        let rejectActionTitle = NSLocalizedString(
            "REJECT_ACTION_TITLE",
            comment: "Title for Reject action"
        )
        
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_ACTION",
            title: acceptActionTitle,
            options: [.foreground]
        )
        
        let rejectAction = UNTextInputNotificationAction(
            identifier: "REJECT_ACTION",
            title: rejectActionTitle,
            options: [
                .destructive,
                .foreground
            ],
            textInputButtonTitle: NSLocalizedString(
                "BNT_SEND",
                comment: "Button title for sending input"
            ),
            textInputPlaceholder: NSLocalizedString(
                "INPUT_REASON_PLACEHOLDER",
                comment: "Placeholder for input field"
            )
            
        )
        
        let category = UNNotificationCategory(
            identifier: "VISITOR_REQUEST",
            actions: [
                acceptAction,
                rejectAction
            ],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories(
            [category]
        )
    }
    
    @objc private func didReceiveRemoteNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print("\(tag.self) didReceiveRemoteNotification:: No userInfo found")
            return
        }
        
        print("\(tag.self) didReceiveRemoteNotification:: = 1", userInfo)
        let pluginIsEnabled = isPluginEnabled()
        
        if let type = userInfo["type"] as? String,  userInfo["type"] == nil || type == "REMOVE_NOTIFICATION",
           let eid = userInfo["eid"] as? String {
            self.removeNotificationByEid(eid, category: categoryLocalNotificationName.self)
        } else {
            print("\(tag.self) didReceiveRemoteNotification:: = 2 processNotification and create", userInfo)
            
            let type = userInfo["type"] as? String
            
            if pluginIsEnabled && type ==  "NEED_APPROVAL" {
                vibrationService.stopContinuousVibration()
                vibrationService.startContinuousVibration()
            }
            
        }
        
        
        
        processNotification(notification)
        
    }
    
    
    @objc func processNotificationAction(notification: NSNotification) {
        
        print("\(tag.self) processNotificationAction::notification  =  1")
        
        guard let response = notification.object as? UNNotificationResponse else {
            return
        }
        
        print("\(tag.self) processNotificationAction::notification  =  2")
        
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        let idPushNotification = userInfo["idPushNotification"] as? String
        
        vibrationService.stopContinuousVibration()
        
        
        // Cria um dicionário para armazenar todos os dados
        var dataDict: [String: Any] = [
            "actionIdentifier": actionIdentifier,
            "idPushNotification": idPushNotification ?? "",
        ]
        
        // Adiciona todos os elementos do userInfo ao dataDict
        for (
            key,
            value
        ) in userInfo {
            dataDict[key as! String] = value
        }
        
        if actionIdentifier == "REJECT_ACTION", let textResponse = response as? UNTextInputNotificationResponse {
            let userText = textResponse.userText
            dataDict["reasonText"] = userText
        }
        
        
        // Notifica os listeners com o dicionário completo
        notifyListeners(
            notifyListenerAction,
            data: dataDict
        )
        print("\(tag.self) handleNotificationAction::notification  =  3", dataDict)
    }
    
    
    
    
    @objc func processNotification(_ notification: NSNotification) {
        let result = self.createNotificationResult(notification: notification)
        print("\(tag.self) processNotification::notification  =  1")

        guard let data = result["data"] as? [String: Any] else {return }
        
        print("\(tag.self) processNotification::notification  =  2")

        // Extrair e processar o campo alert
        var title = " "
        var body = " "
        var messageId = UUID().uuidString
   
        if let alertString = data["alert"] as? String,
           let alertData = convertToDictionary(
            text: alertString
           ) {
            if let alertTitle = alertData["title"] as? String {
                title = alertTitle
            }
            if let alertBody = alertData["body"] as? String {
                body = alertBody
            }
        }
        
        if let msgID = data["gcm.message_id"] as? String {
            messageId = msgID
        }
        
        
        print("\(tag.self) processNotification::notification =  3")
        

        
        triggerLocalNotification(
            title: title,
            body: body,
            idPushNotification: messageId,
            additionalData: data
        )
        

    }
    
    @objc private func stopVibrationOnNotificationsCleared() {
        vibrationService.stopContinuousVibration()
    }
   
    private func processSilentNotification(_ response: UNNotificationResponse) {
        print("\(tag.self) processSilentNotification::response  =  1")
        
        var userInfo = response.notification.request.content.userInfo
        let idPushNotification = userInfo["idPushNotification"] as? String
        
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            print("\(tag.self) ACCEPT_ACTION triggered")
            NotificationCenter.default.post(
                name: Notification.Name(
                    notificationButtonTapped
                ),
                object: response,
                userInfo:
                    [
                        "action": "ACCEPT",
                        "idPushNotification": idPushNotification ?? "",
                        "notification": response.notification
                    ]
            )
        case "REJECT_ACTION":
            print("\(tag.self) REJECT_ACTION triggered")
            if let textResponse = response as? UNTextInputNotificationResponse {
                let userText = textResponse.userText
                userInfo["reasonText"] = userText  // Adiciona o texto do usuário ao userInfo
                NotificationCenter.default.post(
                    name: Notification.Name(
                        notificationButtonTapped
                    ),
                    object: response,
                    userInfo: [
                        "action": "REJECT",
                        "idPushNotification": idPushNotification ?? "",
                        "notification": response.notification,
                        "reasonText": userText
                    ]
                )
            } else {
                print("\(tag.self) REJECT_ACTION triggered not text textResponse")
                NotificationCenter.default.post(
                    name: Notification.Name(
                        notificationButtonTapped
                    ),
                    object: response,
                    userInfo: [
                        "action": "REJECT",
                        "idPushNotification": idPushNotification ?? "",
                        "notification": response.notification,
                        "reasonText": ""
                    ]
                )
            }
            
        default:
            print("\(tag.self) Default action triggered")
            NotificationCenter.default.post(
                name: Notification.Name(
                    notificationButtonTapped
                ),
                object: response,
                userInfo:
                    [
                        "idPushNotification": idPushNotification ?? "",
                        "notification": response.notification
                    ]
            )
            break
        }
    }
    
    
    // Enviar notificação local
    private func triggerLocalNotification(
        title: String,
        body: String,
        idPushNotification: String,
        additionalData: [String: Any]
    ) {
    
        let pluginIsEnabled = isPluginEnabled()
        
        
        if pluginIsEnabled {
            vibrationService.stopContinuousVibration()
            vibrationService.startContinuousVibration()
        }
         
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "VISITOR_REQUEST"
        content.userInfo = additionalData
        
        if !pluginIsEnabled {
            if #available(iOS 15.2, *) {
                content.sound = .defaultRingtone
            } else {
                content.sound = .defaultCritical
            }
            
        }
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
        }
        
        content.userInfo["idPushNotification"] = idPushNotification
        
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: idPushNotification,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(
            request
        ) { error in
            if let error = error {
                self.vibrationService.stopContinuousVibration()
                print(
                    "Erro ao adicionar notificação: \(error)"
                )
            }
        }
    }
    
   
    public func removeNotificationByEid(_ eid: String, category: String) {
        let center = UNUserNotificationCenter.current()
        // Obter notificações pendentes
        center.getPendingNotificationRequests { pendingRequests in
            // Obter notificações entregues
            center.getDeliveredNotifications { deliveredNotifications in
                // Combinar as notificações pendentes e entregues
                let allNotifications = pendingRequests.map { $0.content } + deliveredNotifications.map { $0.request.content }
                
                // Filtrar notificações com o eid correspondente
                let notificationsToRemove = allNotifications.filter { content in
                    if let userInfo = content.userInfo as? [String: Any],
                       let notificationEid = userInfo["eid"] as? String,
                       notificationEid == eid {
                        return true
                    }
                    return false
                }.compactMap { content in
                    // Verificar se idPushNotification existe
                    return content.userInfo["idPushNotification"] as? String
                }
                
                // Remover notificações pendentes
                center.removePendingNotificationRequests(withIdentifiers: notificationsToRemove)
                // Remover notificações entregues
                center.removeDeliveredNotifications(withIdentifiers: notificationsToRemove)
                
                // Toast indicando que a notificação foi removida
                if !notificationsToRemove.isEmpty {
                    self.vibrationService.stopContinuousVibration()
                     
                     // DEBUG SHOW REMOVE NOTIFICATION
//                    DispatchQueue.main.async {
//                        self.showToast(message: "Notificação com eid \(eid) removida.")
//                    }
                     
                }
                
                // Verificar se todas as notificações da categoria específica foram removidas
                center.getPendingNotificationRequests { remainingPendingRequests in
                    center.getDeliveredNotifications { remainingDeliveredNotifications in
                        // Filtrar notificações restantes pela categoria especificada
                        let remainingNotifications = remainingPendingRequests.map { $0.content } + remainingDeliveredNotifications.map { $0.request.content }
                        let remainingNotificationsInCategory = remainingNotifications.filter { content in
                            content.categoryIdentifier == category
                        }
                        
                        if remainingNotificationsInCategory.isEmpty {
                            NotificationCenter.default.post(name: Notification.Name("NotificationsCleared"), object: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    
    func showToast(message: String) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        rootViewController.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    public func handleTokenReceived(token: String?) {
        var result = JSObject()
        result["token"] = token
        notifyListeners("tokenReceived", data: result, retainUntilConsumed: true)
    }
    
    public func handleNotificationReceived(notification: UNNotification) {
        print("\(tag.self) handleNotificationReceived")
        let notificationResult = self.createNotificationResult(notification: notification)
        var result = JSObject()
        result["notification"] = notificationResult
        notifyListeners("notificationReceived", data: result, retainUntilConsumed: true)
    }
    
    public  func handleRemoteNotificationReceived(notification: NSNotification) {
        print("\(tag.self) handleRemoteNotificationReceived")
        let notificationResult = self.createNotificationResult(notification: notification)
        var result = JSObject()
        result["notification"] = notificationResult
        notifyListeners("notificationReceived", data: result, retainUntilConsumed: true)
    }
    
  
    public  func createNotificationResult(notification: NSNotification) -> JSObject {
        var result = JSObject()
        result["data"] = JSTypes.coerceDictionaryToJSObject(notification.userInfo) ?? [:]
        return result
        
    }
    
    public  func createNotificationResult(notification: UNNotification) -> JSObject {
        var result = JSObject()
        result["body"] = notification.request.content.body
        result["data"] = JSTypes.coerceDictionaryToJSObject(notification.request.content.userInfo) ?? [:]
        result["id"] = notification.request.identifier
        result["subtitle"] = notification.request.content.subtitle
        result["title"] = notification.request.content.title
        return result
    }
    
    private func convertToDictionary(
        text: String
    ) -> [String: Any]? {
        if let data = text.data(
            using: .utf8
        ) {
            do {
                return try JSONSerialization.jsonObject(
                    with: data,
                    options: []
                ) as? [String: Any]
            } catch {
                print(
                    "Error converting string to dictionary: \(error)"
                )
            }
        }
        return nil
    }
    
    
    //    MARK: manager plugin
    @objc func enablePlugin(_ call: CAPPluginCall) {
        setPluginEnabled(enabled: true)
        call.resolve(
            [
                "value": implementation?.enablePlugin(
                    true
                )
            ]
        )
    }
    
    @objc func disablePlugin(_ call: CAPPluginCall) {
        setPluginEnabled(enabled: false)
        call.resolve(
            [
                "value": implementation?.disablePlugin(
                    false
                )
            ]
        )
    }
    
    @objc func isEnabled(_ call: CAPPluginCall) {
        isEnabledPlugin = isPluginEnabled()
        call.resolve(
            [
                "value": implementation?.isEnabled(isEnabledPlugin)
            ]
        )
    }
    
    @objc func stopContinuousVibration(
        _ call: CAPPluginCall
    ) {
        self.vibrationService.stopContinuousVibration()
        let value =  true
        call.resolve(
            [
                "value": implementation?.stopContinuousVibration(
                    value
                )
            ]
        )
    }
    
     @objc func getToken(_ call: CAPPluginCall) {
        implementation?.getToken(completion: { token, error in
            if let error = error {
                CAPLog.print("[", self.tag, "] ", error)
                call.reject(error.localizedDescription)
                return
            }
            var result = JSObject()
            result["token"] = token
            call.resolve(result)
        })
    }
    
    @objc func deleteToken(_ call: CAPPluginCall) {
        implementation?.deleteToken(completion: { error in
            if let error = error {
                CAPLog.print("[", self.tag, "] ", error)
                call.reject(error.localizedDescription)
                return
            }
            call.resolve()
        })
    }
    
    @objc private func didRegisterForRemoteNotifications(notification: NSNotification) {
        guard let deviceToken = notification.object as? Data else {
            return
        }
        print("\(tag.self) didRegisterForRemoteNotifications :deviceToken")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    @objc override public func requestPermissions(_ call: CAPPluginCall) {
        implementation?.requestPermissions(completion: { granted, error in
            if let error = error {
                CAPLog.print("[", self.tag, "] ", error)
                call.reject(error.localizedDescription)
                return
            }
            call.resolve(["receive": granted ? "granted" : "denied"])
        })
    }
    
    
    @objc override public func checkPermissions(_ call: CAPPluginCall) {
        implementation?.checkPermissions(completion: { permission in
            call.resolve([
                "receive": permission
            ])
        })
    }
    
    @objc public func isPluginEnabled() -> Bool {
        // Ler o valor do UserDefaults para a chave myPluginEnabledKey.
        let isEnabledPlugin = UserDefaults.standard.bool(forKey: myPluginEnabledKey)
        return isEnabledPlugin
    }
   
    
    private func setPluginEnabled(enabled: Bool) {
        isEnabledPlugin = enabled
        UserDefaults.standard.set(isEnabledPlugin, forKey: myPluginEnabledKey)
    }
}

extension NotifyPersistentPlugin: MessagingDelegate{
    // Processa interação com ao touch
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("\(tag.self) userNotificationCenter::didReceive  =  0")
        vibrationService.stopContinuousVibration()
        processSilentNotification(response)
        completionHandler()

    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0,*) {
            completionHandler([.list,.banner,.sound])
        } else {
            completionHandler([.badge,.sound])
        }
        print("\(tag.self) handleNotificationReceived willPresent")
        self.handleNotificationReceived(notification: notification)  
    }
    
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.handleTokenReceived(token: fcmToken)
    }
}
/*
 public func handleNotificationActionPerformed(response: UNNotificationResponse) {
     let notificationResult = self.createNotificationResult(notification: response.notification)
     var result = JSObject()
     result["notification"] = notificationResult
     if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
         result["actionId"] = "tap"
     } else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
         result["actionId"] = "dismiss"
     } else {
         result["actionId"] = response.actionIdentifier
     }
     if let inputType = response as? UNTextInputNotificationResponse {
         result["inputValue"] = inputType.userText
     }
     
     notifyListeners("notificationActionPerformed", data: result, retainUntilConsumed: true)
 }
 */
