//
//  LoginPage.swift
//  chor_mates
//
//  Created by kosta on 5/11/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit
import Parse
import QuartzCore

class LoginPage: ViewTextController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let currentUser = PFUser.currentUser()
        if(currentUser != nil) {
            HasHousehold(currentUser, msg: "Welcome back, \(currentUser!.username!)!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Login(sender: UIButton) {
        DismissKeyboard()
        
        //Validate the username and password
        if(!userName.text!.isEmpty && !password.text!.isEmpty)
        {
            PFUser.logInWithUsernameInBackground(userName.text!, password:password.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    self.HasHousehold(user, msg: "Sucessful Login! Welcome back!")
                }
                else {
                    self.PopUp("Invalid Login", image: nil, msg: "Invalid username or password! Forgot?", animate: true)
                }
            }
        }
    }
    
    // Function queries DB to see if logged in user is registered with a household.
    // If not, then redirect to household page, if so, redirect to home page
    func HasHousehold(user: PFUser?, msg: String)
    {
        if(user != nil) {
            let query = PFQuery(className: "Household_User")
            query.whereKey("userID", equalTo: user!)
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    let redirectHome = (objects!.count == 0) ? false : true
                    self.RedirectTo(redirectHome, msg: msg)
                }
                else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
    func RedirectTo(redirectHome: Bool, msg: String) {
        if(!redirectHome) {
          PopUp("Successful Login", image: nil, msg: msg, animate: true, onCloseFunc: ChangeToHouseHoldPage)
        }
        else {
            //Go to home page
            let controller = storyboard?.instantiateViewControllerWithIdentifier("TabViewController") as! UITabBarController
            presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func ChangeToHouseHoldPage() {
        performSegueWithIdentifier("LoginToHH", sender: nil)
    }
    
    @IBAction func Register(sender: UIButton) {
        userName.text = ""
        password.text = ""
        DismissKeyboard()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @IBAction func ForgotPass(sender: UIButton) {
        userName.text = ""
        password.text = ""
        DismissKeyboard()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}



