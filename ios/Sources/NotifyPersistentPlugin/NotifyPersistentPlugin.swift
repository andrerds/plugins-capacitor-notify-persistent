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
    public let didReceiveRemoteNotificationName = "didReceiveRemoteNotificationNotifyPersistentPlugin"
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "isEnabled", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "enablePlugin", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "disablePlugin", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopContinuousVibration", returnType: CAPPluginReturnPromise),
    ]
    
    let myPluginEnabledKey = "NotifyPersistentPluginEnabled"  // Definindo a constante para a chave de UserDefaults
    private let implementation = NotifyPersistent()
    public let notificationReceivedEvent = "notificationReceived"
    let vibrationService = NotifyPersistentVibrationService.shared
    
    // Padrão é false
    var isEnabled: Bool = false
    
    override public func load() {
        super.load()
        isEnabled = UserDefaults.standard.bool(forKey: myPluginEnabledKey)
        setActions()
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveRemoteNotification(notification:)), name: Notification.Name(didReceiveRemoteNotificationName.self), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotificationAction(notification:)), name: Notification.Name("notificationButtonTapped"), object: nil)
        
        UNUserNotificationCenter.current().delegate = self // Definir o delegate
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveRemoteNotification(notification:)), name: Notification.Name.init(didReceiveRemoteNotificationName.self), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotificationAction(notification:)), name: Notification.Name("notificationButtonTapped"), object: nil)
        print("NotifyPersistentPlugin loaded and delegate set")
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
     
    @objc public func setActions(){
        // Definir as ações e a categoria
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Aceitar", options: [.foreground])
        let rejectAction = UNNotificationAction(identifier: "REJECT_ACTION", title: "Recusar", options: [.destructive])
        let category = UNNotificationCategory(identifier: "VISITOR_REQUEST", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
      
    @objc public func didReceiveRemoteNotificationProcess(_ notification: NSNotification) {
           guard let userInfo = notification.userInfo as? [String: Any] else {
               return
           }
           print("\(NotifyPersistentPlugin.self) plugin:::didReceiveRemoteNotificationProcess", userInfo)
           handleNotification(notification)
       }

       @objc private func didReceiveRemoteNotification(notification: NSNotification) {
           if let userInfo = notification.userInfo {
               didReceiveRemoteNotificationProcess(notification)
           }
       }

       @objc func handleNotificationAction(notification: NSNotification) {
           guard let response = notification.object as? UNNotificationResponse else {
               return
           }
           let actionIdentifier = response.actionIdentifier
           let userInfo = response.notification.request.content.userInfo
           let idPushNotification = userInfo["idPushNotification"] as? String

           print("handleNotificationAction: Action - \(actionIdentifier), ID - \(idPushNotification ?? "No ID")")

           if actionIdentifier == "ACCEPT_ACTION" || actionIdentifier == "REJECT_ACTION" {
               vibrationService.stopContinuousVibration()
           }

           notifyListeners("notificationAction", data: [
               "actionIdentifier": actionIdentifier,
               "idPushNotification": idPushNotification ?? "",
               "data": userInfo
           ])
       }
    
    @objc func handleNotification(_ notification: NSNotification) {
        let result = self.createNotificationResult(notification: notification)
        print("\(tag.self) handleNotification::result:::", result)
        
        var title = "testw"
        var body =  "tesew kkk"
        var messageId = "887"
        var isSilencNotification = false;
        sendLocalNotification(title: title, body: body, idPushNotification: messageId)
        
        if isEnabled {
            print("aqui tocar som e vibrar")
            stopVibrateFromNotification()
            vibrateFromNotification()
        }
    }
    

       // Implementar UNUserNotificationCenterDelegate para receber notificações
       public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           if #available(iOS 14.0, *) {
               completionHandler([.list, .banner, .sound])
           } else {
               completionHandler([.badge, .sound])
           }
       }

       // Processa resposta à notificação
       public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
           vibrationService.stopContinuousVibration()
           print("userNotificationCenter didReceive response")
           
           let userInfo = response.notification.request.content.userInfo
           let idPushNotification = userInfo["idPushNotification"] as? String

           print("Notification ID:", idPushNotification ?? "No ID")

           switch response.actionIdentifier {
           case "ACCEPT_ACTION":
               print("ACCEPT_ACTION triggered")
               NotificationCenter.default.post(name: Notification.Name("notificationButtonTapped"), object: response, userInfo: ["action": "ACCEPT", "idPushNotification": idPushNotification ?? ""])
           case "REJECT_ACTION":
               print("REJECT_ACTION triggered")
               NotificationCenter.default.post(name: Notification.Name("notificationButtonTapped"), object: response, userInfo: ["action": "REJECT", "idPushNotification": idPushNotification ?? ""])
           default:
               print("Default action triggered")
               break
           }

           completionHandler()
       }

       // Enviar notificação local
       private func sendLocalNotification(title: String, body: String, idPushNotification: String) {
           vibrationService.stopContinuousVibration()
           vibrationService.startContinuousVibration()
           let content = UNMutableNotificationContent()
           content.title = title
           content.body = body
           content.categoryIdentifier = "VISITOR_REQUEST"
           content.userInfo = ["idPushNotification": idPushNotification]

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
    
    
    @objc func vibrateFromNotification() {
        vibrationService.startContinuousVibration()
    }
    
    @objc func stopVibrateFromNotification() {
        vibrationService.stopContinuousVibration()
    }
    
}




