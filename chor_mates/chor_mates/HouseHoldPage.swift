//
//  HouseHoldPage.swift
//  chor_mates
//
//  Created by Philip Moise on 6/22/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit
import Parse

class HouseHoldPage: ViewTextController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        let logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: "LogOut")
        logoutButton.tintColor = UIColor.whiteColor()
        //logoutButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Noteworthy", size: 20)!], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = logoutButton
        
        
    }
    
    func LogOut() {
        PFUser.logOut()
        performSegueWithIdentifier("HHToLogin", sender: nil)
    }
}
