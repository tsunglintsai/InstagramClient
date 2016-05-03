//
//  IGMediaCell+IGMedia.swift
//  InstagramApp
//
//  Created by Henry on 5/2/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit
import InstagramSDK
import SDWebImage

// associate object
extension IGMediaCell {
    private struct MediaIdKey {
        static var DescriptiveName = "MediaIdKey"
    }
    
    var mediaId: String? {
        get { return objc_getAssociatedObject(self, &MediaIdKey.DescriptiveName) as! String? }
        set { objc_setAssociatedObject( self, &MediaIdKey.DescriptiveName, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC ) }
    }
}

// update UI
extension IGMediaCell {
    func updateCellWithMedia(media: IGMedia, imageWidth: CGFloat) {
        mediaId = media.mediaId
        if let image = media.image {
            let scale = imageWidth / image.width
            imageHeightConstrain.constant = image.height * scale
            mediaImageView.sd_setImageWithPreviousCachedImageWithURL(image.url, placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.DelayPlaceholder, progress: nil, completed: nil)
        }
        likeButton.selected = media.userHasLike
        numberOfLikeButton.setTitle("\(media.likes) likes", forState: UIControlState.Normal)
        mediaId = media.mediaId
        likeButton.enabled = true
    }
}