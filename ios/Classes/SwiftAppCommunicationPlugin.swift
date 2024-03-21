import Flutter
import UIKit

public class SwiftAppCommunicationPlugin: NSObject, FlutterPlugin {
    
    var resultFlutter: FlutterResult?
    var notificationReceived: String?
    var receivedValue : Dictionary<String, Any>?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "app_communication_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftAppCommunicationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        resultFlutter = result
        if(call.method == "getDataReceivedInSoftpos") {
            if(receivedValue == nil) {
                result(nil)
            } else {
                result(receivedValue)
            }
        } else if(call.method == "sendDataBackToSource") {
            if(call.arguments == nil) {
                sendDataBackToSource(arguments: nil)
            } else {
                sendDataBackToSource(arguments:  convertArgumentsToDict(arguments: call.arguments as! [String : Any]))
            }
            
        } else if(call.method == "openSoftposApp") {
            //
            // TODO: When data will be received back to source app => please handle to convert int to bool type without fail
            openSoftposApp(arguments:  convertArgumentsToDict(arguments: call.arguments as! [String : Any]))
        } else if(call.method == "throwErrorFromSoftpos") {
            // sending in this method because for error it needs to be handled in notification call back
            
            sendDataBackToSource(arguments: convertArgumentsToDict(arguments: call.arguments as! [String : Any]))
        }
        
        else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    func openSoftposApp(arguments : [String : Any]) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.resultReceivedFromSoftpos(notification:)), name: Notification.Name("OPENSOFTPOSAPP"), object: nil)
        var requestData = [URLQueryItem]()
        for (key, value) in arguments {
            requestData.append(URLQueryItem(name: key, value: String( describing: value) ))
        }
        var urlComps = URLComponents(string: "interpaymeasoftpos://app")!
        urlComps.queryItems = requestData
        let appScheme = String(describing: urlComps.url!)
        let url : URL! = URL.init(string: appScheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        if #available(iOS 10.0, *) {
            // commenting out because canOpenUrl gives false
            if(UIApplication.shared.canOpenURL(url)) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                resultFlutter!(FlutterError(code: "404", message: "App not installed", details: nil))
            }
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @objc func resultReceivedFromSoftpos(notification: Notification) {
        let data = getDictionaryFromUrl(url: (notification.userInfo!["url"] as! String).removingPercentEncoding!)
        
        if(data == nil || data.isEmpty) {
            resultFlutter!(FlutterError(code: "400", message: "User has cancelled the payment.", details: nil))
        } else if(data["errorCode"] != nil) {
            resultFlutter!(FlutterError(code:(data["errorCode"] as! String).removingPercentEncoding!, message: (data["errorMessage"] as! String).removingPercentEncoding!, details: (data["errorDetails"] as! String).removingPercentEncoding!))
        }
        
        else {
            resultFlutter!(data)
        }
        
    }
    
    
    
    func sendDataBackToSource(arguments :[String : Any]?) {
        var responseData = [URLQueryItem]()
        if(arguments == nil) {
            //
        } else {
            
            for (key, value) in arguments! {
                responseData.append(URLQueryItem(name: key, value: String( describing: value) ))
            }
        }
        
        
        let responseUrl : String = receivedValue!["bundleUrlSchemeName"] as! String
        
        var urlComps = URLComponents(string: "\(responseUrl)://app")!
        urlComps.queryItems = responseData
        let appScheme = String(describing: urlComps.url!)
        let url : URL! = URL.init(string: appScheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        receivedValue = nil // adding null so that when user comes back to softpos he will not redirect to payment screen
        resultFlutter!(true)
        if #available(iOS 10.0, *) {
            // commenting out because canOpenUrl gives false
            //            if(UIApplication.shared.canOpenURL(url)) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //            } else {
            //                resultFlutter!(FlutterError(code: "404", message: "App not installed", details: nil))
            //            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    
    public  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Response From SourceApp==>\(url.absoluteString)")
        notificationReceived = url.absoluteString
        
        guard let query = notificationReceived else { return false}
        
        
        
        receivedValue = getDictionaryFromUrl(url: query)
        
        NotificationCenter.default.post(name: Notification.Name("OPENSOFTPOSAPP"), object: nil, userInfo: ["url" : query])
        
        return true
    }
    
    func getDictionaryFromUrl(url : String) -> Dictionary<String, Any> {
        var queryStrings = [String: Any]()
        if(url.contains("&")) {
            for pair in url.components(separatedBy: "?")[1].components(separatedBy: "&") {
                
                let key = pair.components(separatedBy: "=")[0]
                
                let value = pair
                    .components(separatedBy:"=")[1]
                    .replacingOccurrences(of: "+", with: " ")
                    .removingPercentEncoding ?? ""
                
                queryStrings[key] = value
            }
        }
        
        return queryStrings
    }
    
    
    func convertArgumentsToDict(arguments : [String : Any]) -> Dictionary<String, Any> {
        var args = [String : Any]()
        
        for (key, value) in arguments {
            if(value is Bool) {
                args[key] = Bool(value as! NSNumber)
            } else {
                args[key] = value
            }
        }
        return args
        
    }
}
