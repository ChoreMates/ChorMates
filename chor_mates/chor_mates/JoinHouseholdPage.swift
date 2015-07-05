//
//  JoinHouseholdPage.swift
//  chor_mates
//
//  Created by Philip Moise on 7/3/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import Foundation
import Parse

class JoinHouseholdPage: ViewTextController {
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: "LogOut")
        logoutButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = logoutButton
        
        var query = PFQuery(className: "HouseInvitation")
        query.whereKey("userID", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if(objects!.count != 0) {
                    self.PopUp("Waiting for Response", image: nil, msg: "Your already requested to join a household!", animate: true,  onCloseFunc: self.GoBack)
                }
            }
        }
    }
    
    func GoBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func LetMeIn(sender: UIButton) {
        if(!email.text.isEmpty) {
            if(email.text.rangeOfString(".") == nil || email.text.rangeOfString("@") == nil) {
                PopUp("E-Mail Error", image: nil, msg: "E-Mail is not in the proper format!", animate: true)
            }
            else if(email.text == PFUser.currentUser()!.email!) {
                PopUp("E-Mail Error", image: nil, msg: "You can't join your own household!", animate: true)
            }
            else {
                //Query for the requested user
                var query = PFUser.query()
                query!.whereKey("email", equalTo:email.text)
                query?.findObjectsInBackgroundWithBlock {
                    (users: [AnyObject]?, error: NSError?) -> Void in
                    if error == nil {
                        if(users!.count == 0) {
                            self.PopUp("Request Not Sent", image: nil, msg: "E-Mail address is not found!", animate: true,  onCloseFunc: nil)
                        }
                        else {
                            if let users = users as? [PFObject] {
                                var user = users.first!
                                println(user.objectId!)
                                // Query for the requested user's household
                                var query2 = PFQuery(className: "Household_User")
                                query2.whereKey("userID", equalTo: user)
                                query2.findObjectsInBackgroundWithBlock {
                                    (objects: [AnyObject]?, error2: NSError?) -> Void in
                                    if error2 == nil {
                                        if(objects!.count == 0) {
                                            self.PopUp("Request Not Sent", image: nil, msg: "User is not part of a household!", animate: true,  onCloseFunc: nil)
                                        }
                                        else {
                                            if let hHolds = objects as? [PFObject] {
                                                var hHold = hHolds.first!
                                                println(hHold["householdID"]!.objectId!!)
                                                
                                                //Create HouseInvitation object and send email to household owner
                                                var houseInvite = PFObject(className: "HouseInvitation")
                                                houseInvite["userID"] = PFUser.currentUser()
                                                houseInvite["householdID"] = hHold["householdID"]!
                                                houseInvite["status"] = false
                                                houseInvite.saveInBackgroundWithBlock {
                                                    (success: Bool, error3: NSError?) -> Void in
                                                    if (success) {
                                                        self.PopUp("Request Sent", image: nil, msg: "You're request to join has been sent!", animate: true,  onCloseFunc: nil)
                                                    }
                                                    else {
                                                        self.PopUp("Request Not Sent", image: nil, msg: "Could not send request!", animate: true,  onCloseFunc: nil)
                                                        println("Error3: \(error3!) \(error3!.userInfo!)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        println("Error2: \(error2!) \(error2!.userInfo!)")
                                    }
                                }
                            }
                        }
                    }
                    else {
                        println("Error: \(error!) \(error!.userInfo!)")
                    }
                }
            }
        }
        else
        {
            PopUp("E-Mail Error", image: nil, msg: "Please enter an e-mail address.", animate: true)
        }
    }
    
    
}