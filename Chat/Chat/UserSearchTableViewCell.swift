//
//  UserSearchTableViewCell.swift
//  Chat
//
//  Created by Soren Nelson on 5/27/16.
//  Copyright © 2016 SORN. All rights reserved.
//

import UIKit

class UserSearchTableViewCell: UITableViewCell {
    

    @IBOutlet weak var usernameLabel: UILabel!
    var relationship: Relationship?
        
    @IBOutlet var sendRequestButton: UIButton!
    @IBOutlet var profilePic: UIImageView!
}
