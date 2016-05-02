//
//  IGTagSearchTableViewController.swift
//  InstagramApp
//
//  Created by Henry on 5/1/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit
import InstagramSDK

class IGTagSearchTableViewController: UITableViewController {
    let tagCellIdentifier = "TagCell"
    let mediaListSegueIdentifier = "MediaListSegue"
    @IBOutlet weak var searchBar: UISearchBar!
    
}

//MARK: View life cycle
extension IGTagSearchTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: UITableViewDatasource
extension IGTagSearchTableViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(tagCellIdentifier) else { return UITableViewCell() }
        cell.textLabel?.text = "test"
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140.0
    }
}

//MARK: UITableViewDelegate
extension IGTagSearchTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("Test2Segue", sender: nil)
    }
}