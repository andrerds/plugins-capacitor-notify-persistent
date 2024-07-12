import Foundation
import FirebaseCore
import FirebaseMessaging
import UserNotifications


@objc public class NotifyPersistent: NSObject {
    private let plugin: NotifyPersistentPlugin
    private let config: NotifyPersistentConfig

    init(plugin: NotifyPersistentPlugin, config: NotifyPersistentConfig) {
        self.plugin = plugin
        self.config = config
        super.init()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
    }
    
    @objc public func enablePlugin(_ value: Bool) -> Bool {
        print("enablePlugin", value)
        return value
    }
    @objc public func disablePlugin(_ value: Bool) -> Bool {
        print("disablePlugin", value)
        return value
    }
    
    @objc public func stopContinuousVibration(_ value: Bool) -> Bool {
        print(value)
        return value
    }
    
    @objc public func isEnabled(_ value: Bool) -> Bool {
        print("isEnable", value)
        return value
    }
    
    
    @objc public func handleNotificationResponse(_ value: Any) -> Any {
        print("handleNotificationResponse", value)
        return value
    }
    
    
    public func requestPermissions(completion: @escaping (_ granted: Bool, _ error: Error?) -> Void) {
         var options = UNAuthorizationOptions()
         self.config.presentationOptions.forEach { option in
             switch option {
             case "alert":
                 options.insert(.alert)
             case "badge":
                 options.insert(.badge)
             case "sound":
                 options.insert(.sound)
             case "criticalAlert":
                 options.insert(.criticalAlert)
             default:
                 print("Unrecogizned authorization option: \(option)")
             }
         }
         UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
             completion(granted, error)
         }
          
    }
    
    public func checkPermissions(completion: @escaping (_ status: String) -> Void) {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let permission: String
            
            switch settings.authorizationStatus {
            case .authorized, .ephemeral, .provisional:
                permission = "granted"
            case .denied:
                permission = "denied"
            case .notDetermined:
                permission = "prompt"
            @unknown default:
                permission = "prompt"
            }
            
            completion(permission)
        }
         
    }

    public func getToken(completion: @escaping (String?, Error?) -> Void) {
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().token(completion: { result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(result, nil)
        })
    }

    public func deleteToken(completion: @escaping (Error?) -> Void) {
        Messaging.messaging().deleteToken(completion: { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        })
    }

}
 
