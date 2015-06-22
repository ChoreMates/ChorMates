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
        var currentUser = PFUser.currentUser()
        if(currentUser != nil){
          println("Welcome back, \(currentUser?.username)!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func Login(sender: UIButton) {
        DismissKeyboard()
        
        //Validate the username and password
        if(!userName.text.isEmpty && !password.text.isEmpty)
        {
            PFUser.logInWithUsernameInBackground(userName.text, password:password.text) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    self.PopUp("Successful Login", image: nil, msg: "Sucessful Login! Welcome, \(user!.username!)!", animate: true)
                    //Pop up needs to be replaced with redirect to either home page, or create/join household
                }
                else {
                    self.PopUp("Invalid Login", image: nil, msg: "Invalid username or password! Forgot?", animate: true)
                }
            }
            PFUser.logOut()
        }
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



