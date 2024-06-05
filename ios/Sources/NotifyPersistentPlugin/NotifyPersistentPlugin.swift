import Foundation
import FirebaseMessaging
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

@objc(NotifyPersistentPlugin)
public class NotifyPersistentPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NotifyPersistentPlugin"
    public let jsName = "NotifyPersistent"
    public let tag = "NotifyPersistentPlugin"
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRegisterForRemoteNotifications(notification:)), name: .capacitorDidRegisterForRemoteNotifications, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveRemoteNotification(notification:)), name: Notification.Name.init("didReceiveRemoteNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.willPresent(notification:)), name: Notification.Name("willPresent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotificationAction(notification:)), name: Notification.Name("didReceiveNotificationResponse"), object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleNotificationAction(notification: NSNotification) {
        
        print("handleNotificationAction::53", notification)
        guard let response = notification.object as? UNNotificationResponse else {
            return
        }

        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo

        // Parar a vibração ao clicar na ação
        if actionIdentifier == "ACCEPT_ACTION" || actionIdentifier == "REJECT_ACTION" {
            print(" action identifier", actionIdentifier)
            vibrationService.stopContinuousVibration()
        }

        // Notificar o app sobre a ação da notificação
        notifyListeners("notificationAction", data: [
            "actionIdentifier": actionIdentifier,
            "userInfo": userInfo
        ])
    }
    
    
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
    
    @objc public func didReceiveRemoteNotificationProcess(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        handleNotification(userInfo)
    }
    
    
    @objc public func setActions(){
        // Definir as ações e a categoria
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Aceitar", options: [.foreground])
        let rejectAction = UNNotificationAction(identifier: "REJECT_ACTION", title: "Recusar", options: [.destructive])
        let category = UNNotificationCategory(identifier: "VISITOR_REQUEST", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    
    @objc func handleNotification(_ message: [String: Any]) {
        let extractedData = handleNotificationPayload(message)
        var titleExtracted = ""
        var bodyExtracted = ""
        var gcmMessageIDExtracted  = ""
        var silientExtracted  = false
        
        
        if let silient = extractedData["silient"] as? Bool {
            silientExtracted = silient
        }
        
        if let title = extractedData["title"] as? String, let body = extractedData["body"] as? String {
            titleExtracted = title
            bodyExtracted = body
        }
        
        if let gcmMessageID = extractedData["gcmMessageID"] as? String {
            gcmMessageIDExtracted = gcmMessageID
        }
        
        if let openApp = extractedData["openApp"] as? Bool {
            print("Open App: \(openApp)")
        }
        
        notifyListeners("notificationReceived", data: [
                  "title": titleExtracted,
                  "body": bodyExtracted,
                  "gcmMessageID": gcmMessageIDExtracted,
                  "silient": silientExtracted
         ])
        
        sendLocalNotification(title: titleExtracted, body: bodyExtracted, idPushNotification: gcmMessageIDExtracted)
        
        if isEnabled && silientExtracted {
            print("aqui tocar som e vibrar")
            stopVibrateFromNotification()
            vibrateFromNotification()
        }
        
    }
    
    
    @objc public func checkPluginIsEnabled() -> Bool{
        isEnabled = UserDefaults.standard.bool(forKey: myPluginEnabledKey)
        return isEnabled
    }
    
  
    
    @objc func willPresent(notification: NSNotification) {
           guard let userInfo = notification.userInfo as? [String: Any] else {
               return
           }
           print("Notification will present:: 180", userInfo)
    }
    
    @objc func vibrateFromNotification() {
         vibrationService.startContinuousVibration()
    }
    
    @objc func stopVibrateFromNotification() {
         vibrationService.stopContinuousVibration()
    }
    
    @objc private func didRegisterForRemoteNotifications(notification: NSNotification) {
        guard let deviceToken = notification.object as? Data else {
            return
        }
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
    @objc private func didReceiveRemoteNotification(notification: NSNotification) {
        didReceiveRemoteNotificationProcess(notification as Notification)
    }
    
    
    public func removeDeliveredNotifications(ids: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
    }
    
    public func getDeliveredNotifications(completion: @escaping ([UNNotification]) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            completion(notifications)
        }
    }
    
    private  func sendLocalNotification(title: String, body: String, idPushNotification: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = "VISITOR_REQUEST"
     
        // Adicionando botões de texto diretamente no corpo da notificação
        content.userInfo = ["ACCEPT_ACTION": "ACCEPT_ACTION", "REJECT_ACTION": "REJECT_ACTION"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        // uuid UUID().uuidString
        let request = UNNotificationRequest(identifier: idPushNotification, content: content, trigger: trigger)
    
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.vibrationService.stopContinuousVibration()
                print("Erro ao adicionar notificação: \(error)")
            }
        }
    }
    
    private func handleNotificationPayload(_ userInfo: [AnyHashable: Any]) -> [String: Any] {
        var extractedData: [String: Any] = [:]
        
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            if let alert = aps["alert"] as? [String: AnyObject] {
                let title = alert["title"] as? String ?? ""
                let body = alert["body"] as? String ?? ""
                extractedData["title"] = title
                extractedData["body"] = body
            }
            if let silient = aps["silient"] as? Bool {
                extractedData["silient"] = silient
            }
        }
        
        if let gcmMessageID = userInfo["gcm.message_id"] as? String {
            extractedData["gcmMessageID"] = gcmMessageID
        }
        
        // Outras extrações de dados conforme necessário
        if let openApp = userInfo["openApp"] as? Bool {
            extractedData["openApp"] = openApp
        }
        
        return extractedData
    }
}
