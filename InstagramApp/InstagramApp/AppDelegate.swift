//
//  AppDelegate.swift
//  InstagramApp
//
//  Created by Henry on 4/30/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit
import InstagramSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        IGManager.configIGManager("44cfd11666ed4e9183ddd19bdc1b708f", redirectURL: "https://www.instagram.com/henrytsaiint0403/", permissions: Set([.PublicContent,.Likes]) )
        IGManager.sharedInstance.authRequireUserInputClosure = { [weak self] (authViewController)->() in
            self?.showAuthDialog(authViewController)
            authViewController.authFailClosure = {
                authViewController.startAuth({ (state) -> () in })
            }
        }
        return true
    }
    
    func showAuthDialog(authViewController: IGAuthViewController) {
        guard let rootViewController = window?.rootViewController else {
            return
        }
        rootViewController.dismissViewControllerAnimated(false, completion: nil)
        authViewController.authSuccessClosure = {
            rootViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        let navController = UINavigationController(rootViewController: authViewController)
        navController.navigationBar.translucent = false
        rootViewController.presentViewController(navController, animated: true, completion: { () -> Void in })
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

