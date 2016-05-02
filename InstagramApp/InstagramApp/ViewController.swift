//
//  ViewController.swift
//  InstagramApp
//
//  Created by Henry on 4/30/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit
import InstagramSDK

class ViewController: UIViewController {
    var viewController: IGAuthViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        viewController = IGManager.sharedInstance.authViewController()
//        if let viewController = viewController {
//            viewController.view.frame = view.bounds
//            let navController = UINavigationController(rootViewController: viewController)
//            viewController.startAuth({ (state) -> () in
//                print(state)
//                print(IGManager.sharedInstance.accessToken)
//
//            })
//            self.presentViewController(navController, animated: true) { () -> Void in
//                
//            }
//        }
        IGManager.sharedInstance.queryMedia("test")
    }


}

