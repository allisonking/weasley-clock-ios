//
//  AddMemberViewController.swift
//  aking_finalproject
//
//  Created by Allison King on 4/24/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import UIKit

class AddMemberViewController : ObservingTVC {
    let reuseId = "AddCell"
    var editingRow : Int?
    var selectedRow : Int?
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        guard let membersRow = editingRow else {
            preconditionFailure("parent forgot to instantiate editing row!")
        }
        if let index = selectedRow {
            let user = users[index]
            guard let name = user["name"] as? String, location = user["location"] as? Int else {
                errorAlert("User data at row \(index) is missing or wrong type")
                return
            }
            let userInfo = UserInfo(currentLocation : LocationType(rawValue: location)!, name : name, objID : user.objectId!)
            model.addUser(membersRow, data: userInfo)
            navigationController?.popViewControllerAnimated(true)
        } else {
            preconditionFailure("row not selected- how did add button get enabled?")
        }
        
    }
  
    @IBAction func refresh(sender: UIRefreshControl) {
        reloadDataFromParse()
        sender.endRefreshing()
    }
    let model = AppDel.socialModel
    
    // delete this later
    func deleteFromDatabase(id : String) {
        let query = PFQuery(className: "aking_UserInfo")
        query.getObjectInBackgroundWithId(id) { (user, error) -> Void in
            user?.deleteEventually()
        }
    }
    
    override func viewDidLoad() {
        // reload from the database
        reloadDataFromParse()
        
        // disable the add button (enabled by user choosing a table cell)
        addButton.enabled = false
        
/*
        let obj = PFObject(className: "aking_UserInfo")
        obj.setValue(LocationType.ExerciseLocation.rawValue, forKey: "location")
        obj.setValue("Karl", forKey: "name")

        do {
            try obj.save()
        }
        catch let e as NSError {
            print(e.localizedDescription)
        } */
        
        
        /*let query = PFQuery(className: "aking_UserInfo")
        query.getObjectInBackgroundWithId("NFhPS0r6lU") { (object, error) -> Void in
            if let e = error {
                print("error: \(e.localizedDescription)")
                return
            }
            if let result = object {
                result["location"] = LocationType.SchoolLocation.rawValue
                result.saveInBackground()
            }
        }*/
        
        
        
        

    }
    
    var users = [PFObject]()
    
    func reloadDataFromParse() {
        let query = PFQuery(className: "aking_UserInfo")
        
        // All this nice packaging is STILL on the background network thread
        query.findObjectsInBackgroundWithBlock { [weak self] (objects, error) -> Void in
            guard let s = self else {
                print("VC was dismissed before results arrived")
                return
            }
            if let e = error {
                s.errorAlert("Parse returned error: \(e.localizedDescription)")
                return
            }
            guard let results = objects else {
                s.errorAlert("Parse reported no error, but could not unpack results as PFObject array")
                return
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                // Data model should only be manipulated on one thread too.
                // So if initialized/read from 'main' thread, write to it
                // ONLY on the 'main' thread.
                
                s.users = results
                s.tableView.reloadData()
            
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("AddCell") else {
            preconditionFailure("Failed to create a reusable cell")
        }
        let row = indexPath.row
        let user = users[row]
        guard let name = user["name"] as? String else {
            errorAlert("User data at row \(row) is missing or wrong type")
            return cell
        }
        cell.tag = row
        cell.textLabel!.text = name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        addButton.enabled = true
    }
}
