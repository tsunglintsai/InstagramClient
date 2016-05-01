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

    override func viewDidLoad() {
        super.viewDidLoad()
        let p = IGAuthentication()
        print(p.getNumber())
    }


}

