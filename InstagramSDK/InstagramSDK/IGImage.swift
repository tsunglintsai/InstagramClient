//
//  IGImage.swift
//  InstagramSDK
//
//  Created by Henry on 5/1/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import Foundation

struct IGImage {
    let urlString: String
    let width: CGFloat
    let height: CGFloat
    let imageResolution: IGImageResolution
}

extension IGImage {
    init?(data:[String:AnyObject], imageResolution: IGImageResolution) {
        var validData = false
        self.imageResolution = imageResolution
        
        if let width = data["width"] as? CGFloat {
            self.width = width
        } else {
            self.width = 0
            validData = false
        }
        
        if let height = data["height"] as? CGFloat {
            self.height = height
        } else {
            self.height = 0
            validData = false
        }
        
        if let url = data["url"] as? String {
            self.urlString = url
        } else {
            self.urlString = ""
            validData = false
        }
        
        if !validData {
            return nil
        }
    }
}