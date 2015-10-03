//
//  editProfileView.swift
//  chor_mates
//
//  Created by Michael Ye on 7/12/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class editProfileView: UITableViewController {
    
    
    @IBAction func doneEditProfile(sender: UIBarButtonItem) {
        //if any of the text fields are empty, alert user
        if(self.emailField.text == "" || self.firstNameField.text == ""
            ||  self.lastNameField.text == ""){
                let alert = UIAlertView()
                //alert.title = "Change Password"
                alert.message = "Please complete all fields"
                alert.addButtonWithTitle("Ok")
                alert.show()
        }
        else
        {
           //save to database
            PFUser.currentUser()!.setObject(self.emailField.text!, forKey: "username")
            PFUser.currentUser()!.setObject(self.emailField.text!, forKey: "email")
            PFUser.currentUser()?.setObject(self.firstNameField.text!, forKey: "fName")
            PFUser.currentUser()?.setObject(self.lastNameField.text!, forKey: "lName")
            PFUser.currentUser()?.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                
                if (success) {
                    print(success)
                    self.performSegueWithIdentifier("unWindtoSettingsFromProfile", sender: self)
                    
                    // self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    if(error!.code == 125)
                    {
                        
                        let alert = UIAlertView()
                        //alert.title = "Change Password"
                        alert.message = "Enter a Valid Email Address"
                        alert.addButtonWithTitle("OK")
                        alert.show()
                    }
                    print(error!.description)
                }
                
            }

        }
    }
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.emailField.text = PFUser.currentUser()!.email!
        self.firstNameField.text = PFUser.currentUser()!["fName"] as? String!
        self.lastNameField.text = PFUser.currentUser()!["lName"] as? String!
        self.navigationItem.title = "Edit Profile"
    }
    
}