import UIKit
import Parse
import ParseUI
class requestPickChore: PFQueryTableViewController {
    var userSwapWithID: String = ""
    var selectedObject: PFObject?
   

    @IBOutlet var choreSwapTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Pick Chore"
    }
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "Chore_User"
        self.textKey = "objectID"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery {
        var userQuery = PFQuery(className: "_User")
        userQuery.whereKey("objectId", equalTo: userSwapWithID)
        println(userSwapWithID)
        
        var query1 = PFQuery(className:"Chore_User")
        query1.includeKey("userID")
        query1.whereKey("userID", matchesKey: "objectId", inQuery: userQuery)
        query1.includeKey("choreID")
        query1.whereKey("status", equalTo: "pending")
        return query1
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
    
        var cell = tableView.dequeueReusableCellWithIdentifier("pickChoreCell") as! PFTableViewCell!
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "pickChoreCell")
        }
        var dateCreated = object?["endDate"] as! NSDate?
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MMM dd, yyyy"
    
    
        cell?.detailTextLabel?.text = "Due " + (NSString(format: "%@", dateFormat.stringFromDate(dateCreated!)) as! String)
        
        if let pointer = object?["choreID"] as? PFObject {
            let choreName = pointer["choreName"] as! String
    
        cell?.textLabel?.text = choreName
    
    
        }
    
        return cell
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "pickedChoreUnwind" {
            if let addRequestViewController = segue.destinationViewController as? addRequest {
                var selectedPath : NSIndexPath! = self.choreSwapTableView.indexPathForCell(sender as!UITableViewCell!)
                 self.selectedObject = self.objectAtIndexPath(selectedPath)
                addRequestViewController.choreSwapWith = selectedObject!.objectId!
                if let pointer = self.selectedObject?["choreID"] as? PFObject {
                    let choreName = pointer["choreName"] as! String
                    addRequestViewController.toPFObject = self.selectedObject
                    addRequestViewController.chorePickedTextField.text = choreName
                    addRequestViewController.chorePickedTextField.textAlignment = .Center
                }
            }
    }
    }
      
    
        

    


}