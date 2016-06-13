//
//  Friend.swift
//  Bro
//
//  Created by Praveen Chekuri on 4/23/15.
//  Copyright (c) 2015 Jaskirat Khangoora. All rights reserved.
//

import Foundation
import Parse

class Friend : PFObject, PFSubclassing {
    var friend: String {
        get {
            return objectForKey("friend") as! String
        }
        set {
            setObject(newValue, forKey: "friend")
        }
    }

    
    class func parseClassName() -> String! {
        return "Friend"
    }

}
