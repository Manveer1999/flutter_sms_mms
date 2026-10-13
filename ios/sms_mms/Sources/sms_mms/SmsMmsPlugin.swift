import Flutter
import MessageUI
import MobileCoreServices
import UIKit
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

public class SmsMmsPlugin: NSObject, FlutterPlugin, MFMessageComposeViewControllerDelegate {
    private var pendingResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sms_mms", binaryMessenger: registrar.messenger())
        let instance = SmsMmsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "sendMms":
            sendMms(arguments: call.arguments as? [String: Any] ?? [:], result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func sendMms(arguments: [String: Any], result: @escaping FlutterResult) {
        #if targetEnvironment(simulator)
        result(FlutterError(
            code: "message_not_sent",
            message: "Cannot send message on this device!",
            details: "Cannot send SMS and MMS on a Simulator. Test on a real device."
        ))
        #else
        let paths = arguments["paths"] as? [String] ?? []

        // Attachment support is only needed when there is something to attach.
        guard MFMessageComposeViewController.canSendText(),
              paths.isEmpty || MFMessageComposeViewController.canSendAttachments() else {
            result(FlutterError(
                code: "device_not_capable",
                message: "The current device is not capable of sending this message.",
                details: "A device may be unable to send messages if it does not support messaging or if it is not currently configured to send messages. This only applies to the ability to send text messages via iMessage, SMS, and MMS."
            ))
            return
        }

        if pendingResult != nil {
            result(FlutterError(
                code: "already_open",
                message: "A message compose sheet is already open.",
                details: nil
            ))
            return
        }

        guard let presenter = topViewController() else {
            result(FlutterError(
                code: "no_view_controller",
                message: "No view controller is available to present the compose sheet.",
                details: nil
            ))
            return
        }

        let controller = MFMessageComposeViewController()
        controller.body = arguments["message"] as? String
        controller.recipients = arguments["recipientNumbers"] as? [String]
        controller.messageComposeDelegate = self

        for path in paths {
            let url = URL(fileURLWithPath: path)
            guard FileManager.default.isReadableFile(atPath: path),
                  controller.addAttachmentURL(url, withAlternateFilename: url.lastPathComponent) else {
                result(FlutterError(
                    code: "file_not_found",
                    message: "Attachment could not be added: \(path)",
                    details: "The file is missing, unreadable, or of type \(typeIdentifier(for: url)), which Messages does not accept."
                ))
                return
            }
        }

        pendingResult = result
        presenter.present(controller, animated: true)
        #endif
    }

    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        let status: String
        switch result {
        case .sent: status = "sent"
        case .cancelled: status = "cancelled"
        case .failed: status = "failed"
        @unknown default: status = "unknown"
        }
        controller.dismiss(animated: true)
        pendingResult?(status)
        pendingResult = nil
    }

    /// The uniform type identifier for a file, from its extension. Used in error details only.
    private func typeIdentifier(for url: URL) -> String {
        if #available(iOS 14.0, *) {
            return UTType(filenameExtension: url.pathExtension)?.identifier ?? "public.data"
        }
        let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)
        return uti?.takeRetainedValue() as String? ?? "public.data"
    }

    private func topViewController() -> UIViewController? {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
