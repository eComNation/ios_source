//
//  MyAddressesController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 24/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class MyAddressesController: UITableViewController {

    // MARK: Other variables
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    // MARK: Datasource containers
    var addressSectionList: [SectionDetail] = []
    
    // MARK: Life-Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        persistencyManager.deleteAll("Address")
        fetchAddresses()
        
        emptyDataView?.frame = self.tableView.bounds
        self.tableView.backgroundView = emptyDataView
        
        emptyDataView?.onActionButtonTap = { [weak emptyDataView] in
            if emptyDataView?.btnAction.titleLabel?.text == "REFRESH" {
                self.fetchAddresses()
            } else {
                self.navigationController?.pushViewController(UIStoryboard.addAddressController()!, animated: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: MyAddressesController()))
        
        prepareAddressDatasource()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Preparation methods
    func prepareAddressDatasource() {
        
        // Remove all previous sections from product section list
        addressSectionList.removeAll()
        
        let mainSection = SectionDetail()
        
        if persistencyManager.count("Address") > 0 {
            
            let addressOrder = NSSortDescriptor(key: "position", ascending: true)
            let allAddresses = persistencyManager.fetchAll("Address", predicate: nil, sortDescriptors: [addressOrder])! as [Address]
            let addressCellSize = CGSize(width: self.view.frame.width, height: 90)
            for address in allAddresses {
                let addressCellDetail = CellDetail()
                addressCellDetail.cellType = .Address
                addressCellDetail.cellSize = addressCellSize
                addressCellDetail.cellData = address
                mainSection.sectionDataList.append(addressCellDetail)
            }
        }
        
        addressSectionList.append(mainSection)
        tableView.reloadData()
    }
    
    // MARK: Service methods
    func fetchAddresses() {
        
        emptyDataView?.showIndicatorView()
        networkManager.fetchCustomerAddresses() { (success, message, response) -> (Void) in
            
            if success {
                self.prepareAddressDatasource()
                if persistencyManager.count("Address") == 0 {
                    self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "No addresses", buttonTitle: "ADD ADDRESS")
                }
            } else {
                self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "Something went wrong", buttonTitle: "REFRESH")
            }
        }
    }

    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return addressSectionList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if addressSectionList[section].sectionDataList.count == 0 {
            emptyDataView?.isHidden = false
        } else {
            emptyDataView?.isHidden = true
        }
        
        return addressSectionList[section].sectionDataList.count
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressCell
        
        let cellDetail = addressSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row]
        cell.configureWithCellDetail(cellDetail)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellDetail = addressSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row]
        let addAddressController = UIStoryboard.addAddressController()
        addAddressController?.address = cellDetail.cellData as? Address
        self.navigationController?.pushViewController(addAddressController!, animated: true)
    }
}
