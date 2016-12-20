 //
//  AppDelegate.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 06/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Armchair
import Fabric
import Crashlytics

let kRedirectToLogin = "redirectToLogin"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var onSignupActivation: (() -> ())?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize fabric
        Fabric.with([Crashlytics.self])
        Fabric.with([Answers.self])
        
        // Set navigation bar color universally
        UINavigationBar.appearance().barTintColor = BaseApplicationColor
        
        // Set title font attributes for navigation bar
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : NavigationBarTitleColor]
        
        // Set keyboard manager
        IQKeyboardManager.sharedManager().enable = true
        
        // Set Google sign
        GIDSignIn.sharedInstance().clientID = GoogleSignInClientId
        
        // Set Google Analytics
        GAI.sharedInstance().tracker(withTrackingId: GoogleAnalyticsTrackingId)
//        GAI.sharedInstance().logger.logLevel = GAILogLevel.Verbose
        
        // Initialize facebook sign-in
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Set rate app configurations
        Armchair.appID(ApplicationId)
        Armchair.appName(ApplicationName)
        Armchair.reviewTitle("Rate \(ApplicationName)")
        Armchair.reviewMessage("If you enjoy using \(ApplicationName), please take a moment to rate it on app store.")
        Armchair.cancelButtonTitle("No, thanks")
        Armchair.rateButtonTitle("Rate \(ApplicationName)")
        Armchair.remindButtonTitle("Remind me later")
        Armchair.daysUntilPrompt(5)
        Armchair.opensInStoreKit(false)
        
        UAirship.takeOff()
        
        // User notifications will not be enabled until userPushNotificationsEnabled is
        // set YES on UAPush. Once enabled, the setting will be persisted and the user
        // will be prompted to allow notifications. Normally, you should wait for a more
        // appropriate time to enable push to increase the likelihood that the user will
        // accept notifications.
        UAirship.push().userPushNotificationsEnabled = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        PersistencyManager.sharedManager.saveContext()
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication,
                     open url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return (GIDSignIn.sharedInstance().handle(url,
            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplicationOpenURLOptionsKey.annotation])) || (FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation]))
    }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation) || (FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation))
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        print("Scheme url: " + url.absoluteString)
        
        if url.absoluteString.contains("signup") {
            if customerManager.isCustomerLoggedIn == false {                
                UserDefaults.standard.set(true, forKey: kRedirectToLogin)
                if onSignupActivation != nil {
                    onSignupActivation!()
                }
            }
        }
        
        return true
    }
}

