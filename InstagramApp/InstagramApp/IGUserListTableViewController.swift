//
//  IGUserListTableViewController.swift
//  InstagramApp
//
//  Created by Henry on 5/2/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit
import InstagramSDK
import SDWebImage


class IGUserListTableViewController: UITableViewController {
    private let cellIdentifier = "UserCell"
    var userList = [IGUser]() {
        didSet {
            guard let tableView = tableView else { return }
            tableView.reloadData()
        }
    }
}

//MARK: View life cycle
extension IGUserListTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: UITableViewDatasource
extension IGUserListTableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) else { return UITableViewCell() }
        let user = userList[indexPath.row]
        cell.textLabel?.text = user.fulleName
        return cell
    }
}
