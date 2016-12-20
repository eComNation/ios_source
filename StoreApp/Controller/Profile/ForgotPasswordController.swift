//
//  ForgotPasswordController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 09/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Material
import Whisper

class ForgotPasswordController: UIViewController {

    @IBOutlet var viewResetPassword: UIView!
    @IBOutlet var viewResetPasswordHeight: NSLayoutConstraint!
    @IBOutlet var txtUsername: KaedeTextField!
    @IBOutlet var btnResetPassword: UIButton!
    
    @IBOutlet var viewConfirmation: UIView!
    @IBOutlet var lblConfirmedUsername: UILabel!

    // MARK: Other properties
    let indicator: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 50), type: NVActivityIndicatorType.ballBeat, color: BaseApplicationColor!, padding: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUIRelatedResources()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: DashboardController()))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Preparing resources
    func prepareUIRelatedResources() {
        
        // Set confirmation view alpha
        viewConfirmation.alpha = 0.0
        
        // Set reset button UI
        btnResetPassword.backgroundColor = GeneralButtonColor
    }
    
    func setUIElementsToAlpha(_ alpha: CGFloat) {
        indicator.center = CGPoint(x: Material.Device.width / 2, y: Material.Device.height / 2)
        
        if alpha == 0.0 {
            indicator.startAnimation()
            self.view.addSubview(indicator)
        } else {
            indicator.stopAnimation()
            indicator.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viewResetPassword.alpha = alpha
        }) 
    }
    
    func showConfirmationView() {
        
        lblConfirmedUsername.text = txtUsername.text
        viewResetPasswordHeight.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viewResetPassword.alpha = 0.0
            self.viewConfirmation.alpha = 1.0
            self.view.layoutIfNeeded()
        }) 
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        
        if networkManager.noRequestRunning {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        
        var message = Message(title: "Please Enter valid information", backgroundColor: UIColor.red)
        
        guard !((txtUsername.text?.isEmpty)!) else {
            message.title = "Login Id can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard txtUsername.text!.isEmail() else {
            message.title = "Invalid Login Id."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        setUIElementsToAlpha(0.0)
        
        networkManager.resetPasswordForUsername(txtUsername.text!) { (success, message, response) -> (Void) in
            
            self.setUIElementsToAlpha(1.0)
            
            if success {
                self.showConfirmationView()
            } else {
                _ = SweetAlert().showAlert("Failed", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
            }
        }
    }
}
