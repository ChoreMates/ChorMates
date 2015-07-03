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
        
        var logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItemStyle.Plain, target: self, action: "LogOut")
        logoutButton.tintColor = UIColor.whiteColor()
        //logoutButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Noteworthy", size: 20)!], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    override func DismissKeyboard() {
        super.DismissKeyboard()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func LogOut() {
        PFUser.logOut()
        performSegueWithIdentifier("HHToLogin", sender: nil)
    }
    
    @IBAction func HomeSweetHome(sender: UIButton) {
        DismissKeyboard()
        if(householdName.text.isEmpty || address1.text.isEmpty) {
            PopUp("Empty Fields", image: nil, msg: "You left something empty!", animate: true)
        }
        else {
            var address: String = address1.text
            if(!address2.text.isEmpty) {
                address += ", \(address2.text)"
            }
            
            println(householdName.text)
            println(address)
            if(privacy.on) {
                println("It's on!")
            }
            else {
                println("It's off!")
            }
        
            var household = PFObject(className: "Household")
            household["name"] = householdName.text
            household["createdBy"] = PFUser.currentUser()!
            household["address"] = address
            household["private"] = privacy.on
            household.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    var houseUser = PFObject(className: "Household_User")
                    houseUser["householdID"] = household
                    houseUser["userID"] = PFUser.currentUser()!
                    houseUser.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            self.PopUp("Household Created", image: nil, msg: "You're household has been created!", animate: true,  onCloseFunc: self.RedirectHomePage)
                            //Redirect to home page
                        }
                        else {
                            println("Problem, Uh-oh!!")
                            //if problem reaches here, delete household and tell user to retry
                        }
                    }
                }
                else {
                    println("Problem!!")
                    //retry creating the household
                }
            }
        }
    }
    
    func RedirectHomePage() {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("MyChoresPage") as! UITableViewController
        presentViewController(controller, animated: true, completion: nil)
    }
}
