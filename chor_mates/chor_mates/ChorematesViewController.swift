import UIKit
import Parse
import ParseUI
class TableViewController: PFQueryTableViewController {
    
    @IBAction func settingsPressed(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("toSettings", sender: self)
    }
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    override func viewDidAppear(animated: Bool) {
        var nav = self.navigationController?.navigationBar
        // 2
        //nav?.barStyle = UIBarStyle.
        nav?.tintColor = UIColor.blueColor()
        
        self.loadObjects()
        
    }
    override func viewDidLoad() {
        self.navigationItem.title = "Choremates"
        
        
        super.viewDidLoad()
        
        //hide empty table rows
        var tblView =  UIView(frame: CGRectZero)
        //  choreTableView.tableFooterView = tblView
        //  choreTableView.tableFooterView!.hidden = true
        //  choreTableView.backgroundColor = UIColor.clearColor()
        
        
        
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "Household_User"
        self.textKey = "householdID"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        
        var query1 = PFQuery(className:"Household_User")
        // query2.includeKey("userID")
        query1.includeKey("householdID")
        query1.whereKey("userID", equalTo: PFUser.currentUser()!)
        
        var query2 = PFQuery(className:"Household_User")
        query2.includeKey("userID")
        //query3.whereKey("householdID", matchesQuery: query1)
        query2.whereKey("householdID", matchesKey: "householdID", inQuery: query1)
        query2.orderByAscending("createdAt")
        return query2
    }
    
    //override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.preservesSuperviewLayoutMargins = false;
        
        var dateCreated = object?.createdAt as NSDate?
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MMM dd, yyyy"
        
        
        cell?.detailTextLabel?.text = "Joined: " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
        
        if let pointer = object?["userID"] as? PFObject {
            let fName = pointer["fName"] as! String
            let lName = pointer["lName"] as! String
            cell?.textLabel?.text = fName + " " + lName
            
            
        }
        
        return cell
    }
    
    @IBAction func Logout() {
        PFUser.logOut()
        //Go to login page
        let controller = storyboard?.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
        presentViewController(controller, animated: true, completion: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "toSettings" {
            if let addExpenseViewController = segue.destinationViewController as? settingsView {
                
                
            }
        }
    }
    
    
}