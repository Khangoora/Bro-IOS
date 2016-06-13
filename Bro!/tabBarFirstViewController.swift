//
//  tabBarFirstViewController.swift
//  Bro
//
//  Copyright (c) 2015 Jaskirat Khangoora. All rights reserved.
//

import UIKit
import Parse

class tabBarFirstViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,UITabBarDelegate {
    
    //refreshControl for  Tableview
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.backgroundColor = UIColor.whiteColor()
        refreshControl.tintColor = UIColor.grayColor()
        
        
        return refreshControl
        }()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //Status Bar Color
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    var currentUser: String = ""
    
    //View Starts Here
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() == nil || !PFUser.currentUser()!.isAuthenticated()) {
            performSegueWithIdentifier("toViewController", sender: self)
        } else {
            var newCurrentUser = PFUser.currentUser()!
            if (currentUser != newCurrentUser.username!) {
                self.friends = []
                self.friends.append("SHARE BRO!")
                self.friendObjects = []
                currentUser = newCurrentUser.username!
            }
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
                fetchAndSaveUserLocation()
            }
            startLoading()
            populateFriends()
        }
        
        self.friendsTableView.addSubview(self.refreshControl)
        self.friendsTableView.allowsMultipleSelectionDuringEditing = false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    //IBOutlets
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    var friends: [String] = []
    var friendObjects: [PFUser] = []
    
    //IBActions
    
    func startLoading() {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
    }
    
    func stopLoading() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    @IBAction func addButtonPressed(sender: UIButton) {
        var alert = UIAlertView()
        alert.title = "Add a bro!"
        alert.addButtonWithTitle("Add Bro")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.addButtonWithTitle("Cancel")
        alert.delegate = self
        let textField = alert.textFieldAtIndex(0) as UITextField!
        textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        textField.placeholder = "Bro Name"
        alert.show()
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:firstTableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell") as! firstTableViewCell
        cell.textLabel?.text = friends[indexPath.row]
        
        if (friends.count - 1 == indexPath.row) {
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        } else {
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.systemFontOfSize(16.0)
        }
        return cell;
    }
    
    func shareBros() {
        var name: String = PFUser.currentUser()?.username as String!
        let firstActivityItem = "Get the bro app and bro me! My bro name is " + name + " http://goo.gl/opSkqp"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var text = alertView.textFieldAtIndex(0)?.text as String!
        if (buttonIndex == 0 && !text.isEmpty) {
            addNewFriend(text)
        }
    }
    
    //UiTableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (friends.count - 1 == indexPath.row) {
            shareBros()
        } else {
            var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            spinner.frame = CGRectMake(0, 0, 24, 24)
            var cell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
            cell.userInteractionEnabled = false
            cell.accessoryView = spinner
            spinner.startAnimating()
            var myTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFunc:", userInfo: cell, repeats: false)
            sendNotification(self.friendObjects[indexPath.row])
        }
    }
    
    func timerFunc(timer: NSTimer) {
        var cell = timer.userInfo as! UITableViewCell
        cell.userInteractionEnabled = true
        var spinner = cell.accessoryView as! UIActivityIndicatorView
        spinner.stopAnimating()
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell:firstTableViewCell = friendsTableView.cellForRowAtIndexPath(indexPath) as! firstTableViewCell
        cell.backgroundColor = UIColor(rgb: 0x2d5d82, alpha: 0.2)
        
    }
    
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell:firstTableViewCell = friendsTableView.cellForRowAtIndexPath(indexPath) as! firstTableViewCell
        cell.backgroundColor = UIColor.whiteColor()
    }
    
    //UITabBar Delegates
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        tabBar.tintColor  = UIColor(rgb: 0x2d5d82, alpha: 1.0)

    }
    //Implementing the swipe to Delete
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func populateFriends()
    {
        var myArray:[AnyObject] = []
        var query = PFQuery(className:"Friend")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        
        var userQuery = PFUser.query()
        userQuery?.whereKey("username", matchesKey: "friend", inQuery: query)
        userQuery!.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error != nil || objects == nil) {
                self.showMessage("Error", message: "Sorry something went wrong. Please try again.")
            } else {
                var reversedObjects = objects?.reverse()
                for object in reversedObjects! {
                    let currentFriend = object.username!
                    if (!(self.friends.contains(currentFriend!))) {
                        self.friendObjects.insert(object as! PFUser, atIndex: 0)
                        self.friends.insert(currentFriend!, atIndex: 0)
                    }
                }
                self.reloadData()
                self.stopLoading()
            }
        }
        
    }
    
    func sendNotification(receiver: PFUser) {
        var query = PFInstallation.query()
        query?.whereKey("user", equalTo: receiver)
        var push = PFPush()
        push.setQuery(query)
        var message: String = "BRO! from " + (PFUser.currentUser()?.username!)!
        let data = [
            "alert" : message,
            "sound" : "default"
        ]
        push.setData(data)
        push.sendPushInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if (error == nil) {
                var track = PFObject(className: "Notification")
                track.setValue(PFUser.currentUser()?.objectId!, forKey: "user")
                track.setValue(receiver.objectId, forKey: "friend")
                track.saveInBackground()
            }
        }
    }
    
    func addNewFriend(name: String) {
        if (name == PFUser.currentUser()?.username) {
            stopLoading()
            showMessage("Lol", message: "You can't bro yourself")
            return
        }
        
        if (self.friends.contains(name)) {
            stopLoading()
            showMessage("Bro!", message: "You guys are already bros.")
            return
        }
        
        startLoading()
        var friendName = name.uppercaseString
        var query = PFUser.query()
        query!.whereKey("username", equalTo: friendName)
        query?.getFirstObjectInBackgroundWithBlock({ (object: AnyObject?, error: NSError?) -> Void in
            if (error != nil) {
                self.stopLoading()
                self.showMessage("Oops", message: "The bro doesn't exist.")
            } else {
                var friendFromQuery = object as! PFUser
                var friendObject = PFObject(className: "Friend")
                friendObject.setValue(PFUser.currentUser()!, forKey: "user")
                friendObject.setValue(friendName, forKey: "friend")
                friendObject.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    if (succeeded) {
                        self.friends.insert(friendName, atIndex: 0)
                        self.friendObjects.insert(friendFromQuery, atIndex: 0)
                        self.reloadData()
                        self.stopLoading()
                        self.showMessage("Bro!", message: "Successfully added " + friendName + "! \n Bro On!")
                        var secondFriendObject = PFObject(className: "Friend")
                        secondFriendObject.setValue(object as! PFUser, forKey: "user")
                        secondFriendObject.setValue(PFUser.currentUser()?.username!, forKey: "friend")
                        secondFriendObject.saveInBackground()
                    } else {
                        self.stopLoading()
                        self.showMessage("Oops", message: "Something went wrong, please try to re-bro!")
                    }
                })
            }
        })
    }
    
    func showMessage(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveUserCurrentLocation(point: PFGeoPoint) {
        PFUser.currentUser()?.setValue(point, forKey: "location")
        PFUser.currentUser()?.saveInBackground()
    }
    
    func refreshTableViewController() {
        var refreshControl:UIRefreshControl!
        
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        populateFriends()
        refreshControl.endRefreshing()
    }
    
    func reloadData() {
        self.friendsTableView.reloadData()
    }
    
    func fetchAndSaveUserLocation() {
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.saveUserCurrentLocation(geoPoint!)
            }
        }
    }
    
}













