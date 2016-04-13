//
//  AddContactTableViewController.swift
//  Chat
//
//  Created by Soren Nelson on 4/1/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit

class AddContactTableViewController: UITableViewController {
    
    @IBOutlet var bigContactView: UIView!
    let darkView = UIView()
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let searchResultsCell = tableView.dequeueReusableCellWithIdentifier("searchResultsCell", forIndexPath: indexPath)
            return searchResultsCell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 52
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        bigContactView.center.x = view.center.x
        bigContactView.center.y = view.center.y
        darkView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        darkView.backgroundColor = UIColor.blackColor()
        darkView.alpha = 0.3
        
        self.view.addSubview(darkView)
        self.view.addSubview(bigContactView)
        
    }
    
    @IBAction func dismissButtonTapped(sender: AnyObject) {
        bigContactView.removeFromSuperview()
        darkView.removeFromSuperview()
    }
    
    @IBAction func addContactButtonTapped(sender: AnyObject) {
    }
    
}
