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
    
    fileprivate var allDataObserver : NSObjectProtocol?
    
    deinit {
        if let obs = allDataObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
    
    func updateUI() {
        allHandsView.setNeedsDisplay()
        memberTableView.reloadData()
    }
    
    func pullDataFromParse() {
        print ("Pulling data from Parse... not!")
        // need to iterate through the saved users
        /*let query = PFQuery(className: "aking_UserInfo")
        var index = 0
        for user in model.allUserInfo {
            if let u = user {
                /*query.getObjectWithId((u.objID)) { [weak self] (object, error) -> Void in*/
                do {
                    let obj = try query.getObjectWithId(u.objID)
                    guard let name = obj["name"] as? String, let location = obj["location"] as? Int else {
                        print("User data at row \(index) is missing or wrong type")
                        return
                    }
                    let userInfo = UserInfo(currentLocation : LocationType(rawValue: location)!, name : name, objID : u.objID)
                    model.allUserInfo[index] = userInfo
                    index += 1
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
            
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allDataObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Messages.FriendDataChanged), object: model, queue: OperationQueue.main) {
            [weak self] (notification: Notification) in
            self?.updateUI()
        }
        allHandsView.socialModel = AppDel.socialModel
        
        updateUI()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pullDataFromParse()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addMemberController = segue.destination as? AddMemberViewController  {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalMembersPossible
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell") else {
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



