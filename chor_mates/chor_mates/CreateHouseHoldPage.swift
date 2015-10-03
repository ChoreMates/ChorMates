//
//  CreateHouseHoldPage.swift
//  chor_mates
//
//  Created by Philip Moise on 6/23/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit
import Parse

class CreateHouseHoldPage: ViewTextController {
    
    @IBOutlet weak var householdName: UITextField!
    @IBOutlet weak var address1: UITextField!
    @IBOutlet weak var address2: UITextField!
    @IBOutlet weak var privacy: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: "LogOut")
        logoutButton.tintColor = UIColor.whiteColor()
        //logoutButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Noteworthy", size: 20)!], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = logoutButton
        
        // Check if previously requested, if yes make sure if want to continue.
        // If yes, send email to household owner saying no more request, remove request from the table
    }
    
    override func DismissKeyboard() {
        super.DismissKeyboard()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func LogOut() {
        PFUser.logOut()
        performSegueWithIdentifier("CreateToLogin", sender: nil)
    }
    
    @IBAction func HomeSweetHome(sender: UIButton) {
        DismissKeyboard()
        if(householdName.text!.isEmpty || address1.text!.isEmpty) {
            PopUp("Empty Fields", image: nil, msg: "You left something empty!", animate: true)
        }
        else {
            var address: String = address1.text!
            if(!address2.text!.isEmpty) {
                address += ", \(address2.text)"
            }
        
            let household = PFObject(className: "Household")
            household["name"] = householdName.text
            household["createdBy"] = PFUser.currentUser()!
            household["address"] = address
            household["private"] = privacy.on
            household.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    let houseUser = PFObject(className: "Household_User")
                    houseUser["householdID"] = household
                    houseUser["userID"] = PFUser.currentUser()!
                    houseUser.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            self.PopUp("Household Created", image: nil, msg: "You're household has been created!", animate: true,  onCloseFunc: self.RedirectHomePage)
                            //Redirect to home page
                        }
                        else {
                            household.deleteInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (!success) {
                                    print("Delete failed? \(error!.description)")
                                    //Assuming the connection loss is the cause of the failure
                                    household.deleteEventually()
                                }
                                self.PopUp("Household Not Created", image: nil, msg: "The household could not be created!\nPlease try again.", animate: true,  onCloseFunc: nil)
                            }
                        }
                    }
                }
                else {
                    self.PopUp("Household Not Created", image: nil, msg: "The household could not be created!\nPlease try again.", animate: true,  onCloseFunc: nil)
                }
            }
        }
    }
    
    func RedirectHomePage() {
        PFUser.logOut() //Temp! Only until tab view is working
        let controller = storyboard?.instantiateViewControllerWithIdentifier("MyChoresPage") as! UITableViewController
        presentViewController(controller, animated: true, completion: nil)
    }
}
