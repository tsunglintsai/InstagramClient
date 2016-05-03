//
//  IGMediaListViewController.swift
//  InstagramApp
//
//  Created by Henry on 5/1/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit
import InstagramSDK
import SDWebImage
import MBProgressHUD

class IGMediaListViewController: UIViewController {
    private let mediaCellIdentifier = "MediaCell"
    private let userListSegueIdentifier = "UserListSegue"
    private var mediaList = [IGMedia]()
    private var hud: MBProgressHUD?
    var tag: String? {
        didSet {
            reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 300
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.tableFooterView = UIView()
        }
    }
}

//MARK: View life cycle
extension IGMediaListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHud()
        reloadData()
        title = tag
    }
}

//MARK: UI component
extension IGMediaListViewController {
    func handleGetListFailure() {
        let alert = UIAlertController(title: "Can't retreive info", message: "We can't retreive user list info", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { [weak self] (action) -> Void in
            guard let _self = self else { return }
            _self.navigationController?.popToViewController(_self, animated: true)
        }))
        presentViewController(alert, animated: true, completion: nil)
        navigationController?.popToViewController(self, animated: true)
    }
    func handleLikeFailure() {
        let alert = UIAlertController(title: "Can't give feedback", message: "We submit feedback at this point. please try again later", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { [weak self] (action) -> Void in
            guard let _self = self else { return }
            _self.navigationController?.popToViewController(_self, animated: true)
            }))
        presentViewController(alert, animated: true, completion: nil)
    }
}
//MARK: Events
extension IGMediaListViewController {
    func setupMediaCellEvents(cell:IGMediaCell , media:IGMedia) {
        cell.didTapLikeButtonClosure = { [weak self] ()->() in
            var newMedia = media
            newMedia.userHasLike = !media.userHasLike
            if newMedia.userHasLike {
                newMedia.likes++
            } else {
                newMedia.likes--
            }
            guard let mediaIndex = self?.mediaList.indexOf({$0.mediaId == media.mediaId}),
                let cellIndexPath = self?.tableView.indexPathForCell(cell)
                else { return }
            self?.mediaList[mediaIndex] = newMedia
            self?.tableView.reloadRowsAtIndexPaths([cellIndexPath], withRowAnimation: .None)
            if let medieaId = cell.mediaId {
                IGManager.sharedInstance.likeUnlikeMedia(medieaId, like: newMedia.userHasLike, successClosure: { () -> () in
                    // don't need to do anything if transaction success
                }, failureClosure: { () -> () in
                    // roll back to previous state if transaction fail
                    if cell.mediaId == media.mediaId {
                        self?.mediaList[mediaIndex] = media
                        self?.tableView.reloadRowsAtIndexPaths([cellIndexPath], withRowAnimation: .None)
                    }
                    self?.handleLikeFailure()
                })
            }
        }
        
        cell.didTapNumberOfLikeButtonClosure = { [weak self] ()->() in
            self?.performSegueWithIdentifier("UserListSegue", sender: cell)
        }
    }
}
//MARK: Model data
extension IGMediaListViewController {
    func reloadData() {
        guard let tag = tag else { return }
        showLoadingIndicator()
        IGManager.sharedInstance.queryMedia(tag, successClosure: { [weak self] (response) -> () in
            self?.mediaList = response.mediaList
            self?.tableView.reloadData()
            self?.hideLoadingIndicator()
        }) { [weak self] () -> () in
            self?.handleGetListFailure()
            self?.hideLoadingIndicator()
        }
    }
}

//MARK: Segue
extension IGMediaListViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == userListSegueIdentifier {
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPathForCell(cell) else { return }
            let media = mediaList[indexPath.row]
            if let mediaId = media.mediaId {
                IGManager.sharedInstance.getMediaLikes(mediaId, successClosure: { (users) -> () in
                    if let userListViewController = segue.destinationViewController as? IGUserListTableViewController {
                        userListViewController.userList = users
                    }
                }, failureClosure: { [weak self]  () -> () in
                    self?.handleGetListFailure()
                })
            }
        }
    }
}

//MARK: UITableViewDatasource
extension IGMediaListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(mediaCellIdentifier) as? IGMediaCell
            else { return UITableViewCell() }
        let media = mediaList[indexPath.row]
        cell.updateCellWithMedia(media, imageWidth: self.tableView.frame.width)
        setupMediaCellEvents(cell, media: media)
        return cell
    }
}

//MARK: MBProgressHUDDelegate
extension IGMediaListViewController: MBProgressHUDDelegate {
    func setupHud() {
        hud = MBProgressHUD(view: tableView)
        guard let hud = hud else { return }
        hud.dimBackground = true
        hud.delegate = self
    }
    
    func showLoadingIndicator() {
        guard let hud = hud else { return }
        tableView.addSubview(hud)
        hud.show(true)
    }
    
    func hideLoadingIndicator() {
        guard let hud = hud else { return }
        hud.hide(true, afterDelay: 500)
        hud.removeFromSuperview()
    }
}

