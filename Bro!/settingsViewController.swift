//
//  settingsViewController.swift
//  Bro
//
//  Copyright (c) 2015 Jaskirat Khangoora. All rights reserved.
//


import UIKit
import Parse
import MessageUI
import Social

class settingsViewController: UIViewController, MFMailComposeViewControllerDelegate {

    
    //Status Bar Color
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var screenBound: CGRect = UIScreen.mainScreen().bounds
        var screenSize: CGSize = screenBound.size
        if (screenSize.height < 500) {
            bottomSettingsView.hidden = true
            shareLabel.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        broNameLabel.text = PFUser.currentUser()?.username
        if (PFInstallation.currentInstallation().valueForKey("user") != nil) {
            silenceOutlet.on = false
        } else {
            silenceOutlet.on = true
        }
    }
    
    func silenceUser() {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.removeObjectForKey("user")
        currentInstallation.saveInBackground()
    }
    
    func unSilenceUser() {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setObject(PFUser.currentUser()!, forKey: "user")
        currentInstallation.saveInBackground()
    }
    
    //IBOutlets
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var broNameLabel: UILabel!
    @IBOutlet weak var bottomSettingsView: UIView!
    @IBOutlet weak var shareLabel: UILabel!
    //UIButton Actions
    @IBAction func facebookButtonPressed(sender: UIButton) {
        sender.backgroundColor = UIColor.clearColor() //reset IB Color
        sender.setBackgroundImage(UIImage.imageWithColor(UIColor.clearColor()), forState: .Normal)
        sender.setBackgroundImage(UIImage.imageWithColor(UIColor(rgb:0x2d5d82, alpha: 1)), forState: .Highlighted)
        sender.clipsToBounds = true
        var maskPath = UIBezierPath(roundedRect: sender.bounds, byRoundingCorners: ([UIRectCorner.TopLeft, UIRectCorner.TopRight]), cornerRadii: CGSize(width: 5, height: 5))
        var maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.CGPath
        sender.layer.mask = maskLayer
        shareViaFacebook(PFUser.currentUser()?.username as String!)
    }
    
    @IBAction func silenceToggle(sender: UISwitch) {
        if (sender.on) {
            silenceUser()
        } else {
            unSilenceUser()
        }
    }
    
    @IBOutlet weak var silenceOutlet: UISwitch!
    
    @IBAction func twitterButtonPressed(sender: UIButton) {
        sender.backgroundColor = UIColor.clearColor() //reset IB Color
        sender.setBackgroundImage(UIImage.imageWithColor(UIColor.clearColor()), forState: .Normal)
        sender.setBackgroundImage(UIImage.imageWithColor(UIColor(rgb:0x2d5d82, alpha: 1)), forState: .Highlighted)
        shareViaTwitter(PFUser.currentUser()?.username as String!)
    }
    
    @IBAction func mailButtonPressed(sender: UIButton) {
        sender.backgroundColor = UIColor.clearColor() //reset IB Color
        sender.setBackgroundImage(UIImage.imageWithColor(UIColor.clearColor()), forState: .Normal)
        sender.setBackgroundImage(UIImage.imageWithColor(UIColor(rgb:0x2d5d82, alpha: 1)), forState: .Highlighted)
        let mailComposeViewController = configuredMailComposeViewController(PFUser.currentUser()?.username as String!)
        if (MFMailComposeViewController.canSendMail()) {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showMessage("Oops", message: "Sorry seems you can't share via email. Please try another method.")
        }
    }
    
    @IBAction func SMSButtonPressed(sender: UIButton) {
        sender.backgroundColor = UIColor.clearColor() //reset IB Color
        sender.setBackgroundImage(UIImage.imageWithColor(UIColor.clearColor()), forState: .Normal)
        sender.setBackgroundImage(UIImage.imageWithColor(UIColor(rgb:0x2d5d82, alpha: 1)), forState: .Highlighted)
        sender.clipsToBounds = true
        var maskPath = UIBezierPath(roundedRect: sender.bounds, byRoundingCorners: ([UIRectCorner.BottomLeft, UIRectCorner.BottomRight]), cornerRadii: CGSize(width: 5, height: 5))
        var maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.CGPath
        sender.layer.mask = maskLayer
        if (messageComposer.canSendText()) {
            let messageComposeVC = messageComposer.configuredMessageComposeViewController(PFUser.currentUser()?.username as String!)
            presentViewController(messageComposeVC, animated: true, completion: nil)
        } else {
            self.showMessage("Oops", message: "Sorry seems you can't share via SMS. Please try another method.")
        }

    }
    
    let messageComposer = MessageComposer()
    
    @IBAction func signOutButtonPressed(sender: UIButton) {
        PFUser.logOut()
        if (PFUser.currentUser() == nil || !PFUser.currentUser()!.isAuthenticated()) {
            performSegueWithIdentifier("fromSignupToViewController", sender: self)
        }
    }

    
    //Helper Functions
    
    func configuredMailComposeViewController(name: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setSubject("Get the Bro App!")
        let message: String = "Get the bro app and bro me! My bro name is " + name + " http://goo.gl/opSkqp"
        mailComposerVC.setMessageBody(message, isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showMessage(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func shareViaFacebook(name: String) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            var fb = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            let shareText: String = "Get the bro app and bro me! My bro name is " + name + " http://goo.gl/opSkqp"
            fb.setInitialText(shareText)
            
            fb.addImage(UIImage(named: "AppIcon"))
            
            self.presentViewController(fb, animated: true, completion:nil)
        } else {
            showMessage("Oops", message: "Facebook not configured on your device. Go to Settings >> Facebook and log in to share.")
        }
        
    }
    
    func shareViaTwitter(name: String) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            var fb = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            let shareText: String = "Get the bro app and bro me! My bro name is " + name + " http://goo.gl/opSkqp"
            fb.setInitialText(shareText)
            
            fb.addImage(UIImage(named: "AppIcon"))
            
            self.presentViewController(fb, animated: true, completion:nil)
        } else {
            showMessage("Oops", message: "Twitter not configured on your device. Go to Settings >> Facebook and log in to share.")
        }
        
    }
    
}