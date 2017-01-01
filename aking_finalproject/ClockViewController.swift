//
//  ViewController.swift
//  aking_finalproject
//
//  Created by Allison King on 3/23/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import UIKit
let totalMembersPossible = 6

class ClockViewController: ObservingVC, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var allHandsView: AllHandsView!
    
    @IBOutlet weak var memberTableView: UITableView!
    var model = AppDel.socialModel
    
    private var allDataObserver : NSObjectProtocol?
    
    deinit {
        if let obs = allDataObserver {
            NSNotificationCenter.defaultCenter().removeObserver(obs)
        }
    }
    
    func updateUI() {
        allHandsView.setNeedsDisplay()
        memberTableView.reloadData()
    }
    
    func pullDataFromParse() {
        // need to iterate through the saved users
        let query = PFQuery(className: "aking_UserInfo")
        var index = 0
        for user in model.allUserInfo {
            if let u = user {
                /*query.getObjectWithId((u.objID)) { [weak self] (object, error) -> Void in*/
                do {
                    let obj = try query.getObjectWithId(u.objID)
                    guard let name = obj["name"] as? String, location = obj["location"] as? Int else {
                        print("User data at row \(index) is missing or wrong type")
                        return
                    }
                    let userInfo = UserInfo(currentLocation : LocationType(rawValue: location)!, name : name, objID : u.objID)
                    model.allUserInfo[index] = userInfo
                    index++
                }
                catch let e as NSError {
                    print(e.localizedDescription)
                }
                    /*guard let s = self else {
                        print("VC was dismissed before results arrived")
                        return
                    }
                    if let e = error {
                        print("error: \(e.localizedDescription)")
                        return
                    }
                
                    if let result = object {
                        guard let name = result["name"] as? String, location = result["location"] as? Int else {
                            print("User data at row \(index) is missing or wrong type")
                            return
                        }
                        let userInfo = UserInfo(currentLocation : LocationType(rawValue: location)!, name : name, objID : u.objID)
                        s.model.allUserInfo[index] = userInfo
                        index++
                    }*/
                    
                
                
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allDataObserver = NSNotificationCenter.defaultCenter().addObserverForName(Messages.FriendDataChanged, object: model, queue: NSOperationQueue.mainQueue()) {
            [weak self] (notification: NSNotification) in
            self?.updateUI()
        }
        allHandsView.socialModel = AppDel.socialModel
        
        updateUI()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        pullDataFromParse()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let addMemberController = segue.destinationViewController as? AddMemberViewController  {
            var editingRow : Int
            if let tappedCell = sender as? UITableViewCell {
                editingRow = tappedCell.tag
            } else {
                preconditionFailure("Segue from unexpected object: \(sender)")
            }
            
            addMemberController.editingRow = editingRow
        }

    }
    
    // MARK: Tableview delegate/datasource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalMembersPossible
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell") else {
            preconditionFailure("Failed to create a reusable cell")
        }
        let row = indexPath.row
        // set the tag
        cell.tag = row
        if let info = model.allUserInfo[row] {
            cell.textLabel!.text = info.name
        }
        else {
            cell.textLabel!.text = "Add member to clock"
        }
        cell.textLabel!.textColor = getColorFromIndex(row)
        
        return cell
    }

}



