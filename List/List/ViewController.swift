//
//  ViewController.swift
//  List
//
//  Created by Mitch Hamburger on 6/15/16.
//  Copyright © 2016 Mitch Hamburger. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {

    var listItems = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addItem"))
        // Do any additional setup after loading the view, typically from a nib.
    }

    func addItem() {
        let alertController = UIAlertController(title: "Type Something", message: "Type...", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: ({
            (_) in
            if let field = alertController.textFields![0] as? UITextField {
                self.saveItem(field.text!)
                self.tableView.reloadData()
                
            }
        }
        ))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertController.addTextFieldWithConfigurationHandler({
            (textField) in
            textField.placeholder = "Type in something"
            
        })
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func saveItem(itemToSave: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("ListEntity", inManagedObjectContext: managedContext!)
        
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        item.setValue(itemToSave, forKey: "item")
        
        do {
            try managedContext?.save()
            listItems.append(item)
        } catch {
            print("Error")
        }
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        managedContext?.deleteObject(listItems[indexPath.row])
        listItems.removeAtIndex(indexPath.row)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell
        
        let item = listItems[indexPath.row]
        
        cell.textLabel?.text = item.valueForKey("item") as! String
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

