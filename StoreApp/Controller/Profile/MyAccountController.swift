//
//  MyAccountController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 16/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Whisper

class MyAccountController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: MyAccountController()))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func logoutTapped(_ sender: AnyObject) {
        print("Logout called")
        let alertViewController = UIAlertController(title: "Warning", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "YES", style: .default) { (action) -> Void in
            customerManager.logoutCustomer()
            NotificationCenter.default.post(name: Notification.Name(rawValue: UserLoggedOutNotification), object: nil)

            _ = self.navigationController?.popToRootViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "NO", style: .cancel) { (action) -> Void in
            
        }
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(okAction)
        
        self.present(alertViewController, animated: true, completion: nil)
    }
}
