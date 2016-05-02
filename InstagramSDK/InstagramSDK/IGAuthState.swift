//
//  IGAuthState.swift
//  InstagramSDK
//
//  Created by Henry on 4/30/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import Foundation

public enum IGAuthState: Int {
    case PendingStart
    case PendingUserInput
    case Denied
    case Authorized
}