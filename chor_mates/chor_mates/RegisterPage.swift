//
//  RegisterPage.swift
//  chor_mates
//
//  Created by Philip Moise on 6/20/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit
import Parse

class RegisterPage: ViewTextController {
    
    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var valPass: UITextField!
    @IBOutlet weak var allSet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func DismissKeyboard() {
        super.DismissKeyboard()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParentViewController()){
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    @IBAction func AllSet(sender: UIButton) {
        DismissKeyboard()
        if(fName.text!.isEmpty || lName.text!.isEmpty || email.text!.isEmpty || password.text!.isEmpty || valPass.text!.isEmpty) {
            PopUp("Empty Fields", image: nil, msg: "You left something empty!", animate: true)
        }
        else if(password.text != valPass.text)
        {
            PopUp("Mis-matching Pass", image: nil, msg: "You have mis-matching passwords!", animate: true)
        }
        else if(email.text!.rangeOfString(".") == nil || email.text!.rangeOfString("@") == nil)
        {
            PopUp("E-Mail Error", image: nil, msg: "E-Mail is not in the proper format!", animate: true)
        }
        else
        {
            //All's good
            let user = PFUser()
            user.username = email.text
            user.email = email.text
            user.password = password.text
            user["fName"] = fName.text
            user["lName"] = lName.text
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo["error"] as? String
                    self.PopUp("Sign Up Error", image: nil, msg: errorString!, animate: true)
                    print(errorString!)
                }
                else {
                    // Log new user in automatically
                    PFUser.logInWithUsernameInBackground(self.email.text!, password: self.password.text!) {
                        (user: PFUser?, error: NSError?) -> Void in
                        if user != nil {
                            self.PopUp("Sign Up Complete", image: nil, msg: "Sign Up Complete!\nE-Mail verification sent.", animate: true, onCloseFunc: self.ChangeToHouseHoldPage)
                        }
                        else {
                            self.PopUp("Problem Logging in", image: nil, msg: "Problem logging in. Try logging in.", animate: true, onCloseFunc: self.ChangeToLoginPage)
                        }
                    }
                }
            }
        }
    }
    
    func ChangeToHouseHoldPage() {
        performSegueWithIdentifier("RegisterToHH", sender: nil)
    }
    
    func ChangeToLoginPage() {
        performSegueWithIdentifier("RegisterToLogin", sender: nil)
    }
}