import UIKit
import Parse
import ParseUI
class TableViewController: PFQueryTableViewController {
    
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
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
        query1.includeKey("userID")
        
        
        return query1
    }
    
    //override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell

    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
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


}