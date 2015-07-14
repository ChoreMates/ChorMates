//
//  settings.swift
//  chor_mates
//
//  Created by Michael Ye on 7/12/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//



import UIKit

import Parse

import ParseUI

class settingsView: UITableViewController {
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
      
        
        
    }
    @IBOutlet var staticSettingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Options"
    }
    override func viewDidAppear(animated: Bool) {
        
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }
        else if(section == 1){
            return 2
        }
        else  {
            return 2
        }
    
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var section = indexPath.section
        //account section
        if(section==0){
            
            
        }
        //household section
        else if(section==1){
            // leave household
            if(indexPath.row == 0){
               
                let leaveHousehold = UIAlertController(title: nil, message: "Your activities with the Household will be erased permanently.", preferredStyle: .Alert)
                
                let yesAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                    { action -> Void in
                        
                        //delete the record for which household the user is in currently
                        var deleteHouseholdUsers = PFQuery(className: "Household_User")
                        deleteHouseholdUsers.whereKey("userID", equalTo: PFUser.currentUser()!)
                        
                        deleteHouseholdUsers.findObjectsInBackgroundWithBlock {
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            
                            if error == nil
                            {
                                // The find succeeded.
                                println("Successfully retrieved \(objects!.count) chores.")
                                // Do something with the found objects
                                if let objects = objects as? [PFObject]
                                {
                                    PFObject.deleteAllInBackground(objects)
                                }
                            }
                            else
                            {
                                println("error")
                                
                            }
                        }

                        //delete all chores associated with the user
                        var deleteChoreUsers = PFQuery(className: "Chore_User")
                        deleteChoreUsers.whereKey("userID", equalTo: PFUser.currentUser()!)
                        
                        deleteChoreUsers.findObjectsInBackgroundWithBlock {
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            
                            if error == nil
                            {
                                // The find succeeded.
                                println("Successfully retrieved \(objects!.count) chores.")
                                // Do something with the found objects
                                if let objects = objects as? [PFObject]
                                {
                                    PFObject.deleteAllInBackground(objects)
                                }
                            }
                            else
                            {
                                println("error")
                                
                            }
                        }
                        
                        //redirect user to the householdpage where they can join or create a new household
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("HouseHoldPage") as! HouseHoldPage
                        self.presentViewController(controller, animated: true, completion: nil)
                        
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
                leaveHousehold.addAction(yesAction)
                leaveHousehold.addAction(cancelAction)
                
                
                
                self.presentViewController(leaveHousehold, animated: true, completion: nil)
            }
            
        }
        //basic section
        else if(section==2){
            //notifications
            
            
            //logout
            if(indexPath.row == 1){
                PFUser.logOut()
                //Go to login page
                let controller = storyboard?.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
                presentViewController(controller, animated: true, completion: nil)
                
            }

        }
   

        
    }
    
}