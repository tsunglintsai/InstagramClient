//
//  IGImage.swift
//  InstagramSDK
//
//  Created by Henry on 5/1/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import Foundation
import JSONHelper

public struct IGImage: Deserializable {
    public var url: NSURL?
    public var width: CGFloat = 0
    public var height: CGFloat = 0
    public init(data: [String: AnyObject]) {
        url <-- data["url"]
        width <-- data["width"]
        height <-- data["height"]
    }
}
