import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(NotifyPersistentPlugin)
public class NotifyPersistentPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NotifyPersistentPlugin"
    public let jsName = "NotifyPersistent"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "echo", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = NotifyPersistent()

    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
}
