//
//  AppDelegate.swift
//  AudioPlayer Sample
//
//  Created by Tom Baranes on 15/01/16.
//  Copyright © 2016 tbaranes. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import XCGLogger

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    
    var window: UIWindow?
    var loginUserStore = LoginUserStore()
    var audioPlayer = AudioPlayer()
    var liveProgressTimer : NSTimer?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: .Debug)
        
        // Override point for customization after application launch.
        application.beginReceivingRemoteControlEvents()
        
        let serviceLocatorStore = ServiceLocatorStore()
        if serviceLocatorStore.GetServiceLocator() == nil {
            let serviceLocator = ServiceLocator()
            serviceLocator.http = "http"
            serviceLocator.serverName = "jjhaudio.hengdianworld.com"
            serviceLocator.port = 80
            serviceLocatorStore.saveServiceLocator(serviceLocator)
        }

        
        registerForPushNotifications(application)
        return true
    }

    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }
    
    var deviceTokenString = ""
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        log.debug("Device Token: \(tokenString)")
        
        deviceTokenString = tokenString
        
        registerDeviceTokenToServer(nil)
    }
    
    
    func registerDeviceTokenToServer(completionHandler: ((response: RegisterDeviceResponse) -> Void)?) {
        let loginUser = loginUserStore.getLoginUser()
        if loginUser != nil {
            let request = RegisterDeviceRequest()
            request.deviceToken = deviceTokenString
            BasicService().sendRequest(ServiceConfiguration.REGISTER_DEVICE, request: request) {
                (resp: RegisterDeviceResponse) -> Void in
                print("register \(self.deviceTokenString) to \((loginUser?.userName)!)")
                if completionHandler  != nil {
                    completionHandler!(response: resp)
                }
            }
            
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register:", error)
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let event = event {
            audioPlayer.remoteControlReceivedWithEvent(event)
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        let currentViewController = getVisibleViewController(nil)
        
        if currentViewController != nil {
            if let navController = currentViewController as? UINavigationController {
                if let topController = navController.topViewController as? SongViewController {
                    topController.playerPageViewController.enterForhand()
                }
            }
        }
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        let currentViewController = getVisibleViewController(nil)
        
        if currentViewController != nil {
            if let navController = currentViewController as? UINavigationController {
                if let topController = navController.topViewController as? SongViewController {
                    topController.playerPageViewController.enterBackgound()
                }
            }
        }

    }
    
    private func getVisibleViewController(var rootViewController: UIViewController?) -> UIViewController? {
        
        if rootViewController == nil {
            rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        }
        
        if rootViewController?.presentedViewController == nil {
            return rootViewController
        }
        
        if let presented = rootViewController?.presentedViewController {
            if presented.isKindOfClass(UINavigationController) {
                let navigationController = presented as! UINavigationController
                print(navigationController.viewControllers.last!)
                return navigationController.viewControllers.last!
            }
            
            if presented.isKindOfClass(UITabBarController) {
                let tabBarController = presented as! UITabBarController
                print(tabBarController.selectedViewController!)
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }


}

