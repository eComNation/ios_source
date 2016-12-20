//
//  ChangePasswordController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 25/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Whisper
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ChangePasswordController: UITableViewController {

    // MARK: Outlets
    @IBOutlet var txtCurrentPassword: UITextField!
    @IBOutlet var txtNewPassword: UITextField!
    @IBOutlet var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: ChangePasswordController()))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Service methods
    func changePassword() {
        
        var message = Message(title: "Please Enter valid information", backgroundColor: UIColor.red)
        
        var passwordInfo: [String: AnyObject] = [:]
        
        if txtCurrentPassword.text?.characters.count > 0 {
            passwordInfo["current_password"] = txtCurrentPassword.text as AnyObject?
        } else {
            message.title = "Current password can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        if txtNewPassword.text?.characters.count > 0 {
            passwordInfo["new_password"] = txtNewPassword.text as AnyObject?
        } else {
            message.title = "New password can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        if txtConfirmPassword.text?.characters.count > 0 && txtNewPassword.text == txtConfirmPassword.text {
            passwordInfo["confirm_password"] = txtConfirmPassword.text as AnyObject?
        }  else {
            message.title = "Confirm password doesn't match with new password."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }

        networkManager.changeCustomerPassword(passwordInfo) { (success, message, response) -> (Void) in

            if success {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        changePassword()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Set separator insets
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
}
