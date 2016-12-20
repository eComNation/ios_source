//
//  ContactUsController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 08/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import MessageUI
import Material
import Whisper

class ContactUsController: UIViewController {

    @IBOutlet var lblPhone: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var viewCallUsOn: UIView!
    @IBOutlet var btnCallUs: UIButton!
    @IBOutlet var viewEmailUsAt: UIView!
    @IBOutlet var btnEmailUsAt: UIButton!
    @IBOutlet var viewWriteToUs: UIView!
    @IBOutlet var txtName: TextField!
    @IBOutlet var txtEmailId: TextField!
    @IBOutlet var txtMobileNo: TextField!
    @IBOutlet var txtNote: TextView!
    @IBOutlet var btnSubmit: UIButton!
    
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
        
        // Set submit button UI
        btnSubmit.backgroundColor = GeneralButtonColor
        
        lblPhone.text = ContactPhone
        lblEmail.text = ContactMail
        
        // Set place holder for note text view
        txtNote.placeholderLabel = UILabel()
        txtNote.placeholderLabel!.textColor = UIColor(hexString: "CCCCCC")
        txtNote.placeholderLabel!.text = "NOTE"
        txtNote.textContainerInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        // Set layering properties
        viewCallUsOn.layer.cornerRadius = 2.0
        viewCallUsOn.layer.masksToBounds = true
        viewCallUsOn.layer.borderColor = UIColor.lightGray.cgColor
        viewCallUsOn.layer.borderWidth = 0.5

        viewEmailUsAt.layer.cornerRadius = 2.0
        viewEmailUsAt.layer.masksToBounds = true
        viewEmailUsAt.layer.borderColor = UIColor.lightGray.cgColor
        viewEmailUsAt.layer.borderWidth = 0.5
        
        viewWriteToUs.layer.cornerRadius = 2.0
        viewWriteToUs.layer.masksToBounds = true
        viewWriteToUs.layer.borderColor = UIColor.lightGray.cgColor
        viewWriteToUs.layer.borderWidth = 0.5
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
            self.viewCallUsOn.alpha = alpha
            self.viewWriteToUs.alpha = alpha
        }) 
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        
        if networkManager.noRequestRunning {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func callUsTapped(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "tel://"+ContactPhone)!)
    }

    @IBAction func emailUsTapped(_ sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([ContactMail])
            mail.setMessageBody("", isHTML: true)
            
            present(mail, animated: true, completion: nil)
        } else {
            print("Cannot send mail.")
        }
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        
        var message = Message(title: "Please Enter valid information", backgroundColor: ErrorRedColor!)
        
        guard !((txtName.text?.isEmpty)!) else {
            message.title = "Name can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtEmailId.text?.isEmpty)!) else {
            message.title = "Email address can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtNote.text?.isEmpty)!) else {
            message.title = "Note can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        var details: [String: AnyObject] = [:]
        
        details["email"] = txtEmailId.text as AnyObject?
        details["fields[name]"] = txtName.text as AnyObject?
        details["subject"] = "User Comment" as AnyObject?
        if let mobileText = txtMobileNo.text , mobileText.characters.count > 0 {
            details["phone"] = txtMobileNo.text as AnyObject?
        }

        details["fields[comments]"] = txtNote.text as AnyObject?
       
        setUIElementsToAlpha(0.0)
        
        networkManager.contactUsWithDetail(details) { (success, message, response) -> (Void) in
            
            self.setUIElementsToAlpha(1.0)
            
            if success {
                _ = SweetAlert().showAlert("Feedback Submitted",subTitle: nil, style: AlertStyle.success, buttonTitle: "Ok")
                self.txtName.text = ""
                self.txtEmailId.text = ""
                self.txtMobileNo.text = ""
                self.txtNote.text = ""
            } else {
                _ = SweetAlert().showAlert("Failed", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
            }
        }
    }
}

extension ContactUsController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
