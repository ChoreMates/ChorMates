//
//  changeHouseholdName.swift
//  chor_mates
//
//  Created by Michael Ye on 7/12/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class changeHouseholdNameView: UITableViewController {
    var householdID :String?
    
    @IBAction func doneHouseholdNameChange(sender: UIBarButtonItem) {
        //if field is empty
        if(houseHoldNameField.text == "")
        {
            let alert = UIAlertView()
            //alert.title = "Change Password"
            alert.message = "Please complete all fields"
            alert.addButtonWithTitle("Ok")
            alert.show()
            
            
        }
        //save new household name
        else
        {
            var query = PFQuery(className:"Household")
            query.getObjectInBackgroundWithId(householdID!) {
                (houesehold: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    println(error)
                } else if let houesehold = houesehold {
                    houesehold["name"] = self.houseHoldNameField.text
                    houesehold.saveInBackground()
                    self.performSegueWithIdentifier("unWindToSettingsFromHouseHoldName", sender: self)
                }
            }
            

            
        }
    }
    @IBOutlet weak var houseHoldNameField: UITextField!
    override func viewDidLoad() {
        self.navigationItem.title = "Household Name"
        super.viewDidLoad()
        
        //retrieve current household name
        var query = PFQuery(className: "Household_User")
        query.includeKey("householdID")
        query.includeKey("userID")
        query.whereKey("userID", equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil
            {
                // The find succeeded.
                //println("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as? [PFObject]
                {
                    if let pointer = objects[0]["householdID"] as? PFObject {
                        self.houseHoldNameField.text = pointer["name"] as! String
                        self.householdID = pointer.objectId!
                        
                        
                    }
                  
                }
                
            }
            else
            {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }

        
       
    }
}