import Foundation
import FirebaseMessaging
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

@objc(NotifyPersistentPlugin)
public class NotifyPersistentPlugin: CAPPlugin, CAPBridgedPlugin, UNUserNotificationCenterDelegate {
    
    public let identifier = "NotifyPersistentPlugin"
    public let jsName = "NotifyPersistent"
    public let tag = "NotifyPersistentPlugin"
    
    public let notifyListenerReceived = "notificationReceivedNotifyPersistentPlugin"
    public let notifyListenerAction = "notificationActionNotifyPersistentPlugin"
    public let didReceiveRemoteNotificationName = "didReceiveRemoteNotificationNotifyPersistentPlugin"
    public let notificationButtonTapped = "notificationButtonTapped"
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "isEnabled", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "enablePlugin", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "disablePlugin", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopContinuousVibration", returnType: CAPPluginReturnPromise),
    ]
    
    let myPluginEnabledKey = "NotifyPersistentPluginEnabled"  // Definindo a constante para a chave de UserDefaults
    private let implementation = NotifyPersistent()
    let vibrationService = NotifyPersistentVibrationService.shared
    
    // Padrão é false
    var isEnabled: Bool = false
    
    override public func load() {
        super.load()
        isEnabled = UserDefaults.standard.bool(forKey: myPluginEnabledKey)
        setActions()
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveRemoteNotification(notification:)), name: Notification.Name(didReceiveRemoteNotificationName.self), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotificationAction(notification:)), name: Notification.Name(notificationButtonTapped), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc public func setActions(){
        // Definir as ações e a categoria
        let acceptActionTitle = NSLocalizedString("ACCEPT_ACTION_TITLE", comment: "Title for Accept action")
        let rejectActionTitle = NSLocalizedString("REJECT_ACTION_TITLE", comment: "Title for Reject action")
        
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: acceptActionTitle, options: [.foreground])
//        let rejectAction = UNNotificationAction(identifier: "REJECT_ACTION", title: rejectActionTitle, options: [.destructive])
        let rejectAction = UNTextInputNotificationAction(identifier: "REJECT_ACTION", title: rejectActionTitle, options: [.destructive], 
                                                         textInputButtonTitle: NSLocalizedString("SEND", comment: "Button title for sending input"),
                                                         textInputPlaceholder: NSLocalizedString("Enter reason", comment: "Placeholder for input field"))

        
        let category = UNNotificationCategory(identifier: "VISITOR_REQUEST", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    @objc private func didReceiveRemoteNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            didReceiveRemoteNotificationProcess(notification)
            print("\(tag.self) notification::userInfo \(userInfo)")
        }
    }
    
    @objc public func didReceiveRemoteNotificationProcess(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        print("\(tag.self) didReceiveRemoteNotificationProcess::userInfo \(userInfo)")
        handleNotification(notification)
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
            "idPushNotification": idPushNotification ?? ""
        ]
        
        // Adiciona todos os elementos do userInfo ao dataDict
        for (key, value) in userInfo {
            dataDict[key as! String] = value
        }
        
        // Notifica os listeners com o dicionário completo
        notifyListeners(notifyListenerAction, data: dataDict)
    }
    
    @objc func handleNotification(_ notification: NSNotification) {
        let result = self.createNotificationResult(notification: notification)
        guard let data = result["data"] as? [String: Any] else {
            print("\(tag.self) handleNotification:: No data found in notification")
            return
        }
        
        // Extrair e processar o campo alert
        var title = " "
        var body = " "
        var messageId = UUID().uuidString
        
        var isSilentNotification = false
        
        if let aps = data["aps"] as? [String: Any], let contentAvailable = aps["content-available"] as? Int {
            isSilentNotification = contentAvailable == 1
        }
        
        if let alertString = data["alert"] as? String,
           let alertData = convertToDictionary(text: alertString) {
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
        
        if isSilentNotification {
            // Start Continuous Vibration and sound
            if isEnabled {
                sendLocalNotification(title: title, body: body, idPushNotification: messageId, additionalData: data)
                notifyListeners(notifyListenerReceived, data: [
                    "idPushNotification": messageId,
                    "notification": data
                ])
            }
        }
    }
    
    
     public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.list, .banner, .sound])
        } else {
            completionHandler([.badge, .sound])
        }
    }
    
    // Processa interação com ao touch
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        vibrationService.stopContinuousVibration()
        var isSilentNotification = false
        let data =  response.notification.request.content.userInfo;
        
        if let aps = data["aps"] as? [String: Any], let contentAvailable = aps["content-available"] as? Int {
            if(contentAvailable == 1){
                isSilentNotification = true
            }
        }
        
        let userInfo = response.notification.request.content.userInfo
        let idPushNotification = userInfo["idPushNotification"] as? String
        
        if(isSilentNotification){
            switch response.actionIdentifier {
            case "ACCEPT_ACTION":
                print("ACCEPT_ACTION triggered")
                NotificationCenter.default.post(name: Notification.Name(notificationButtonTapped), object: response, userInfo:
                                                    [
                                                        "action": "ACCEPT",
                                                        "idPushNotification": idPushNotification ?? "",
                                                        "notification": response.notification
                                                    ]
                )
            case "REJECT_ACTION":
                print("REJECT_ACTION triggered")
                NotificationCenter.default.post(name: Notification.Name(notificationButtonTapped), object: response, userInfo:
                                                    [
                                                        "action": "REJECT",
                                                        "idPushNotification": idPushNotification ?? "",
                                                        "notification": response.notification
                                                    ])
                
                let response = response as? UNTextInputNotificationResponse
                let userText = response?.userText ?? ""
                handleRejectAction(with: userInfo, with: userText)
                
                
            default:
                print("Default action triggered")
                NotificationCenter.default.post(name: Notification.Name(notificationButtonTapped), object: response, userInfo:
                                                    [
                                                        "idPushNotification": idPushNotification ?? "",
                                                        "notification": response.notification
                                                    ])
                break
            }
        }
        completionHandler()
    }
    
    // Enviar notificação local
    private func sendLocalNotification(title: String, body: String, idPushNotification: String, additionalData: [String: Any]) {
        vibrationService.stopContinuousVibration()
        vibrationService.startContinuousVibration()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "VISITOR_REQUEST"
        content.userInfo = additionalData
        content.userInfo["idPushNotification"] = idPushNotification
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: idPushNotification, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.vibrationService.stopContinuousVibration()
                print("Erro ao adicionar notificação: \(error)")
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
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print("Error converting string to dictionary: \(error)")
            }
        }
        return nil
    }
  
    private func handleRejectAction(with notification: [AnyHashable : Any], with text: String) {
        if let url = URL(string: "keyaccess://reject?reason=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    //    MARK: manager plugin
    @objc func enablePlugin(_ call: CAPPluginCall) {
        isEnabled = true
        UserDefaults.standard.set(isEnabled, forKey: myPluginEnabledKey)
        let value =  isEnabled
        call.resolve([
            "value": implementation.enablePlugin(value)
        ])
    }
    
    @objc func disablePlugin(_ call: CAPPluginCall) {
        isEnabled = false
        UserDefaults.standard.set(isEnabled, forKey: myPluginEnabledKey)
        let value =  isEnabled
        call.resolve([
            "value": implementation.disablePlugin(value)
        ])
    }
    
    @objc func isEnabled(_ call: CAPPluginCall) {
        isEnabled = UserDefaults.standard.bool(forKey: myPluginEnabledKey)
        let value = isEnabled
        call.resolve([
            "value": implementation.isEnabled(value)
        ])
    }
    
    @objc func stopContinuousVibration(_ call: CAPPluginCall) {
        self.vibrationService.stopContinuousVibration()
        let value =  true
        call.resolve([
            "value": implementation.stopContinuousVibration(value)
        ])
    }
    
    
    @objc public func checkPluginIsEnabled() -> Bool{
        isEnabled = UserDefaults.standard.bool(forKey: myPluginEnabledKey)
        return isEnabled
    }
    
}

