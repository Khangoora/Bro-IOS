//
//  tabBarSecondViewController.swift
//  Bro
//
//  Copyright (c) 2015 Jaskirat Khangoora. All rights reserved.
//

import UIKit
import Parse


class tabBarSecondViewController: UIViewController,UITableViewDataSource,  UITableViewDelegate, CLLocationManagerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    //refresh TableView Control
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.backgroundColor = UIColor(rgb: 0x2d5d82, alpha: 1)
        refreshControl.tintColor = UIColor.whiteColor()
        
        
        return refreshControl
        }()
    
    //Change the status bar to light
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    let manager = CLLocationManager()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() == nil || !PFUser.currentUser()!.isAuthenticated()) {
            performSegueWithIdentifier("toViewController", sender: self)
        } else {
            askForLocationPermission()
        }
        
        self.localBrosTableView.addSubview(self.refreshControl)
        self.localBrosTableView.allowsMultipleSelectionDuringEditing = false
        //tableView Resize
        if UITableView.instancesRespondToSelector("setLayoutMargins:") {
            UITableView.appearance().layoutMargins = UIEdgeInsetsZero
            UITableViewCell.appearance().layoutMargins = UIEdgeInsetsZero
            UITableViewCell.appearance().preservesSuperviewLayoutMargins = false
        }
    }
    
    func shareBros() {
        var name: String = PFUser.currentUser()?.username as String!
        let firstActivityItem = "Get the bro app and bro me! My bro name is " + name +  " http://goo.gl/opSkqp"
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    
    //IBOutlets
    
    @IBOutlet weak var localBrosTableView: UITableView!
    
   
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:firstTableViewCell = tableView.dequeueReusableCellWithIdentifier("myCell2") as! firstTableViewCell
        cell.textLabel?.text = friends[indexPath.row]
        
        if (friends.count - 1 == indexPath.row) {
            cell.textLabel?.textColor = UIColor.redColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(16.0)
        } else {
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.systemFontOfSize(16.0)
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    var friends: [String] = []
    var friendObjects: [PFUser] = []
    
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
    
    func sendNotification(receiver: PFUser) {
        var query = PFInstallation.query()
        query?.whereKey("user", equalTo: receiver)
        var push = PFPush()
        push.setQuery(query)
        var message: String = "BRO! from a local bro " + (PFUser.currentUser()?.username!)!
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
    
    
    
    func getBrosNearMe(point: PFGeoPoint) {
        var now: NSDate = NSDate()
        var query = PFQuery(className: "_User")
        query.whereKey("location", nearGeoPoint: point, withinMiles: 10.0)
        query.limit = 20
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            self.stopLoading()
            if (error != nil) {
                self.showMessage("Error", message: "Something went wrong. Please try again.")
            } else {
                self.friends = ["SHARE BRO!"]
                var reversedObjects = objects?.reverse()
                for object in reversedObjects!{
                    let currentFriend = object.username!
                    var isValid: Bool = object.updatedAt!!.timeIntervalSinceNow > -3600
                    if (!self.friends.contains(currentFriend!) && isValid && currentFriend != PFUser.currentUser()?.username! && self.friends.count < 11) {
                        self.friendObjects.insert(object as! PFUser, atIndex: 0)
                        self.friends.insert(currentFriend!, atIndex: 0)
                    }
                }
                self.localBrosTableView.reloadData()
                
            }
        }
    }
    
    func saveUserCurrentLocation(point: PFGeoPoint) {
        PFUser.currentUser()?.setValue(point, forKey: "location")
        PFUser.currentUser()?.saveInBackground()
    }
    
    func fetchAndSaveUserLocation() {
        startLoading()
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.getBrosNearMe(geoPoint!)
                self.saveUserCurrentLocation(geoPoint!)
            } else {
                self.stopLoading()
                self.showMessage("Error", message: "Something went wrong, please try again later")
            }
        }
    }
    
    
    //refresh TableView
    func refreshTableViewController() {
        var refreshControl:UIRefreshControl!
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        askForLocationPermission()
        refreshControl.endRefreshing()
    }
    
    func askForLocationPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            manager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "Please enable location to see bros around you.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            fetchAndSaveUserLocation()
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell:firstTableViewCell = localBrosTableView.cellForRowAtIndexPath(indexPath) as! firstTableViewCell
        cell.backgroundColor = UIColor(rgb: 0x2d5d82, alpha: 0.2)
        
    }
    
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        var cell:firstTableViewCell = localBrosTableView.cellForRowAtIndexPath(indexPath) as! firstTableViewCell
        cell.backgroundColor = UIColor.whiteColor()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways)  {
            fetchAndSaveUserLocation()
        }
    }
    
    func showMessage(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func startLoading() {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
    }
    
    func stopLoading() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    

}