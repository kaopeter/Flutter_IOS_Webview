import UIKit
import Flutter
import WebKit
@available(iOS 10.0, *)
@UIApplicationMain
@objc class AppDelegate: UIResponder,UIApplicationDelegate,FlutterAppLifeCycleProvider {
    
  
   
    let lifeCycleDelegate = FlutterPluginAppLifeCycleDelegate()
    var flutterEngine : FlutterEngine?;
    func addApplicationLifeCycleDelegate(_ delegate: FlutterPlugin) {
        lifeCycleDelegate.add(delegate)
    }
    
    var rootFlutterViewController:FlutterViewController? {
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        if viewController!.isKind(of: FlutterViewController.self) {
            return viewController as? FlutterViewController
        }
        return nil
    }
    
    
    var window: UIWindow?
    let webview = WKWebView()
    let button = UIButton(type: UIButtonType.system)
    
   func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "samples.flutter.io/battery",
                                                  binaryMessenger: controller)
        let urlChannel = FlutterMethodChannel(name: "samples.flutter.io/url",
                                                  binaryMessenger: controller)
    
        batteryChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard call.method == "getBatteryLevel" else {
                result(FlutterMethodNotImplemented)
                return
            }
            print(call.arguments ?? "no value")
            self!.receiveBatteryLevel(result: result)
        })
        urlChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard (call.method == "embedURL" || call.method == "extURL") else {
                result(FlutterMethodNotImplemented)
                return
            }
            if(call.method == "embedURL"){
                self!.addWebView()
                self!.webview.load(URLRequest(url: URL(string:call.arguments as! String)!))
            }else{
                //external browser
                self!.launchURL(parm:call.arguments as! String, result: result)
            }
            print(call.arguments ?? "no url")
            
        })
    
    
        self.flutterEngine = FlutterEngine(name: "io.flutter", project: nil);
        self.flutterEngine?.run(withEntrypoint: nil);
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
    
        let myLaunchOpt = [UIApplicationLaunchOptionsKey:Any]()
         lifeCycleDelegate.application(application, didFinishLaunchingWithOptions:   myLaunchOpt)
        return true
    }
    
    
    func addWebView(){
       
        button.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width,height: 60)
        button.backgroundColor = UIColor.yellow
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 60)
        button.addTarget(self, action: #selector(closeWebAction), for: .touchUpInside)
        self.webview.frame  = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.rootFlutterViewController?.view.addSubview(self.webview)
        
        self.rootFlutterViewController?.view.addSubview(button)
    }
    
    @objc func closeWebAction(sender: UIButton!) {
        webview.removeFromSuperview()
        button.removeFromSuperview()
        print("Button tapped")
    }
    
    private func receiveBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == UIDeviceBatteryState.unknown {
            result(FlutterError(code: "UNAVAILABLE",
                                message: "Battery info unavailable",
                                details: nil))
        } else {
            result(Int(device.batteryLevel * 100))
        }
    }
    @available(iOS 10.0, *)
    private func launchURL(parm:String,result: FlutterResult) {
        if let url = URL(string: parm) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        lifeCycleDelegate.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        lifeCycleDelegate.applicationWillEnterForeground(application)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        lifeCycleDelegate.applicationWillResignActive(application)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        lifeCycleDelegate.applicationDidBecomeActive(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        lifeCycleDelegate.applicationWillTerminate(application)
    }
    
}
