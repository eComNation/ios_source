//
//  SignUpController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 01/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Whisper

class SignUpController: UIViewController {

    // MARK: Outlets
    @IBOutlet var mainContainer: UIScrollView!
    @IBOutlet var txtFirstName: KaedeTextField!
    @IBOutlet var txtLastName: KaedeTextField!
    @IBOutlet var txtUserName: KaedeTextField!
    @IBOutlet var txtPhone: KaedeTextField!
    @IBOutlet var txtPassword: KaedeTextField!
    @IBOutlet var txtConfirmPassword: KaedeTextField!
    @IBOutlet var switchMarketingMails: UISwitch!
    @IBOutlet var btnSignUp: UIButton!
    
    @IBOutlet var viewConfirmation: UIView!
    @IBOutlet var lblConfirmationId: UILabel!
    
    // MARK: Other properties
    let indicator: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 50), type: NVActivityIndicatorType.ballBeat, color: BaseApplicationColor!, padding: 0)
    
    // MARK: Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUIRelatedResources()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: SignUpController()))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Preparing resources
    func prepareUIRelatedResources() {
        
        // Set confirmation view alpha
        viewConfirmation.alpha = 0.0
        
        // Set signup button UI
        btnSignUp.backgroundColor = GeneralButtonColor
    }
    
    func setUIElementsToAlpha(_ alpha: CGFloat) {
        indicator.center = self.view.center
        
        if alpha == 0.0 {
            indicator.startAnimation()
            self.view.addSubview(indicator)
        } else {
            indicator.stopAnimation()
            indicator.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.btnSignUp.alpha = alpha
            self.mainContainer.alpha = alpha
        }) 
    }
    
    func showConfirmation() {
        
        lblConfirmationId.text = txtUserName.text
        
        indicator.stopAnimation()
        indicator.removeFromSuperview()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.btnSignUp.alpha = 0.0
            self.mainContainer.alpha = 0.0
            self.viewConfirmation.alpha=1.0
        }) 
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnSignUpTapped(_ sender: UIButton) {
        
        var message = Message(title: "Please Enter valid information", backgroundColor: UIColor.red)
        
        guard !((txtFirstName.text?.isEmpty)!) else {
            message.title = "First name can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtLastName.text?.isEmpty)!) else {
            message.title = "Last name can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtUserName.text?.isEmpty)!) else {
            message.title = "User name can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard txtUserName.text!.isEmail() else {
            message.title = "Invalid Login Id."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtPassword.text?.isEmpty)!) else {
            message.title = "Password can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtConfirmPassword.text?.isEmpty)!) else {
            message.title = "Confirm Password can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }

        guard txtPassword.text == txtConfirmPassword.text else {
            message.title = "Confirm Password must match with Password."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        setUIElementsToAlpha(0.0)
        
        networkManager.signupWithDetail(txtFirstName.text!, lName: txtLastName.text!, login: txtUserName.text!, phone: txtPhone.text!, password: txtPassword.text!, cPassword: txtConfirmPassword.text!, marketingMails: switchMarketingMails.isOn) { (success, message, response) -> (Void) in
            
            if success {
                self.showConfirmation()
            } else {
                
                self.setUIElementsToAlpha(1.0)
                
                if let errors = response?["error"] as? [String] , errors.count > 1 {
                    let title = errors.first != nil ? errors.first! : "Signup Failed!"
                    let msg = errors[1]                    
                    _ = SweetAlert().showAlert(title, subTitle: msg, style: AlertStyle.error, buttonTitle: "Ok")
                } else {
                    _ = SweetAlert().showAlert("Signup Failed!", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                }
            }
        }
    }
}
