//
//  MyChores.swift
//  chor_mates
//
//  Created by Michael Ye on 7/4/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//
// View controller for my chores tab in tab controller

import UIKit
import Parse
import ParseUI
class MyChores: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var inventoryItems = [String]()
    var choreNameToSwap : String!
    var refreshControl = UIRefreshControl()
    //separate retrieved chores into 2 lists
    var choreObjectCurrent : [PFObject] = []
    var choreObjectFuture : [PFObject] = []
    var currentUserID : String!
    
    @IBOutlet weak var choreTableView: UITableView!
    
    func retrieveObjectsFromParse()
    {
        //only retreive objects that end after previous month
        var components = NSDateComponents()
        components.setValue(-1, forComponent: NSCalendarUnit.CalendarUnitMonth);
        let date: NSDate = NSDate()
        var expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
        
        //  var userQuery = PFQuery(className:"_User")
        //  userQuery.whereKey("username", equalTo: "lol@lol.com")
        var query = PFQuery(className: "Chore_User")
        query.includeKey("choreID")
        query.includeKey("userID")
        query.whereKey("userID", equalTo: PFUser.currentUser()!)
        query.whereKey("endDate", greaterThanOrEqualTo: expirationDate!)
        query.orderByDescending("status")
        // var choreQuery = PFQuery(className: "Chore")
        //choreQuery.whereKey("objectId", matchesKey: "choreID", inQuery: query)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil
            {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as? [PFObject]
                {
                    self.choreObjectCurrent.removeAll(keepCapacity: false)
                    
                    self.choreObjectFuture.removeAll(keepCapacity: false)
                    for object: PFObject in objects
                    {
                        var dateCreated = object["endDate"] as! NSDate?
                        var components = NSDateComponents()
                        components.setValue(7, forComponent: NSCalendarUnit.CalendarUnitDay);
                        let date: NSDate = NSDate()
                        
                        var expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
                        
                        //if the chore ends within a week from today
                        if (dateCreated!.compare(expirationDate!) == NSComparisonResult.OrderedAscending) && (dateCreated!.compare(date) == NSComparisonResult.OrderedDescending)
                        {
                            self.choreObjectCurrent.append(object)
                        }
                            //if the chore ends at a later time (more than a week from today)
                        else if (dateCreated!.compare(expirationDate!) == NSComparisonResult.OrderedDescending) && (dateCreated!.compare(date) == NSComparisonResult.OrderedDescending)
                        {
                            self.choreObjectFuture.append(object)
                        }
                        
                    }
                }
                self.choreTableView.reloadData();
            }
            else
            {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
        
        
    }
    override func viewDidAppear(animated: Bool) {
        
        self.choreTableView.reloadData()
        retrieveObjectsFromParse()
    }
    
    override func viewDidLoad() {
        
        self.navigationItem.title = "My Chores"
        super.viewDidLoad()
        self.choreTableView.reloadData()
        
        //pull to refresh table view control
        refreshControl.addTarget(self, action: Selector("refreshTableView:"), forControlEvents: UIControlEvents.ValueChanged)
        choreTableView.addSubview(refreshControl)
        
        
        choreTableView.delegate = self
        choreTableView.dataSource = self
        
        
        
        //hide empty table rows
        var tblView =  UIView(frame: CGRectZero)
        choreTableView.tableFooterView = tblView
        choreTableView.tableFooterView!.hidden = true
        choreTableView.backgroundColor = UIColor.clearColor()
        
        retrieveObjectsFromParse()
        
    }
    
    func refreshTableView(sender:AnyObject)
    {
        self.choreTableView.reloadData()
        retrieveObjectsFromParse()
        self.refreshControl.endRefreshing()
    }
    
    
    //for swipe actions on table cell
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        
        var currChore: PFObject!
        if(indexPath.section == 0)
        {
            
            currChore = self.choreObjectCurrent[indexPath.row]
        }
        else if(indexPath.section == 1)
        {
            currChore = self.choreObjectFuture[indexPath.row]
        }
        //request action
        var requestAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Request" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            if(indexPath.section == 0)
            {
                if let pointer = self.choreObjectCurrent[indexPath.row]["choreID"] as? PFObject {
                    self.choreNameToSwap = pointer["choreName"] as! String!
                    
                }
                if let pointer = self.choreObjectCurrent[indexPath.row]["userID"] as? PFObject {
                    self.currentUserID = pointer.objectId
                }
                
                self.performSegueWithIdentifier("toRequest", sender: self.choreObjectCurrent[indexPath.row])
            }
            else{
                
                if let pointer = self.choreObjectFuture[indexPath.row]["choreID"] as? PFObject {
                    self.choreNameToSwap = pointer["choreName"] as! String!
                }
                if let pointer = self.choreObjectFuture[indexPath.row]["userID"] as? PFObject {
                    self.currentUserID = pointer.objectId
                }
                self.performSegueWithIdentifier("toRequest", sender: self.choreObjectFuture[indexPath.row])
            }
            
        })
        //expense action
        var expenseAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Expense" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            if(indexPath.section == 0)
            {
                self.performSegueWithIdentifier("toExpense", sender: self.choreObjectCurrent[indexPath.row])
            }
            else{
                
                self.performSegueWithIdentifier("toExpense", sender: self.choreObjectFuture[indexPath.row])
            }
            
            
            
        })
        //done chore action
        var doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Done" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let doneMenu = UIAlertController(title: nil, message: "Confirm Completion", preferredStyle: .Alert)
            
            let appRateAction = UIAlertAction(title: "Completed", style: UIAlertActionStyle.Default)
                { action -> Void in
                    if(indexPath.section == 0)
                    {
                        
                        
                        currChore["status"] = "completed"
                        currChore["completedDate"] = NSDate()
                        currChore.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                println("The object has been saved.")
                            } else {
                                // There was a problem, check error.description
                            }
                        }
                        
                    }
                    else if(indexPath.section == 1)
                    {
                        
                        
                        currChore["status"] = "completed"
                        currChore["completedDate"] = NSDate()
                        currChore.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                println("The object has been saved.")
                            } else {
                                // There was a problem, check error.description
                            }
                        }
                        
                    }
                    self.choreTableView.reloadData()
                    self.retrieveObjectsFromParse()
                    
                    
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            doneMenu.addAction(appRateAction)
            doneMenu.addAction(cancelAction)
            
            
            
            self.presentViewController(doneMenu, animated: true, completion: nil)
        })
        requestAction.backgroundColor = UIColor(red: 0.5, green: 0.4, blue: 0.4, alpha: 1.0)
        expenseAction.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.5, alpha: 1.0)
        doneAction.backgroundColor = UIColor(red: 0.3, green: 0.4, blue: 0.2, alpha: 1.0)
        
        //if the chore is still pending
        if(currChore["status"] as! String! == "pending")
        {
            return [requestAction,expenseAction,doneAction]
        }
            //if the chore is completed
        else
        {
            return [expenseAction]
        }
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            //return self.choreObject.count
            //return getNumberOfRows(self.choreObject,option: 0)
            return self.choreObjectCurrent.count
        }
        
        //return self.choreObject.count
        return self.choreObjectFuture.count
        
        //  return groupList.count
    }
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        
        return 2
    }
    //section headers
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "This Week"
        }
        return "Upcoming"
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        var cell:MyChoreTableCell = tableView.dequeueReusableCellWithIdentifier("Cell2") as! MyChoreTableCell
        
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        
        
        if( indexPath.section == 0){
            
            var dateCreated = choreObjectCurrent[indexPath.row]["endDate"] as! NSDate?
            var components = NSDateComponents()
            components.setValue(7, forComponent: NSCalendarUnit.CalendarUnitDay);
            let date: NSDate = NSDate()
            
            var expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
            
            if dateCreated!.compare(expirationDate!) == NSComparisonResult.OrderedAscending
            {
                if let pointer = choreObjectCurrent[indexPath.row]["choreID"] as? PFObject {
                    cell.choreName?.text = pointer["choreName"] as! String!
                    
                }
                if( choreObjectCurrent[indexPath.row]["status"] as! String! == "pending")
                {
                    var dateCreated = choreObjectCurrent[indexPath.row]["endDate"] as! NSDate?
                    var dateFormat = NSDateFormatter()
                    dateFormat.dateFormat = "MM.dd.yyyy"
                    cell.choreDueDate?.text = "Due " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
                    
                }
                else
                {
                    var dateCreated = choreObjectCurrent[indexPath.row]["completedDate"] as! NSDate?
                    var dateFormat = NSDateFormatter()
                    dateFormat.dateFormat = "MM.dd.yyyy"
                    cell.choreDueDate?.text = "Completed " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
                    
                }
                if(choreObjectCurrent[indexPath.row]["expenseAmount"] != nil)
                {
                    cell.choreExpense.text = choreObjectCurrent[indexPath.row]["expenseAmount"] as! String!
                }
                else
                {
                    cell.choreExpense.text = "$0"
                    
                }
            }
        }
        else if(indexPath.section == 1){
            
            var dateCreated = choreObjectFuture[indexPath.row]["endDate"] as! NSDate?
            var components = NSDateComponents()
            components.setValue(7, forComponent: NSCalendarUnit.CalendarUnitDay);
            let date: NSDate = NSDate()
            
            var expirationDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
            
            if dateCreated!.compare(expirationDate!) == NSComparisonResult.OrderedDescending
            {
                
                if let pointer = choreObjectFuture[indexPath.row]["choreID"] as? PFObject {
                    cell.choreName?.text = pointer["choreName"] as! String!
                    
                }
                
                
                
                if( choreObjectFuture[indexPath.row]["status"] as! String! == "pending"){
                    var dateCreated = choreObjectFuture[indexPath.row]["endDate"] as! NSDate?
                    var dateFormat = NSDateFormatter()
                    dateFormat.dateFormat = "MM.dd.yyyy"
                    
                    
                    cell.choreDueDate?.text = "Due " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
                    
                }
                else{
                    var dateCreated = choreObjectFuture[indexPath.row]["completedDate"] as! NSDate?
                    var dateFormat = NSDateFormatter()
                    dateFormat.dateFormat = "MM.dd.yyyy"
                    
                    
                    cell.choreDueDate?.text = "Completed " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
                    
                }
                
                
                if(choreObjectFuture[indexPath.row]["expenseAmount"] != nil)
                {
                    cell.choreExpense.text = choreObjectFuture[indexPath.row]["expenseAmount"] as! String!
                }
                else
                {
                    cell.choreExpense.text = "$0"
                    
                }
            }
            
            
            
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toExpense" {
            if let addExpenseViewController = segue.destinationViewController as? addExpense {
                addExpenseViewController.choreID = sender.objectId as String!
                
            }
        }
        else if segue.identifier == "toRequest" {
            if let addRequestViewController = segue.destinationViewController as? addRequest {
                addRequestViewController.choreSwap = sender.objectId as String!
                addRequestViewController.choreSwapName  = choreNameToSwap
                addRequestViewController.fromPFObject = sender as! PFObject!
                addRequestViewController.senderUserID = currentUserID
            }
        }
        
    }
    
    
}