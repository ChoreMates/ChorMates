//
//  changePasswordView.swift
//  chor_mates
//
//  Created by Michael Ye on 7/12/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//
import Foundation
import UIKit
import Parse
import ParseUI

class changePasswordView: UITableViewController {
    
    @IBOutlet weak var initialPassword: UITextField!
    var passwordChecked: Bool = false
    @IBOutlet weak var newPassword: UITextField!
   
    @IBOutlet weak var newPasswordRepeat: UITextField!
    @IBOutlet var changePasswordTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tblView =  UIView(frame: CGRectZero)
        changePasswordTableView.tableFooterView = tblView
        changePasswordTableView.tableFooterView!.hidden = true
       // changePasswordTableView.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "Change Password"
    }
    
    @IBAction func doneChangePassword(sender: UIBarButtonItem) {
        //if any of the text fields are empty, alert user

        if( initialPassword.text == "" || newPassword.text == "" || newPasswordRepeat.text == "")
        {
            let alert = UIAlertView()
            //alert.title = "Change Password"
            alert.message = "Please fill in all password fields"
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        else
        {
            //login to check if users entered current password correctly
            PFUser.logInWithUsernameInBackground(PFUser.currentUser()!.email!,
                password:initialPassword.text){ (user: PFUser?, error: NSError?) -> Void in
                
                    if(user == nil){
                        let alert = UIAlertView()
                        alert.message = "Current Password Incorrect"
                        alert.addButtonWithTitle("Ok")
                        alert.show()
                    }
                }
            
               
            //check if new passwords match
            if(self.newPassword.text != self.newPasswordRepeat.text){
                let alert = UIAlertView()
                //alert.title = "Change Password"
                alert.message = "New Passwords do not match"
                alert.addButtonWithTitle("Ok")
                alert.show()
            }
            //save new password
            else
            {
               
                PFUser.currentUser()?.password = newPasswordRepeat.text
                PFUser.currentUser()?.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    
                    if (success) {
                        println(success)
                        self.performSegueWithIdentifier("unWindtoSettingsFromPassword", sender: self)

                     
                    } else {
                        println(error!.description)
                    }
                   
                }
               
                
            }
        }
    }
}