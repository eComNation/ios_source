//
//  ProfileController.swift
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


class ProfileController: UITableViewController {

    // MARK: Outlets
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtMobileNo: UITextField!
    @IBOutlet var txtEmailAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUIRelatedResources()
        fetchProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: MyFavouritesController()))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: Preparation methods
    func prepareUIRelatedResources() {
        
        if let currentCustomer = customerManager.currentCustomer {
            txtFirstName.text = currentCustomer.first_name
            txtLastName.text = currentCustomer.last_name
            txtMobileNo.text = currentCustomer.phone
            txtEmailAddress.text = currentCustomer.email
        }
    
    }
    
    // MARK: Service methods
    func fetchProfile() {

        networkManager.refreshCustomerProfile { (success, message, response) -> (Void) in
            if success {
                self.prepareUIRelatedResources()
            }
        }
    }
    
    func updateProfile() {
        
        var message = Message(title: "Please Enter valid information", backgroundColor: ErrorRedColor!)
        var profileInfo: [String: AnyObject] = [:]
        
        if txtFirstName.text?.characters.count > 0 {
            profileInfo["first_name"] = txtFirstName.text as AnyObject?
        } else {
            message.title = "First name can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        if txtLastName.text?.characters.count > 0 {
            profileInfo["last_name"] = txtLastName.text as AnyObject?
        } else {
            message.title = "Last name can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        if txtMobileNo.text?.characters.count > 0 {
            profileInfo["phone"] = txtMobileNo.text as AnyObject?
        }
        
        if txtEmailAddress.text?.characters.count > 0 {
            profileInfo["email"] = txtEmailAddress.text as AnyObject?
        }

        networkManager.updateCustomerProfile(profileInfo) { (success, message, response) -> (Void) in
            
            if success {
                _ = SweetAlert().showAlert("Profile updated successfully",subTitle: nil, style: AlertStyle.success, buttonTitle: "Ok")
            } else {
                _ = SweetAlert().showAlert("Failed", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
            }
        }
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        
        updateProfile()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
