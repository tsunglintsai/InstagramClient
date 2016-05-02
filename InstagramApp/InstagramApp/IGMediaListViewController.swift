//
//  IGMediaListViewController.swift
//  InstagramApp
//
//  Created by Henry on 5/1/16.
//  Copyright © 2016 Henry. All rights reserved.
//

import UIKit
import InstagramSDK

class IGMediaListViewController: UIViewController {
    let mediaCellIdentifier = "MediaCell"
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 300
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
}

//MARK: View life cycle
extension IGMediaListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//MARK: UITableViewDatasource
extension IGMediaListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(mediaCellIdentifier) as? IGMediaCell else { return UITableViewCell() }
        cell.imageHeightConstrain.constant = CGFloat(100 * ((indexPath.row % 2) + 1))
        return cell
    }
    
}

//MARK: UITableViewDelegate
extension IGMediaListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}