//

//  addRequest.swift

//  chor_mates

//

//  Created by Michael Ye on 7/6/15.

//  Copyright (c) 2015 ChorMates. All rights reserved.

//



import UIKit

import Parse

import ParseUI

class addRequest: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var yourChore: UITextField!
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
        // addRequestViewController.chorePickedTextField.text = self.selectedObject.objectId!
        
        
    }
    
    @IBAction func onPickChorePress(sender: AnyObject) {
        self.performSegueWithIdentifier("toPickChore", sender: userSwapWithID)
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toPickChore" {
            if let requestPickChoreViewController = segue.destinationViewController as? requestPickChore {
                requestPickChoreViewController.userSwapWithID = sender as! String!
            }
        }
        
    }
    
    @IBOutlet weak var chorePickedTextField: UITextField!
    
    
    @IBOutlet weak var choremateLabel: UILabel!
    
    
    
    @IBOutlet weak var choremateTextField: UITextField!
    
    
    
    var chorematesList: [PFObject] = []
    var choreSwap: String = ""
    var choreSwapWith: String = ""
    var choreSwapName: String = ""
    var userSwapWithID: String = ""
    var senderUserID: String = ""
    var fromPFObject: PFObject!
    var toPFObject: PFObject!
    
    
    @IBAction func swapPressed(sender: UIButton) {
        if(self.choremateTextField != nil && self.chorePickedTextField != nil){
            var choreRequest = PFObject(className:"Chore_Request")
            choreRequest["senderUserID"] = fromPFObject["userID"]
            choreRequest["toUserID"] = toPFObject["userID"]
            choreRequest["senderChoreID"] = fromPFObject["choreID"]
            choreRequest["toChoreID"] = toPFObject["choreID"]
            choreRequest["status"] = "pending"
            choreRequest.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                }
            }
        }
        
        
    }
    override func viewDidLoad() {
        
        self.navigationItem.title = "Send Request"
        self.chorePickedTextField.text = self.choreSwapWith
        self.yourChore.text = self.choreSwapName
        self.yourChore.textAlignment = .Center
        super.viewDidLoad()
        
        //set up picker view
        var pickerFrame: CGRect = CGRectMake(17, 52, 270, 100)
        var chorematePicker: UIPickerView = UIPickerView(frame: pickerFrame)
        chorematePicker.showsSelectionIndicator = true
        chorematePicker.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
        
        chorematePicker.delegate = self;
        chorematePicker.dataSource = self;
        chorematePicker.hidden = false;
        chorematePicker.showsSelectionIndicator = true
        self.choremateTextField.inputView = chorematePicker
        
        
        var query1 = PFQuery(className:"Household_User")
        // query2.includeKey("userID")
        query1.includeKey("householdID")
        query1.whereKey("userID", equalTo: PFUser.currentUser()!)
        
        var houseUserQuery = PFQuery(className:"Household_User")
        houseUserQuery.includeKey("userID")
        houseUserQuery.whereKey("householdID", matchesKey: "householdID", inQuery: query1)
        houseUserQuery.whereKey("userID", notEqualTo: PFUser.currentUser()!)
        houseUserQuery.findObjectsInBackgroundWithBlock {
            
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            
            
            if error == nil
                
            {
                
                // The find succeeded.
                
                println(    "Successfully retrieved \(objects!.count) scores.")
                
                // Do something with the found objects
                
                if let objects = objects as? [PFObject]
                {
                    for object: PFObject in objects
                    {
                        
                        if let pointer = object["userID"] as? PFObject {
                            
                            let fName = pointer["fName"] as! String
                            
                            let lName = pointer["lName"] as! String
                            
                            self.chorematesList.append(object)
                            
                        }
                        
                    }
                    
                    
                    
                }
                    
                else
                    
                {
                    
                    // Log details of the failure
                    
                    println("Error: \(error!) \(error!.userInfo!)")
                    
                }
                
                dispatch_async(dispatch_get_main_queue()){
                    
                    //self.chorematePicker.reloadComponent(0)
                    
                    //self.choremateTextField.reloadInputViews()
                    
                    
                    
                };
                
            }
            
        }
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissPicker")
        view.addGestureRecognizer(tap)
    }
    
    // returns the number of 'columns' to display.
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        
        return 1
        
    }
    
    
    // returns the # of rows in each component..
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return self.chorematesList.count
        
    }
    
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let pointer = chorematesList[row]["userID"] as! PFObject
        
        let fName = pointer["fName"] as! String
        
        let lName = pointer["lName"] as! String
        return fName + " " + lName
        
        
        
    }
    
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
        
    {
        let pointer = chorematesList[row]["userID"] as! PFObject
        
        let fName = pointer["fName"] as! String
        
        let lName = pointer["lName"] as! String
        choremateTextField.text = fName + " " + lName
        
        
        
        //choremateTextField.text = self.chorematesList[row]
        choremateTextField.textAlignment = .Center
        
        self.choremateTextField.resignFirstResponder()
        ///chorematePicker.hidden = true;
        
    }
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let pointer = chorematesList[row]["userID"] as! PFObject
        
        let fName = pointer["fName"] as! String
        
        let lName = pointer["lName"] as! String
        let titleData = fName + " " + lName
        
        self.userSwapWithID = pointer.objectId!
        
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.darkGrayColor()])
        return myTitle
    }
    func DismissPicker(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        if(self.choremateTextField.isFirstResponder())
        {
            view.endEditing(true)
            self.choremateTextField.resignFirstResponder()
            
        }
    }
    
    
    
    
    
    
    
    
    
}