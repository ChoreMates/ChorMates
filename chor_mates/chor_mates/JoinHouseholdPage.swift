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
        
        let logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: "LogOut")
        logoutButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = logoutButton
        
        let query = PFQuery(className: "HouseInvitation")
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
    
    func LogOut() {
        PFUser.logOut()
        performSegueWithIdentifier("JoinToLogin", sender: nil)
    }
    
    func GoBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func LetMeIn(sender: UIButton) {
        if(!email.text!.isEmpty) {
            if(email.text!.rangeOfString(".") == nil || email.text!.rangeOfString("@") == nil) {
                PopUp("E-Mail Error", image: nil, msg: "E-Mail is not in the proper format!", animate: true)
            }
            else if(email.text == PFUser.currentUser()!.email!) {
                PopUp("E-Mail Error", image: nil, msg: "You can't join your own household!", animate: true)
            }
            else {
                //Find household of user based on email address
                let query = PFQuery(className: "Household_User")
                let inner = PFUser.query()!
                inner.whereKey("email", equalTo:email.text!)
                query.whereKey("userID", matchesQuery: inner)
                query.findObjectsInBackgroundWithBlock {
                    (usersHH: [AnyObject]?, error: NSError?) -> Void in
                    if error == nil {
                        if(usersHH!.count == 0) {
                            self.PopUp("Email Error", image: nil, msg: "Could not find the household for the email address provided!", animate: true,  onCloseFunc: nil)
                        }
                        else {
                            if let usersHH = usersHH as? [PFObject] {
                                let userHH = usersHH.first!
                                //Create HouseInvitation object and send email to household owner
                                let houseInvite = PFObject(className: "HouseInvitation")
                                houseInvite["userID"] = PFUser.currentUser()
                                houseInvite["householdID"] = userHH["householdID"]!
                                houseInvite["status"] = false
                                houseInvite.saveInBackgroundWithBlock {
                                    (success: Bool, error2: NSError?) -> Void in
                                    if (success) {
                                        self.PopUp("Request Sent", image: nil, msg: "You're request to join has been sent!", animate: true,  onCloseFunc: nil)
                                        
                                        //Send email to household owner, query for hh owner
                                        // DOESN'T WORK YET! Successfully gets email, no email sent
//                                        var queryHH = PFQuery(className: "Household")
//                                        println(userHH["householdID"]!.objectId!!)
//                                        queryHH.whereKey("objectId", equalTo: userHH["householdID"]!.objectId!!)
//                                        queryHH.includeKey("createdBy")
//                                        queryHH.findObjectsInBackgroundWithBlock {
//                                            (houseHold: [AnyObject]?, error: NSError?) -> Void in
//                                            if error == nil {
//                                                if houseHold!.count == 0 {
//                                                    println("No household by that id!")
//                                                }
//                                                else {
//                                                    if let houseHold = houseHold as? [PFObject] {
//                                                        let hh = houseHold.first!
//                                                        println("Found the household!")
//                                                        let creator = hh["createdBy"]! as! PFUser
//                                                        println(creator.email!)
//                                                    }
//                                                }
//                                            }
//                                            else {
//                                                println("Error: \(error!) \(error!.userInfo!)")
//                                            }
//                                        }
                                        //End send email query
                                    }
                                    else {
                                        self.PopUp("Request Not Sent", image: nil, msg: "Could not send request!\nPlease try again.", animate: true,  onCloseFunc: nil)
                                        print("Error3: \(error2!) \(error2!.userInfo)")
                                    }
                                }
                            }
                        }
                    }
                    else {
                        self.PopUp("Request Not Sent", image: nil, msg: "Request could not be sent!\nPlease try again.", animate: true)
                        print("Error: \(error!) \(error!.userInfo)")
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