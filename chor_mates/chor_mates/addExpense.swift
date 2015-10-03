//
//  addExpense.swift
//  chor_mates
//
//  Created by Michael Ye on 7/6/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

//
//  MyChores.swift
//  chor_mates
//
//  Created by Michael Ye on 7/4/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit
import Parse
import ParseUI
class addExpense: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var choreID: String = ""
    var suppliesList: [String] = []
    var currPFObject: PFObject?
    
    
    @IBOutlet weak var amountLabel: UITextField!
    
    @IBAction func addExpenseButton(sender: UIButton) {
        var inputTextField: UITextField?
        func addTextField(textField: UITextField!){
            // add the text field and make the result global
            textField.placeholder = "Item"
            inputTextField = textField
            
        }
        func addedItemAction(alert: UIAlertAction!){
            // store the new word
            if(inputTextField != nil)
            {
                self.suppliesList.append(inputTextField!.text!)
                let currChore: PFObject = self.currPFObject!
                currChore["expensesList"] = self.suppliesList
                currChore.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("The object has been saved.")
                    } else {
                        // There was a problem, check error.description
                    }
                }
                self.suppliesTableView.reloadData()
            }
        }
        // display an alert
        let newWordPrompt = UIAlertController(title: "Enter Expense Item", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        newWordPrompt.addTextFieldWithConfigurationHandler(addTextField)
        newWordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        newWordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: addedItemAction))
        presentViewController(newWordPrompt, animated: true, completion: nil)
    }
    @IBOutlet weak var suppliesTableView: UITableView!
    override func viewDidAppear(animated: Bool) {
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        
        self.suppliesTableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        
        
        //remove empty cells from table view
        let tblView =  UIView(frame: CGRectZero)
        suppliesTableView.tableFooterView = tblView
        suppliesTableView.tableFooterView!.hidden = true
        suppliesTableView.backgroundColor = UIColor.clearColor()
        
        //remove key pad when elsewhere tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        let query = PFQuery(className: "Chore_User")
        query.whereKey("objectId", equalTo: choreID)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil
            {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as? [PFObject]
                {
                    for object: PFObject in objects
                    {
                        self.amountLabel.text = object["expenseAmount"] as? String
                        self.currPFObject = object
                        if(object["expensesList"] != nil){
                            self.suppliesList = object["expensesList"] as! [String]
                            print (self.suppliesList[0])
                        }
                        
                    }
                }
                
            }
            else
            {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            dispatch_async(dispatch_get_main_queue()){
                self.suppliesTableView.reloadData();
                
                
            };
            
        }
        
    }
    override func viewDidLoad() {
        suppliesTableView.dataSource = self
        suppliesTableView.delegate = self
        self.navigationItem.title = "Add Expenses"
        
        
        
        
        
    }
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.suppliesList.count
    }
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("SupplyCell")! as UITableViewCell
        
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        
        cell.textLabel!.text = suppliesList[indexPath.row]
        //cell.textLabel!.text  = "hello"
        return cell
    }
    
    func DismissKeyboard(){
        
        if(self.amountLabel.isFirstResponder())
        {
            view.endEditing(true)
            if(self.amountLabel.text!.rangeOfString("$") == nil){
                
                let formatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                formatter.locale = NSLocale(localeIdentifier: "en_US")
                let numberFromField = (NSString(string: self.amountLabel.text!).doubleValue)
                self.amountLabel.text = formatter.stringFromNumber(numberFromField)
                
            }
            //save the amount typed by the user when focus is changed
            self.amountLabel.resignFirstResponder()
            let currChore: PFObject = self.currPFObject!
            if(currChore["expenseAmount"] as! String! != self.amountLabel.text)
            {
                currChore["expenseAmount"] = self.amountLabel.text
                currChore.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        print("The object has been saved.")
                    } else {
                        // There was a problem, check error.description
                    }
                }
            }
            
        }
    }
    
    //delete swipe action, delete item from database table
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            suppliesList.removeAtIndex(indexPath.row)
            suppliesTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            let currChore: PFObject = self.currPFObject!
            currChore["expensesList"] = self.suppliesList
            currChore.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    print("The object has been saved.")
                } else {
                    // There was a problem, check error.description
                }
            }
            
        }
    }
    
    
}