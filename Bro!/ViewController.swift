//
//  ViewController.swift
//  Bro!
//
//  Copyright (c) 2015 Jaskirat Khangoora. All rights reserved.
//

import UIKit
import Parse


class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var broNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        broNameTextField.returnKeyType = UIReturnKeyType.Next
        passwordTextField.returnKeyType = UIReturnKeyType.Done
        broNameTextField.delegate = self
        passwordTextField.delegate = self
        
        broNameTextField.layer.mask = roundTextField(CGRectMake(0.0, 0.0, 257.0, 45.0), corners: [UIRectCorner.TopLeft, UIRectCorner.TopRight], radius: 15)
        passwordTextField.layer.mask = roundTextField(CGRectMake(0.0, 0.0, 257.0, 45.0), corners: [UIRectCorner.BottomLeft,UIRectCorner.BottomRight], radius: 15)
        broNameTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func signInButtonPressed(sender: UIButton) {
        login(broNameTextField.text!, password: passwordTextField.text!)
    }

    @IBAction func signUpButtonPressed(sender: UIButton) {
        signUp(broNameTextField.text!, password: passwordTextField.text!)
    }
    func login(username:String, password:String){
            Authentication.signIn(username.uppercaseString, password: password, successClosure: success, failureClosure: signInError)
    }
    func signUp(username:String, password:String){
            Authentication.signUp(username.uppercaseString, password: password, successClosure: success, failureClosure: signUpError)
    }

    func success(){
        dismissViewControllerAnimated(true, completion: nil)
    }

    func signUpError(error: NSError){
        showError("Sorry", text: "Bro name is already taken.")
    }
    
    func signInError(error: NSError) {
        showError("Error", text: "Please check your username and password and try again.")
    }
    
    func showError(title: NSString, text: NSString) {
        var alert = UIAlertController(title: title as String, message: text as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == broNameTextField) {
            self.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }

    func roundTextField(Rect:CGRect, corners:UIRectCorner, radius:CGFloat) ->CAShapeLayer
    {
        var screenRect = UIScreen.mainScreen().bounds
        var screenWidth = screenRect.size.width;
        var screenHeight = screenRect.size.height;
        var newRect = CGRect()
        print(Rect)
        
        if screenWidth == 375{
            newRect = CGRectMake(0.0, 2.0, 312.0, 41.0)
        }
        else if screenWidth == 414{
            newRect = CGRectMake(0.0, 2.0, 351.0, 41.0)
        }
        else{
            newRect = Rect
        }
        var maskPath = UIBezierPath(roundedRect: newRect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        var maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.CGPath
        //broNameTextField.layer.mask = maskLayer
        return maskLayer
    }
}


