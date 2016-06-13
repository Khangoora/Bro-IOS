//
//  Authentication.swift
//  Bro!
//
//  Copyright (c) 2015 Jaskirat Khangoora. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Bolts


class Authentication{
    
    class func registerUserToPushNotification(){
        
        if let user = PFUser.currentUser(){
            var installation = PFInstallation.currentInstallation()
            installation.setObject(user, forKey: "user")
            installation.saveInBackground()
        }
    }
    class func signUp(username:String, password:String,successClosure:()->(), failureClosure:(error: NSError) -> ()){
        
        var user = PFUser()
        user.username = username
        user.password = password
        

        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                successClosure()
                self.registerUserToPushNotification()
            } else {
                failureClosure(error: error!)
            }
        }
        
    }
    
    class func signIn(username:String, password:String, successClosure:()->(), failureClosure:(error: NSError) -> ()){
        
        PFUser.logInWithUsernameInBackground(username, password:password) {
            (user: PFUser?, error: NSError?) -> Void in
            if let loginError = error {
                failureClosure(error: error!)
            } else {
                successClosure()
                self.registerUserToPushNotification()
            }
        }
    }
    
    class func sentBro(username: String, callbackClosure:(error: NSError?)->()){
        
        var userQuery = PFUser.query()
        userQuery!.whereKey("username", equalTo: username)
        userQuery!.findObjectsInBackgroundWithBlock { (users: [AnyObject]?, error: NSError?) -> Void in
            if error != nil {
                callbackClosure(error: error)
            }
            else if users!.count < 1{
//                callbackClosure(error: NSError(domain: "Send Bro", userInfo: [kErrorMessageKey : "The username '\(username)' not found"]))
            }
            else{
                // Find devices associated with these users
                let pushInstallationQuery = PFInstallation.query()
                pushInstallationQuery!.whereKey("user", matchesQuery: userQuery!)
                
                // Send push notification to query
                let push = PFPush()
                push.setQuery(pushInstallationQuery) // Set our Installation query
                
                // Set push notification data
                let data = ["alert" : "Bro FROM \(PFUser.currentUser()!.username)",
                    "sound" : "default"]
                push.setData(data)
                push.sendPushInBackgroundWithBlock({ (succeeded: Bool, error:NSError?) -> Void in
                    if (succeeded) {
                        callbackClosure(error: nil)
                    }
                    else{
                        callbackClosure(error: error)
                    }
                })
            }
        }
    }
    
    class func currentUser() -> PFUser?{
        
        return PFUser.currentUser()
    }
    
    
}
