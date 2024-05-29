import Foundation

@objc public class NotifyPersistent: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
