//
//  SocialClockData.swift
//  aking_finalproject
//
//  Created by Allison King on 4/9/16.
//  Copyright © 2016 Allison King. All rights reserved.
//

import Foundation



class SocialClockData {
    var allUserInfo : [UserInfo?] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: Messages.FriendDataChanged, object: self))
        }
    }
    
    init(){
        allUserInfo = [UserInfo?](count : totalMembersPossible, repeatedValue: nil)
    }
    
    func addUser(row : Int, data : UserInfo ) {
        if row < totalMembersPossible {
            allUserInfo[row] = data
        }
        else {
            preconditionFailure("I can't add over six members!")
        }
    }
    
    
}