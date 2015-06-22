//
//  ForgotPage.swift
//  chor_mates
//
//  Created by Philip Moise on 6/21/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit
import Parse

class ForgotPage: ViewTextController
{
    @IBOutlet weak var email: UITextField!
    
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
    
    @IBAction func SendPassword(sender: UIButton) {
        DismissKeyboard()
        if(!email.text.isEmpty)
        {
            PFUser.requestPasswordResetForEmailInBackground(email.text) {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo?["error"] as? String
                    self.PopUp("Can't Find E-Mail", image: nil, msg: errorString!, animate: true)
                }
                else {
                    self.PopUp("E-Mail Sent", image: nil, msg: "Sent reset to e-mail address.", animate: true)
                }
            }
        }
    }
}
