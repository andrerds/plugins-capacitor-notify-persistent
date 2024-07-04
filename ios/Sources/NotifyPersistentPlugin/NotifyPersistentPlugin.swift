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
public class NotifyPersistentPlugin: CAPPlugin, CAPBridgedPlugin, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    public let identifier = "NotifyPersistentPlugin"
    public let jsName = "NotifyPersistent"
    public let tag = "NotifyPersistentPlugin"
    
    public let notifyListenerReceived = "notificationReceived"
    public let notifyListenerAction = "notificationActionPerformed"
    public let didReceiveRemoteNotificationName = "didReceiveRemoteNotification"
    public let notificationButtonTapped = "notificationButtonTapped"
    
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
    ]
    
    private let implementation = NotifyPersistent()
    let vibrationService = NotifyPersistentVibrationService.shared
    
    let myPluginEnabledKey = "NotifyPersistentPluginEnabled"  // Definindo a constante para a chave de UserDefaults
    // Padrão é false
    var isEnabled: Bool = false
    
    override public func load() {
        super.load()
        isEnabled = checkPluginIsEnabled()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        setActions()

        // MARK:     Observers
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveRemoteNotification(notification:)),
                                               name: Notification.Name(didReceiveRemoteNotificationName.self),
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleNotificationAction(notification:)),
                                               name: Notification.Name(notificationButtonTapped),
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleNotificationsCleared),
                                               name: Notification.Name("NotificationsCleared"),
                                               object: nil)
        
    }
    
    
    //    MARK: DESTROY
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc public func setActions(){
        // Definir as ações e a categoria
        // Tradução
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
        let isEnabled = checkPluginIsEnabled()
        var isSilentNotification: Bool = false
        
        if let userInfo = notification.userInfo {
            print("\(tag.self) didReceiveRemoteNotification:: =  1", userInfo)
            if let aps = userInfo["aps"] as? [String: Any], let contentAvailable = aps["content-available"] as? Int {
                if contentAvailable == 1 {
                    isSilentNotification = true
                }
            }
            
            if isEnabled && isSilentNotification {
              
                
                if isSilentNotification {
                    if let type = userInfo["type"] as? String, type != "NEED_APPROVAL" || userInfo["type"] == nil,
                       let eid = userInfo["eid"] as? String {
                        self.removeNotificationByEid(eid, category: categoryLocalNotificationName.self)
                    } else {
                        handleNotification(notification)
                    }
                }
                
            } else {
                print("\(tag.self) didReceiveRemoteNotification")
                if let userInfo = notification.userInfo {
                    Messaging.messaging().appDidReceiveMessage(userInfo)
                }
                self.handleRemoteNotificationReceived(notification: notification)
            }
            
        }
    }
    
    
    @objc func handleNotificationAction(notification: NSNotification) {
        guard let response = notification.object as? UNNotificationResponse else {
            return
        }
        
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        let idPushNotification = userInfo["idPushNotification"] as? String
        
        if actionIdentifier == "ACCEPT_ACTION" || actionIdentifier == "REJECT_ACTION" {
            vibrationService.stopContinuousVibration()
        }
        
        
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
    }
    
    @objc func handleNotification(_ notification: NSNotification) {
        let result = self.createNotificationResult(notification: notification)
        guard let data = result["data"] as? [String: Any] else {return }
        
        // Extrair e processar o campo alert
        var title = " "
        var body = " "
        var messageId = UUID().uuidString
        
        var isSilentNotification = false
        
        if let aps = data["aps"] as? [String: Any], let contentAvailable = aps["content-available"] as? Int {
            isSilentNotification = contentAvailable == 1
        }
        
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
        
        
        print("\(tag.self) handleNotification:: =  2")
        
        if isSilentNotification {
            // Start Continuous Vibration and sound
            if isEnabled {
                sendLocalNotification(
                    title: title,
                    body: body,
                    idPushNotification: messageId,
                    additionalData: data
                )
                notifyListeners(
                    notifyListenerReceived,
                    data: [
                        "idPushNotification": messageId,
                        "notification": data
                    ]
                )
            }
        } else{
            print("\(tag.self) handleNotification::Not isSilentNotification =  3")
        }
    }
    
    @objc private func handleNotificationsCleared() {
        vibrationService.stopContinuousVibration()
    }
    
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler:
                                       @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0,*) {
            completionHandler(
                [
                    .list,
                    .banner,
                    .sound
                ]
            )
        } else {
            completionHandler(
                [
                    .badge,
                    .sound
                ]
            )
        }
        print("\(tag.self) handleNotificationReceived willPresent")
        self.handleNotificationReceived(notification: notification)
    }
    
    // Processa interação com ao touch
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
        ) {
        print("\(tag.self) userNotificationCenter::didReceive  =  0")
        vibrationService.stopContinuousVibration()
        
        var isSilentNotification = false
        let data =  response.notification.request.content.userInfo;
        
        if let aps = data["aps"] as? [String: Any], let contentAvailable = aps["content-available"] as? Int {
            if(contentAvailable == 1){
                isSilentNotification = true
            }
        }
        
        if isSilentNotification {
            print("\(tag.self) userNotificationCenter::didReceive::isSilentNotification  =  1")
           handleNotificationSilent(response)
        } else {
            print("\(tag.self) userNotificationCenter::didReceive::Not::isSilentNotification  =  1")
            handleNotificationActionPerformed(response: response)
        }
        
        completionHandler()
    }
    
    
    private func handleNotificationSilent(_ response: UNNotificationResponse) {
        
        var userInfo = response.notification.request.content.userInfo
        let idPushNotification = userInfo["idPushNotification"] as? String
        
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            print("ACCEPT_ACTION triggered")
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
            print("REJECT_ACTION triggered")
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
            print(
                "Default action triggered"
            )
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
    
    
    func handleNotificationActionPerformed(response: UNNotificationResponse) {
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
    
    // Enviar notificação local
    private func sendLocalNotification(
        title: String,
        body: String,
        idPushNotification: String,
        additionalData: [String: Any]
    ) {
        vibrationService.stopContinuousVibration()
        vibrationService.startContinuousVibration()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "VISITOR_REQUEST"
        content.userInfo = additionalData
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
                   /*
                // DEBUG SHOW REMOVE NOTIFICATION
                    DispatchQueue.main.async {
                        self.showToast(message: "Notificação com eid \(eid) removida.")
                    }
                */
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
    
    
    /*
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
     }.map { content in
     // Verificar se idPushNotification existe, se não adicionar uma string vazia
     return (content.userInfo["idPushNotification"] as? String) ?? ""
     }
     
     // Remover notificações pendentes
     center.removePendingNotificationRequests(withIdentifiers: notificationsToRemove)
     // Remover notificações entregues
     center.removeDeliveredNotifications(withIdentifiers: notificationsToRemove)
     
     
     // toast indicando que a notificação foi removida
     if !notificationsToRemove.isEmpty {
     self.vibrationService.stopContinuousVibration()
     DispatchQueue.main.async {
     self.showToast(message: "Notificação com eid \(eid) removida.")
     }
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
     } */
    
    
    
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
    
    
    //    MARK: manager plugin
    @objc func enablePlugin(
        _ call: CAPPluginCall
    ) {
        isEnabled = true
        UserDefaults.standard.set(
            isEnabled,
            forKey: myPluginEnabledKey
        )
        let value =  isEnabled
        call.resolve(
            [
                "value": implementation.enablePlugin(
                    value
                )
            ]
        )
    }
    
    @objc func disablePlugin(
        _ call: CAPPluginCall
    ) {
        isEnabled = false
        UserDefaults.standard.set(
            isEnabled,
            forKey: myPluginEnabledKey
        )
        let value =  isEnabled
        call.resolve(
            [
                "value": implementation.disablePlugin(
                    value
                )
            ]
        )
    }
    
    @objc func isEnabled(
        _ call: CAPPluginCall
    ) {
        isEnabled = UserDefaults.standard.bool(
            forKey: myPluginEnabledKey
        )
        let value = isEnabled
        call.resolve(
            [
                "value": implementation.isEnabled(
                    value
                )
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
                "value": implementation.stopContinuousVibration(
                    value
                )
            ]
        )
    }
    
    
    /// Verifica se o plugin está habilitado.
    ///
    /// Essa função verifica se o plugin está habilitado
    /// lendo o valor do `UserDefaults` para a chave `myPluginEnabledKey`.
    ///
    /// - Returns: Um valor booleano que indica se o plugin está habilitado
    ///            ou não.
    @objc public func checkPluginIsEnabled() -> Bool {
        // Ler o valor do `UserDefaults` para a chave `myPluginEnabledKey`.
        let isEnabled = UserDefaults.standard.bool(
            forKey: myPluginEnabledKey
        )
        return isEnabled
    }
    
    
    private func handleNotificationReceived(notification: UNNotification) {
        print("\(tag.self) handleNotificationReceived")
        let notificationResult = self.createNotificationResult(notification: notification)
        var result = JSObject()
        result["notification"] = notificationResult
        notifyListeners("notificationReceived", data: result, retainUntilConsumed: true)
    }
    
    private  func handleRemoteNotificationReceived(notification: NSNotification) {
        print("\(tag.self) handleRemoteNotificationReceived")
        let notificationResult = self.createNotificationResult(notification: notification)
        var result = JSObject()
        result["notification"] = notificationResult
        notifyListeners("notificationReceived", data: result, retainUntilConsumed: true)
    }
}

