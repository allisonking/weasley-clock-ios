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
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Messages.FriendDataChanged), object: self))
        }
    }
    
    init(){
        allUserInfo = [UserInfo?](repeating: nil, count: totalMembersPossible)
    }
    
    func addUser(_ row : Int, data : UserInfo ) {
        if row < totalMembersPossible {
            allUserInfo[row] = data
        }
        else {
            preconditionFailure("I can't add over six members!")
        }
    }
    
    
}
