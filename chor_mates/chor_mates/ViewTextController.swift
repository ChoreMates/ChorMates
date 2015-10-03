//
//  ViewTextController.swift
//  chor_mates
//
// Template class for views that have text fields.
// Allows for you to set Return button to go to another
// text field, or run a button action (or both). Class
// also forces landscape mode, clicking outside a text
// field to dismiss the keyboard, and the pop up controller
// for each iOS device.
//
//  Created by Philip Moise on 6/21/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit

class ViewTextController: UIViewController, UITextFieldDelegate {
    
    var popViewController: PopUpViewControllerSwift!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard() {
        view.endEditing(true)
    }
    
    func PopUp(title: String, image: UIImage?, msg: String, animate: Bool, onCloseFunc: ((Void)->Void)? = nil) {
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController_iPad", bundle: nil)
        }
        else {
            if UIScreen.mainScreen().bounds.size.width > 320 {
                if UIScreen.mainScreen().scale == 3 {
                    self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController_iPhone6Plus", bundle: nil)
                }
                else {
                    self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController_iPhone6", bundle: nil)
                }
            }
            else {
                self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: nil)
            }
        }
        self.popViewController.title = title
        self.popViewController.showInView(self.view, withImage: image, withMessage: msg, animated: animate, onClose: onCloseFunc)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let nextField = textField.nextField {
            nextField.becomeFirstResponder()
        }
        if let returnKey = textField.returnKey {
            textField.resignFirstResponder()
            returnKey.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}

private var kAssociationKeyNextField: UInt8 = 0
private var kAssociationKeyNextKey: UInt8 = 0

extension UITextField {
    @IBOutlet var nextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextField) as? UITextField
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextField, newField, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    @IBOutlet var returnKey: UIButton? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextKey) as? UIButton
        }
        set(newKey) {
            objc_setAssociatedObject(self, &kAssociationKeyNextKey, newKey, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
