//
//  IGMediaListResponse.swift
//  InstagramSDK
//
//  Created by Henry on 5/1/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import Foundation
import JSONHelper

public struct IGMediaListResponsePagination: Deserializable {
    public var nextMinId: String?
    public var minTagId: String?
    public init(data: [String: AnyObject]) {
        nextMinId <-- data["next_min_id"]
        minTagId <-- data["min_tag_id"]
    }
}

public struct IGMediaListResponse: Deserializable {
    public var pagination: IGMediaListResponsePagination?
    public var mediaList = [IGMedia]()
    public init(data: [String: AnyObject]) {
        pagination <-- data["pagination"]
        mediaList <-- data["data"]
    }
}
