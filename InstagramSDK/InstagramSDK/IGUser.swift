//
//  IGUser.swift
//  InstagramSDK
//
//  Created by Henry on 5/2/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import Foundation
import JSONHelper

public struct IGUser: Deserializable {
    public var userName: String?
    public var profilePictureURL: NSURL?
    public var userId: String?
    public var fulleName: String?
    
    public init(data: [String: AnyObject]) {
        userName <-- data["username"]
        profilePictureURL <-- data["profile_picture"]
        userId <-- data["id"]
        fulleName <-- data["full_name"]
    }
}