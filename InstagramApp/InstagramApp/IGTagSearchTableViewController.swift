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
    private let cellIdentifier = "TagCell"
    private let mediaListSegueIdentifier = "MediaListSegue"
    private var tagList = [String]()
    @IBOutlet weak var searchBar: UISearchBar!
    
}

//MARK: View life cycle
extension IGTagSearchTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}

//MARK: Events
extension IGTagSearchTableViewController {
    func searchTag(keyword:String) {
        IGManager.sharedInstance.queryTag(keyword, successClosure: { [weak self] (tagList,keyword) -> () in
            // return could in different order, we drop result which doens't matches current search keyword
            guard self?.searchBar.text == keyword else { return }
            self?.tagList = tagList
            self?.tableView.reloadData()
        }) { [weak self] () -> () in
            self?.tagList = [String]()
            self?.tableView.reloadData()
            self?.showSimpleAlert("Error", content: "Error when performing search, please try again later")
        }
    }
}

//MARK: UI Component
extension IGTagSearchTableViewController {
    func showSimpleAlert(title: String, content:String, buttonText:String = "OK") {
        let alert = UIAlertController(title: title, message: content, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}


//MARK: UITableViewDatasource
extension IGTagSearchTableViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) else { return UITableViewCell() }
        cell.textLabel?.text = tagList[indexPath.row]
        return cell
    }
}

//MARK: UITableViewDelegate
extension IGTagSearchTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(mediaListSegueIdentifier, sender: nil)
    }
}

//MARK: Segues
extension IGTagSearchTableViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == mediaListSegueIdentifier {
            guard let selectedRow = tableView.indexPathForSelectedRow?.row, let controller = segue.destinationViewController as? IGMediaListViewController else { return }
            controller.tag = tagList[selectedRow]
        }
    }
}

//MARK: UISearchBarDelegate
extension IGTagSearchTableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchString = searchBar.text {
            if searchString.characters.isEmpty {
                tagList = [String]()
                tableView.reloadData()
            } else {
                searchTag(searchString)
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchString = searchBar.text {
            searchTag(searchString)
            searchBar.resignFirstResponder()
            searchBar.showsCancelButton = false
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchBar.showsCancelButton = false
    }
}