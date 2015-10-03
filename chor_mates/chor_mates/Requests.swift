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
        let tblView =  UIView(frame: CGRectZero)
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
            print("Not a section!")
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
        //var count = 0;
        
        let inQuery = PFQuery(className: "Chore_Request")
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
                    self.inReq.removeAll(keepCapacity: false)
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
                print("Error Incoming! \(error?.description)")
            }
        }
        
        let outQuery = PFQuery(className: "Chore_Request")
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
                    self.outReq.removeAll(keepCapacity: false)
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
                print("Error Outgoing! \(error?.description)")
            }
        }
        
        let hhUserQuery = PFQuery(className: "Household_User")
        hhUserQuery.includeKey("householdID")
        hhUserQuery.whereKey("userID", equalTo: me)
        hhUserQuery.findObjectsInBackgroundWithBlock {
            (usersHH: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if(usersHH!.count == 0) {
                    print("None found! Weird....")
                }
                else {
                    if let usersHH = usersHH as? [PFObject] {
                        let userHH = usersHH.first!
                        let hh = userHH["householdID"]! as! PFObject
                        
                        self.myHousehold = hh
                        let hhQuery = PFQuery(className: "HouseInvitation")
                        hhQuery.includeKey("userID")
                        hhQuery.orderByDescending("createdAt")
                        hhQuery.whereKey("householdID", equalTo: userHH["householdID"]!)
                        hhQuery.findObjectsInBackgroundWithBlock {
                            (objects: [AnyObject]?, error: NSError?) -> Void in
                            if error == nil {
                                if(objects!.count == 0) {
                                    //++count
                                    self.householdReq.removeAll(keepCapacity: false)
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
                print("Error Household! \(error?.description)")
            }
        }
    }
    
    
    //for swipe actions on table cell
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        
        var currObj: PFObject!
        
        if(indexPath.section == 0)
        {
            currObj = householdReq[indexPath.row]
        }
        else if(indexPath.section == 1)
        {
            currObj = inReq[indexPath.row]
        }
        else { //indexPath.section == 2
            currObj = outReq[indexPath.row]
        }
        
        if(indexPath.section == 0 || indexPath.section == 1) {
            let acceptAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Accept" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
                let alertBox = UIAlertController(title: nil, message: "Accept Request", preferredStyle: .Alert)
                
                let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) {
                    action -> Void in
                    //if Household request, delete from HouseholdInvitationTable, add to Household_User Table
                    var user: PFUser?
                    var myNewChore: PFObject?
                    var myOldChore: PFObject?
                    if(indexPath.section == 0) {
                        user = currObj["userID"]! as? PFUser
                    }
                        
                        //If Incoming request, delete from Chore_Request Table, modify Chore_User Table
                    else { //indexPath.section == 1
                        user = currObj["senderUserID"]! as? PFUser
                        myNewChore = currObj["senderChoreID"]! as? PFObject
                        myOldChore = currObj["toChoreID"]! as? PFObject
                    }
                    
                    currObj.deleteInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("The object has been removed. Going to start the save!")
                            
                            if(indexPath.section == 0) {
                                let userHH = PFObject(className: "Household_User")
                                userHH["userID"] = user!
                                userHH["householdID"] = self.myHousehold!
                                userHH.saveInBackgroundWithBlock {
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        print("The object has been saved!")
                                        self.refreshTableView(PFUser.currentUser()!)
                                    }
                                    else {
                                        print("Error!! \(error?.description)")
                                    }
                                }
                            }
                            else { //indexPath.section == 2
                                //Assign other chore to me
                                let query = PFQuery(className: "Chore_User")
                                query.whereKey("choreID", equalTo: myNewChore!)
                                query.whereKey("userID", equalTo: user!)
                                query.findObjectsInBackgroundWithBlock {
                                    (choreUsers: [AnyObject]?, error: NSError?) -> Void in
                                    if error == nil {
                                        if(choreUsers!.count == 0) {
                                            print("Can't find my new chore!")
                                        }
                                        else {
                                            print("Found something goooood!")
                                            if let choreUsers = choreUsers as? [PFObject] {
                                                let choreUser = choreUsers.first!
                                                choreUser["swapID"] = PFUser.currentUser()!
                                                choreUser.saveInBackgroundWithBlock {
                                                    (success: Bool, error: NSError?) -> Void in
                                                    if (success) {
                                                        print("Got his chore!")
                                                    }
                                                    else {
                                                        print("Error?!?! \(error?.description)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        print("Error!?! \(error?.description)")
                                    }
                                }
                                //Assign my chore to other
                                let query2 = PFQuery(className: "Chore_User")
                                query2.whereKey("choreID", equalTo: myOldChore!)
                                query2.whereKey("userID", equalTo: PFUser.currentUser()!)
                                query2.findObjectsInBackgroundWithBlock {
                                    (choreUsers: [AnyObject]?, error: NSError?) -> Void in
                                    if error == nil {
                                        if(choreUsers!.count == 0) {
                                            print("Can't find my old chore!")
                                        }
                                        else {
                                            if let choreUsers = choreUsers as? [PFObject] {
                                                let choreUser = choreUsers.first!
                                                choreUser["swapID"] = user!
                                                choreUser.saveInBackgroundWithBlock {
                                                    (success: Bool, error: NSError?) -> Void in
                                                    if (success) {
                                                        print("Gave him my chore!")
                                                        self.refreshTableView(PFUser.currentUser()!)
                                                    }
                                                    else {
                                                        print("Error?!?! \(error?.description)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        print("Error!?! \(error?.description)")
                                    }
                                }
                            }
                        }
                        else {
                            print("Error?! \(error?.description)")
                        }
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
                alertBox.addAction(confirmAction)
                alertBox.addAction(cancelAction)
                
                self.presentViewController(alertBox, animated: true, completion: nil)
            })
            
            let rejectAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Reject" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
                let alertBox = UIAlertController(title: nil, message: "Reject Request", preferredStyle: .Alert)
                
                let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default)
                    { action -> Void in
                        //remove from Chore_Request Table
                        currObj.deleteInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("The object has been removed.")
                                
                                self.refreshTableView(PFUser.currentUser()!)
                            }
                            else {
                                print("Error?! \(error?.description)")
                            }
                        }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
                alertBox.addAction(confirmAction)
                alertBox.addAction(cancelAction)
                
                self.presentViewController(alertBox, animated: true, completion: nil)
            })
            
            acceptAction.backgroundColor = UIColor(red: 0.1, green: 0.7, blue: 0.2, alpha: 1.0)
            rejectAction.backgroundColor = UIColor(red: 0.9, green: 0.1, blue: 0.2, alpha: 1.0)
            return [acceptAction, rejectAction]
        }
        else { //indexPath.section == 2
            let cancelAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Cancel" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
                let alertBox = UIAlertController(title: nil, message: "Cancel Request", preferredStyle: .Alert)
                
                let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default)
                    { action -> Void in
                        //delete currObj from database
                        currObj.deleteInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                print("The object has been removed.")
                                
                                self.refreshTableView(PFUser.currentUser()!)
                            }
                            else {
                                print("Error?! \(error?.description)")
                            }
                        }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                
                alertBox.addAction(confirmAction)
                alertBox.addAction(cancelAction)
                
                self.presentViewController(alertBox, animated: true, completion: nil)
            })
            
            cancelAction.backgroundColor = UIColor(red: 0.9, green: 0.1, blue: 0.2, alpha: 1.0)
            return [cancelAction]
        }
    }
    
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
        
        let cell:RequestTableCell = tableView.dequeueReusableCellWithIdentifier("RequestCell") as! RequestTableCell
        
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        
        if( indexPath.section == 0 && householdReq.count != 0) {
            if let pointer = householdReq[indexPath.row]["userID"] as? PFUser {
                let fName = pointer["fName"] as! String
                let lName = pointer["lName"] as! String
                let name = fName + " " + lName
                cell.reqText.text! = "Let me in!"
                cell.reqText2.text! = name
                
                cell.from.text! = pointer.username!
            }
            
            let dateCreated = householdReq[indexPath.row].createdAt
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM.dd.yyyy"
            cell.reqDate.text! = "Reqested: " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as String)
        }
        else if(indexPath.section == 1 && inReq.count != 0) {
            if let fromChore = inReq[indexPath.row]["senderChoreID"] as? PFObject {
                cell.reqText.text! = fromChore["choreName"] as! String
            }
            if let forChore = inReq[indexPath.row]["toChoreID"] as? PFObject {
                cell.reqText2.text! = "For: " + (forChore["choreName"] as! String)
            }
            if let fromPerson = inReq[indexPath.row]["senderUserID"] as? PFUser {
                cell.from.text! = (fromPerson["fName"]! as! String)
            }
            
            let dateCreated = inReq[indexPath.row].createdAt
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM.dd.yyyy"
            cell.reqDate.text! = "Requested: " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as String)
        }
        else if(indexPath.section == 2 && outReq.count != 0) {
            if let toChore = outReq[indexPath.row]["senderChoreID"] as? PFObject {
                cell.reqText.text! = toChore["choreName"] as! String
            }
            if let sentChore = outReq[indexPath.row]["toChoreID"] as? PFObject {
                cell.reqText2.text! = "For: " + (sentChore["choreName"] as! String)
            }
            if let toPerson = outReq[indexPath.row]["toUserID"] as? PFUser {
                cell.from.text! = (toPerson["fName"]! as! String)
            }
            
            let dateCreated = outReq[indexPath.row].createdAt
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "MM.dd.yyyy"
            cell.reqDate.text! = "Requested: " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as String)
        }
        return cell
    }
}
