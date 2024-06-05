import Foundation
import FirebaseCore
import FirebaseMessaging
import UserNotifications


@objc public class NotifyPersistent: NSObject {
 
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
    
}
 
