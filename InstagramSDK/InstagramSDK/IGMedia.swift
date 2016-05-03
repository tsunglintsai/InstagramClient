//
//  IGMedia.swift
//  InstagramSDK
//
//  Created by Henry on 5/1/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import Foundation
import JSONHelper

public struct IGMedia: Deserializable {
    public var tags = [String]()
    public var mediaId: String?
    public var userHasLike = false
    public var image: IGImage?
    public var likes = Int(0)
    
    public init(data: [String: AnyObject]) {
        tags <-- data["tags"]
        mediaId <-- data["id"]
        userHasLike <-- data["user_has_liked"]
        image <-- data["images"]?["standard_resolution"]
        likes <-- data["likes"]?["count"]
    }
}