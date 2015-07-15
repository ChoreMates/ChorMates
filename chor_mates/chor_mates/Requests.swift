//
//  Requests.swift
//  chor_mates
//
//  Created by Philip Moise on 7/13/15.
//  Copyright (c) 2015 ChorMates. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class Requests: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var requestsTable: UITableView!
    
    var refreshControl = UIRefreshControl()
    var inReq : [PFObject] = []
    var outReq : [PFObject] = []
    var householdReq : [PFObject] = []
    
    var myHousehold: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationItem.title = "Requests"
        requestsTable.reloadData()
        
        //pull to refresh table view control
        refreshControl.addTarget(self, action: Selector("refreshTableView:"), forControlEvents: UIControlEvents.ValueChanged)
        requestsTable.addSubview(refreshControl)
        
        requestsTable.delegate = self
        requestsTable.dataSource = self
        
        //hide empty table rows
        var tblView =  UIView(frame: CGRectZero)
        requestsTable.tableFooterView = tblView
        requestsTable.tableFooterView!.hidden = true
        requestsTable.backgroundColor = UIColor.clearColor()
        
        retrieveObjectsFromParse()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.requestsTable.reloadData()
        retrieveObjectsFromParse()
    }
    
    //section headers
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Household Requests"
        }
        else if section == 1 {
            return "Incoming Requests"
        }
        else if section == 2 {
            return "Outgoing Requests"
        }
        else {
            println("Not a section!")
            return "Fake!"
        }
    }
    
    func refreshTableView(sender:AnyObject)
    {
        self.requestsTable.reloadData()
        retrieveObjectsFromParse()
        self.refreshControl.endRefreshing()
    }
    
    func retrieveObjectsFromParse()
    {
        let me = PFUser.currentUser()!
        var count = 0;
        
        var inQuery = PFQuery(className: "Chore_Request")
        inQuery.includeKey("senderChoreID")
        inQuery.includeKey("senderUserID")
        inQuery.includeKey("toChoreID")
        inQuery.whereKey("toUserID", equalTo: me)
        inQuery.orderByDescending("createdAt")
        inQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if(objects!.count == 0) {
                    //++count
                }
                else {
                    if let incoming = objects as? [PFObject] {
                        self.inReq.removeAll(keepCapacity: false)
                        
                        for request in incoming {
                            self.inReq.append(request)
                        }
                        
                        //++count
                        //if(count == 3) {
                            self.requestsTable.reloadData()
                        //}
                    }
                }
            }
            else {
                println("Error Incoming! \(error?.description)")
            }
        }
        
        var outQuery = PFQuery(className: "Chore_Request")
        outQuery.includeKey("senderChoreID")
        outQuery.includeKey("toChoreID")
        outQuery.includeKey("toUserID")
        outQuery.whereKey("senderUserID", equalTo: me)
        outQuery.orderByDescending("createdAt")
        outQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if(objects!.count == 0) {
                    //++count
                }
                else {
                    if let outgoing = objects as? [PFObject] {
                        self.outReq.removeAll(keepCapacity: false)
                        
                        for request in outgoing {
                            self.outReq.append(request)
                        }
                        
                        //++count
                        //if(count == 3) {
                            self.requestsTable.reloadData()
                        //}
                    }
                }
            }
            else {
                println("Error Outgoing! \(error?.description)")
            }
        }
        
        var hhUserQuery = PFQuery(className: "Household_User")
        hhUserQuery.includeKey("householdID")
        hhUserQuery.whereKey("userID", equalTo: me)
        hhUserQuery.findObjectsInBackgroundWithBlock {
            (usersHH: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if(usersHH!.count == 0) {
                    println("None found! Weird....")
                }
                else {
                    if let usersHH = usersHH as? [PFObject] {
                        var userHH = usersHH.first!
                        var hh = userHH["householdID"]! as! PFObject
                        
                        self.myHousehold = hh
                        var hhQuery = PFQuery(className: "HouseInvitation")
                        hhQuery.includeKey("userID")
                        hhQuery.orderByDescending("createdAt")
                        hhQuery.whereKey("householdID", equalTo: userHH["householdID"]!)
                        hhQuery.findObjectsInBackgroundWithBlock {
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            if error == nil {
                                if(objects!.count == 0) {
                                    //++count
                                }
                                else {
                                    if let houseRequests = objects as? [PFObject] {
                                        self.householdReq.removeAll(keepCapacity: false)
                                        
                                        for request in houseRequests {
                                            self.householdReq.append(request)
                                        }
                                        
                                        //++count
                                        //if(count == 3) {
                                            self.requestsTable.reloadData()
                                        //}
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                println("Error Household! \(error?.description)")
            }
        }
    }
    
    
    //for swipe actions on table cell
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
//        
//        var currChore: PFObject!
//        if(indexPath.section == 0)
//        {
//            
//            //currChore = self.choreObjectCurrent[indexPath.row]
//        }
//        else if(indexPath.section == 1)
//        {
//            //currChore = self.choreObjectFuture[indexPath.row]
//        }
//        //request action
//        var requestAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Request" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
//            
//            if(indexPath.section == 0)
//            {
//                if let pointer = self.choreObjectCurrent[indexPath.row]["choreID"] as? PFObject {
//                    self.choreNameToSwap = pointer["choreName"] as! String!
//                    
//                }
//                if let pointer = self.choreObjectCurrent[indexPath.row]["userID"] as? PFObject {
//                    self.currentUserID = pointer.objectId
//                }
//                
//                self.performSegueWithIdentifier("toRequest", sender: self.choreObjectCurrent[indexPath.row])
//            }
//            else{
//                
//                if let pointer = self.choreObjectFuture[indexPath.row]["choreID"] as? PFObject {
//                    self.choreNameToSwap = pointer["choreName"] as! String!
//                }
//                if let pointer = self.choreObjectFuture[indexPath.row]["userID"] as? PFObject {
//                    self.currentUserID = pointer.objectId
//                }
//                self.performSegueWithIdentifier("toRequest", sender: self.choreObjectFuture[indexPath.row])
//            }
//            
//        })
        //expense action
//        var expenseAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Expense" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
//            
//            if(indexPath.section == 0)
//            {
//                self.performSegueWithIdentifier("toExpense", sender: self.choreObjectCurrent[indexPath.row])
//            }
//            else{
//                self.performSegueWithIdentifier("toExpense", sender: self.choreObjectFuture[indexPath.row])
//            }
//        })
//        //done chore action
//        var doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Done" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
//            
//            let doneMenu = UIAlertController(title: nil, message: "Confirm Completion", preferredStyle: .Alert)
//            
//            let appRateAction = UIAlertAction(title: "Completed", style: UIAlertActionStyle.Default)
//                { action -> Void in
//                    if(indexPath.section == 0)
//                    {
//                        currChore["status"] = "completed"
//                        currChore["completedDate"] = NSDate()
//                        currChore.saveInBackgroundWithBlock {
//                            (success: Bool, error: NSError?) -> Void in
//                            if (success) {
//                                println("The object has been saved.")
//                            } else {
//                                // There was a problem, check error.description
//                            }
//                        }
//                    }
//                    else if(indexPath.section == 1)
//                    {
//                        currChore["status"] = "completed"
//                        currChore["completedDate"] = NSDate()
//                        currChore.saveInBackgroundWithBlock {
//                            (success: Bool, error: NSError?) -> Void in
//                            if (success) {
//                                println("The object has been saved.")
//                            } else {
//                                // There was a problem, check error.description
//                            }
//                        }
//                    }
//                    self.requestsTable.reloadData()
//                    self.retrieveObjectsFromParse()
//            }
//            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
//            
//            doneMenu.addAction(appRateAction)
//            doneMenu.addAction(cancelAction)
//            
//            self.presentViewController(doneMenu, animated: true, completion: nil)
//        })
//        requestAction.backgroundColor = UIColor(red: 0.5, green: 0.4, blue: 0.4, alpha: 1.0)
//        expenseAction.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.5, alpha: 1.0)
//        doneAction.backgroundColor = UIColor(red: 0.3, green: 0.4, blue: 0.2, alpha: 1.0)
        
//        //if the chore is still pending
//        if(currChore["status"] as! String! == "pending")
//        {
//            return [requestAction,expenseAction,doneAction]
//        }
//            //if the chore is completed
//        else
//        {
//            return [expenseAction]
//        }
//    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return index
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return self.householdReq.count
        }
        else if section == 1 {
            return self.inReq.count
        }
        else { //section == 2
            return self.outReq.count
        }
    }
    
    func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        var cell:RequestTableCell = tableView.dequeueReusableCellWithIdentifier("RequestCell") as! RequestTableCell
        
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        
        if( indexPath.section == 0) {
            if let pointer = householdReq[indexPath.row]["userID"] as? PFUser {
                var fName = pointer["fName"] as! String
                var lName = pointer["lName"] as! String
                let name = fName + " " + lName
                cell.reqText.text! = "Let me in!"
                cell.reqText2.text! = name
                
                cell.from.text! = pointer.username!
            }
            
            var dateCreated = householdReq[indexPath.row].createdAt
            var dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM.dd.yyyy"
            cell.reqDate.text! = "Reqested: " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
        }
        else if(indexPath.section == 1) {
            if let fromChore = inReq[indexPath.row]["senderChoreID"] as? PFObject {
                cell.reqText.text! = fromChore["choreName"] as! String
            }
            if let forChore = inReq[indexPath.row]["toChoreID"] as? PFObject {
                cell.reqText2.text! = "For: " + (forChore["choreName"] as! String)
            }
            if let fromPerson = inReq[indexPath.row]["senderUserID"] as? PFUser {
                cell.from.text! = (fromPerson["fName"]! as! String)
            }
            
            var dateCreated = inReq[indexPath.row].createdAt
            var dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM.dd.yyyy"
            cell.reqDate.text! = "Requested: " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
        }
        else if(indexPath.section == 2) {
            if let toChore = outReq[indexPath.row]["senderChoreID"] as? PFObject {
                cell.reqText.text! = toChore["choreName"] as! String
            }
            if let sentChore = outReq[indexPath.row]["toChoreID"] as? PFObject {
                cell.reqText2.text! = "For: " + (sentChore["choreName"] as! String)
            }
            if let toPerson = outReq[indexPath.row]["toUserID"] as? PFUser {
                cell.from.text! = (toPerson["fName"]! as! String)
            }
            
            var dateCreated = outReq[indexPath.row].createdAt
            var dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM.dd.yyyy"
            cell.reqDate.text! = "Requested: " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
        }
        return cell
    }
}
