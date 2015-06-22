//
//  ViewController.swift
//  chor_mates
//
//  Created by kosta on 5/11/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var forgotPassword: UILabel!
    var fPColor: UIColor = UIColor.redColor()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fPColor = forgotPassword.textColor
        
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
        //Validate the username and password
        if(!userName.text.isEmpty){
            println("Username: \(userName.text)")
        }
        if(!password.text.isEmpty){
            println("Password: \(password.text)")
        }
        if(userName.text.isEmpty || password.text.isEmpty)
        {
            let incorrect:String = "Incorrect username or password! Forgot?"
            println(incorrect)
            forgotPassword.text = incorrect
            forgotPassword.textColor = UIColor.redColor()
            return
        }
        forgotPassword.text = "Forgot your password?"
        forgotPassword.textColor = fPColor
        
        PFUser.logInWithUsernameInBackground(userName.text, password:password.text) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                println("Successfull Login!")
            } else {
                println("Login Failed!\nWhy?:\n\n\(error?.description)")
            }
        }
        PFUser.logOut()
    }
    
    @IBAction func Register(sender: UIButton) {
        let account = 	PFUser()
        
        account.username = "Phil"
        account.password = "Me Up"
        account.email = "swaggmasta@swag.com"
        account.signUpInBackgroundWithBlock{ (success: Bool, error: NSError?) -> Void in
            if(success) {
                println("Object is saved!")
            }
            else {
                println(error?.description)
            }
        }
    }
}

