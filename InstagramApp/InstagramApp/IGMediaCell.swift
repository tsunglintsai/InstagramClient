//
//  IGMediaCell.swift
//  InstagramApp
//
//  Created by Henry on 5/1/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit

class IGMediaCell: UITableViewCell {
    var didTapLikeButtonClosure: (()->())?
    var didTapNumberOfLikeButtonClosure: (()->())?
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var imageHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton! {
        didSet {
            likeButton.addTarget(self, action: "didTapLikeButton:", forControlEvents: .TouchUpInside)
        }
    }
    @IBOutlet weak var numberOfLikeButton: UIButton! {
        didSet {
            numberOfLikeButton.addTarget(self, action: "didNumberOfLikeButtonButton:", forControlEvents: .TouchUpInside)
        }
    }
}


// MARK: Events
extension IGMediaCell {
    func didTapLikeButton(sender:AnyObject?) {
        didTapLikeButtonClosure?()
    }
    func didNumberOfLikeButtonButton(sender:AnyObject?) {
        didTapNumberOfLikeButtonClosure?()
    }
}
