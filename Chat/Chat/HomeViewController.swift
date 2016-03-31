//
//  HomeTableViewController.swift
//  Chat
//
//  Created by Soren Nelson on 3/29/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func segmentedControlChanged(sender: AnyObject) {
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as! HomeMessageCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
            cell.textLabel?.text = "it works"
            return cell
        }
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }


}


