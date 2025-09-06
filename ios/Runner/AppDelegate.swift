import UIKit
import Flutter
import ZIPFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Access FlutterEngine instead of rootViewController directly
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        let channel = FlutterMethodChannel(
            name: "example.startAccessingToSharedStorage",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "saveSharedFolder":
                guard let args = call.arguments as? [String: Any],
                      let urlString = args["url"] as? String,
                      let folderUrl = URL(string: urlString) else {
                    result(FlutterError(code: "INVALID_ARGS",
                                        message: "No valid URL provided",
                                        details: nil))
                    return
                }
                do {
                    try self?.persistAccessToFolder(url: folderUrl)
                    result(["success": true])
                } catch {
                    result(FlutterError(code: "BOOKMARK_ERROR",
                                        message: error.localizedDescription,
                                        details: nil))
                }
                
            case "getWritableFilePath":
                self?.getWritableFilePath(result: result, call: call)
                
            case "extractIpaAtPath":
                guard let args = call.arguments as? [String: Any],
                      let ipaPath = args["ipaPath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS",
                                        message: "ipaPath required",
                                        details: nil))
                    return
                }
                self?.extractIpa(at: ipaPath, result: result)
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Save bookmark (iOS-compatible, no withSecurityScope)
    private func persistAccessToFolder(url: URL) throws {
        let bookmarkData = try url.bookmarkData(options: [],
                                                includingResourceValuesForKeys: nil,
                                                relativeTo: nil)
        UserDefaults.standard.set(bookmarkData, forKey: "SharedFolderBookmark")
    }
    
    // MARK: - Restore bookmark
    private func restoreSharedFolder() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: "SharedFolderBookmark") else {
            return nil
        }
        
        var isStale = false
        do {
            let restoredUrl = try URL(resolvingBookmarkData: bookmarkData,
                                      options: [],
                                      relativeTo: nil,
                                      bookmarkDataIsStale: &isStale)
            if isStale {
                print("Bookmark is stale, user must pick folder again")
                return nil
            }
            return restoredUrl
        } catch {
            print("Error restoring bookmark: \(error)")
            return nil
        }
    }
    
    // MARK: - Provide writable file path
    private func getWritableFilePath(result: @escaping FlutterResult, call: FlutterMethodCall) {
        guard let args = call.arguments as? [String: Any],
              let fileName = args["fileName"] as? String,
              let folderUrl = restoreSharedFolder() else {
            result(FlutterError(code: "NO_FOLDER",
                                message: "No saved folder found or stale",
                                details: nil))
            return
        }
        
        if folderUrl.startAccessingSecurityScopedResource() {
            defer { folderUrl.stopAccessingSecurityScopedResource() }
            let fileUrl = folderUrl.appendingPathComponent(fileName)
            result(fileUrl.path)
        } else {
            result(FlutterError(code: "ACCESS_DENIED",
                                message: "Could not access folder",
                                details: nil))
        }
    }
    
    // MARK: - Extract IPA and clean up
    private func extractIpa(at ipaPath: String, result: @escaping FlutterResult) {
        let ipaUrl = URL(fileURLWithPath: ipaPath)
        guard let folderUrl = restoreSharedFolder() else {
            result(FlutterError(code: "NO_FOLDER",
                                message: "No saved folder found or stale",
                                details: nil))
            return
        }
        
        if folderUrl.startAccessingSecurityScopedResource() {
            defer { folderUrl.stopAccessingSecurityScopedResource() }
            
            do {
                let fm = FileManager.default
                let tempDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try fm.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
                
                // Unzip IPA into tempDir
                try fm.unzipItem(at: ipaUrl, to: tempDir)
                
                // Locate Payload/*.app
                let payloadUrl = tempDir.appendingPathComponent("Payload")
                let contents = try fm.contentsOfDirectory(at: payloadUrl, includingPropertiesForKeys: nil)
                guard let appUrl = contents.first(where: { $0.pathExtension == "app" }) else {
                    throw NSError(domain: "EXTRACTION", code: 1, userInfo: [NSLocalizedDescriptionKey: "No .app found"])
                }
                
                // Move .app into shared folder
                let destinationUrl = folderUrl.appendingPathComponent(appUrl.lastPathComponent)
                if fm.fileExists(atPath: destinationUrl.path) {
                    try fm.removeItem(at: destinationUrl)
                }
                try fm.moveItem(at: appUrl, to: destinationUrl)
                
                // Cleanup: remove IPA + temp dir
                try fm.removeItem(at: ipaUrl)
                try fm.removeItem(at: tempDir)
                
                result(destinationUrl.path) // return final .app path
                
            } catch {
                result(FlutterError(code: "EXTRACTION_FAILED",
                                    message: error.localizedDescription,
                                    details: nil))
            }
        } else {
            result(FlutterError(code: "ACCESS_DENIED",
                                message: "Could not access folder",
                                details: nil))
        }
    }
}
