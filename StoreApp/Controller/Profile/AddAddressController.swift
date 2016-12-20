//
//  AddAddressController.swift
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


class AddAddressController: UITableViewController {

    // MARK: Outlets
    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtMobileNo: UITextField!
    @IBOutlet var txtAddress1: UITextField!
    @IBOutlet var txtAddress2: UITextField!
    @IBOutlet var txtCity: UITextField!
    @IBOutlet var txtPinCode: UITextField!
    @IBOutlet var txtCountry: UITextField!
    @IBOutlet var indicatorCountry: NVActivityIndicatorView!
    @IBOutlet var txtState: UITextField!
    @IBOutlet var indicatorState: NVActivityIndicatorView!
    @IBOutlet var indicatorDeleteAddress: NVActivityIndicatorView!
    
    let countryPicker = UIPickerView()
    let statePicker = UIPickerView()
    
    var address: Address?
    var selectedCountry: Country?
    var countryList: [Country] = []
    var selectedState: State?
    var stateList: [State] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title
        self.title = "Add Address"
        
        if address != nil {
            self.title = "Update Address"
        }
        
        prepareUIRelatedResources()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: AddAddressController()))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchCountries()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Preparation methods
    func prepareUIRelatedResources() {
        
        // Set right icon to country text field
        txtCountry.rightViewMode = .always
        txtCountry.rightView = UIImageView(image: UIImage(named: "sort"))
        
        // Set right icon to state text field
        txtState.rightViewMode = .always
        txtState.rightView = UIImageView(image: UIImage(named: "sort"))
        
        // Set picker view to country text field
        countryPicker.delegate = self
        txtCountry.inputView = countryPicker
        
        // Set picker view to state text field
        statePicker.delegate = self
        txtState.inputView = statePicker
        
        // Set input accessory view for country and state text fields
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.done, target: self, action: #selector(selectButtonTapped))
        done.tintColor = UIColor.black
        let cancel: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(cancelButtonTapped))
        cancel.tintColor = UIColor.black
        
        doneToolbar.items = [cancel, flexSpace, done]
        doneToolbar.sizeToFit()
        
        txtCountry.inputAccessoryView = doneToolbar
        txtState.inputAccessoryView = doneToolbar
        
        // Set text if address is already given
        if address != nil {

            txtFirstName.text = address?.first_name
            txtLastName.text = address?.last_name
            txtMobileNo.text = address?.phone
            txtAddress1.text = address?.address1
            txtAddress2.text = address?.address2
            txtCity.text = address?.city
            txtPinCode.text = address?.zipcode
            
            txtCountry.text = address?.country_name
            txtState.text = address?.state_name
            
            if countryList.count > 0 {
                selectedCountry = countryList.filter({ $0.id == address?.country_id }).first
                txtCountry.text = selectedCountry?.name
            }
            
            if stateList.count > 0 {
                selectedState = stateList.filter({ $0.id == address?.state_id }).first
                txtState.text = selectedState?.name
            }
        }
    }
    
    // MARK: Service methods
    func fetchCountries() {

        indicatorCountry.isHidden = false
        txtCountry.isHidden = true
        indicatorCountry.startAnimation()
        
        indicatorState.isHidden = false
        txtState.isHidden = true
        indicatorState.startAnimation()
        
        networkManager.fetchCountries { (success, message, response) -> (Void) in

            self.indicatorCountry.stopAnimation()
            self.indicatorCountry.isHidden = true
            self.txtCountry.isHidden = false
            
            if success {
                self.countryList.removeAll()
                let countryOrder = NSSortDescriptor(key: "position", ascending: true)
                if let countries: [Country] = persistencyManager.fetchAll("Country", predicate: nil, sortDescriptors: [countryOrder]) {
                    self.countryList += countries
                    
                    if self.address != nil {
                        self.selectedCountry = self.countryList.filter({ $0.id == self.address?.country_id }).first
                    } else {
                        self.selectedCountry = self.countryList.first
                    }
                    
                    self.txtCountry.text = self.selectedCountry?.name
                    self.fetchStates()
                }
            }
        }
    }
    
    func fetchStates() {
        
        if let selectedCountryId = selectedCountry?.id {
            
            indicatorState.isHidden = false
            txtState.isHidden = true
            indicatorState.startAnimation()
            
            networkManager.fetchStates(Int(selectedCountryId), completion: { (success, message, response) -> (Void) in

                self.indicatorState.stopAnimation()
                self.indicatorState.isHidden = true
                self.txtState.isHidden = false
                
                if success {
                    self.stateList.removeAll()
                    let stateOrder = NSSortDescriptor(key: "position", ascending: true)
                    if let states: [State] = persistencyManager.fetchAll("State", predicate: nil, sortDescriptors: [stateOrder]) {
                        self.stateList += states
                        
                        if self.address != nil {
                            self.selectedState = self.stateList.filter({ $0.id == self.address?.state_id }).first
                        } else {
                            self.selectedState = self.stateList.first
                        }
                        
                        self.txtState.text = self.selectedState?.name
                    }
                }
            })
        }
    }
    
    func addUpdateAddress() {
        
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
        
        guard !((txtMobileNo.text?.isEmpty)!) else {
            message.title = "Phone no can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtAddress1.text?.isEmpty)!) else {
            message.title = "Address Line 1 can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtCity.text?.isEmpty)!) else {
            message.title = "City can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        guard !((txtPinCode.text?.isEmpty)!) else {
            message.title = "Pincode can't be empty."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }

        guard selectedCountry != nil else {
            message.title = "Country not selected."
            Whisper(message: message, to: navigationController!, action: .Show)
            return
        }
        
        var addressInfo: [String: AnyObject] = [:]
        
        addressInfo["first_name"] = txtFirstName.text as AnyObject?
        addressInfo["last_name"] = txtLastName.text as AnyObject?
        addressInfo["phone"] = txtMobileNo.text as AnyObject?
        addressInfo["address1"] = txtAddress1.text as AnyObject?
        
        if txtAddress2.text?.characters.count > 0 {
            addressInfo["address2"] = txtAddress2.text as AnyObject?
        }
        
        addressInfo["city"] = txtCity.text as AnyObject?
        addressInfo["zipcode"] = txtPinCode.text as AnyObject?
        addressInfo["country_id"] = Int((selectedCountry?.id)!) as AnyObject?
                
        if selectedState != nil {
            addressInfo["state_id"] = Int((selectedState?.id)!) as AnyObject?
            addressInfo["state_name"] = Int((selectedState?.name)!) as AnyObject?
        }

        // If address is available, do updation call, else add new address
        if address != nil {
            
            networkManager.updateCustomerAddress(Int((address?.id)!), address: addressInfo, completion: { (success, message, response) -> (Void) in
                if success {
                    if let addressDict = response!["address"] as? [String : AnyObject] {
                        self.address?.setWithDictionary(addressDict, position: Int((self.address?.position)!))
                        persistencyManager.saveContext()
                    }
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    
                }
            })
            
        } else {
            networkManager.addCustomerAddress(addressInfo) { (success, message, response) -> (Void) in
                if success {
                    _ = self.navigationController?.popViewController(animated: true)
                } else {
                    
                }
            }
        }
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
     
        addUpdateAddress()
    }
    
    @IBAction func deleteAddressTapped(_ sender: UIButton) {
        
        let alertViewController = UIAlertController(title: "Warning", message: "Are you sure you want to delete this address?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "YES", style: .default) { (action) -> Void in
            if let address = self.address {
                self.indicatorDeleteAddress.startAnimation()
                networkManager.deleteCustomerAddresses(Int(address.id), completion: { (success, message, response) -> (Void) in
                    self.indicatorDeleteAddress.stopAnimation()
                    if success {
                        _ = self.navigationController?.popViewController(animated: true)
                    }  else {
                        _ = SweetAlert().showAlert("Failed!", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                    }
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "NO", style: .cancel) { (action) -> Void in
            
        }
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(okAction)
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func selectButtonTapped() {
        print("Select tapped")
        
        if txtCountry.isFirstResponder {

            txtCountry.resignFirstResponder()
            
            if countryList.isEmpty {
                return
            }
            
            selectedCountry = countryList[countryPicker.selectedRow(inComponent: 0)]
            txtCountry.text = selectedCountry?.name
            fetchStates()

            
        } else if txtState.isFirstResponder {

            txtState.resignFirstResponder()
            
            if stateList.isEmpty {
                return
            }
            
            selectedState = stateList[statePicker.selectedRow(inComponent: 0)]
            txtState.text = selectedState?.name
        }
    }
    
    func cancelButtonTapped() {
        print("Cancel tapped")
        txtCountry.resignFirstResponder()
        txtState.resignFirstResponder()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if address != nil {
            return 12
        }
        
        return 10
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

// MARK: Picker view extensions
extension AddAddressController: UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == countryPicker {
            return countryList.count
        } else if pickerView == statePicker {
            return stateList.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == countryPicker {
            return countryList[row].name
        } else if pickerView == statePicker {
            return stateList[row].name
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }
}
