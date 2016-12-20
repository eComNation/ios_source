//
//  MyOrdersController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 18/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
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


class MyOrdersController: UITableViewController {

    // MARK: Outlets
    @IBOutlet var footerView: UIView!
    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
    // MARK: Other variables
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    // MARK: Datasource containers
    var orderSectionList: [SectionDetail] = []
    var paginationInfo: PaginationInfo?
    
    // MARK: Life-Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        persistencyManager.deleteAll("OrderInfo")
        fetchOrders()
        
        emptyDataView?.frame = self.tableView.bounds
        self.tableView.backgroundView = emptyDataView
        
        emptyDataView?.onActionButtonTap = {
            self.fetchOrders()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: MyOrdersController()))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Preparation methods
    func prepareOrdersDatasource() {
        
        // Remove all previous sections from product section list
        orderSectionList.removeAll()
        
        let mainSection = SectionDetail()
        
        if persistencyManager.count("OrderInfo") > 0 {
            
            let orderInfoOrder = NSSortDescriptor(key: "position", ascending: true)
            let allOrderInfos = persistencyManager.fetchAll("OrderInfo", predicate: nil, sortDescriptors: [orderInfoOrder])! as [OrderInfo]
            let orderCellSize = CGSize(width: self.view.frame.width, height: 80)
            for orderInfo in allOrderInfos {
                let orderCellDetail = CellDetail()
                orderCellDetail.cellType = .OrderInfo
                orderCellDetail.cellSize = orderCellSize
                orderCellDetail.cellData = orderInfo
                mainSection.sectionDataList.append(orderCellDetail)
            }
        }
        
        orderSectionList.append(mainSection)
        tableView.reloadData()
    }
    
    // MARK: Service methods
    func fetchOrders() {
        
        if paginationInfo != nil && paginationInfo?.nextPage == 0 {
            return
        }
        
        let page: Int = paginationInfo != nil ? (paginationInfo?.nextPage)! : 1
        
        emptyDataView?.showIndicatorView()
        networkManager.fetchCustomerOrders(page) { (success, message, response) -> (Void) in
            
            if success {
                if let responseData = response as? [String : AnyObject] {
                    if let pageDict = responseData["pagination_info"] as? [String : AnyObject] {
                        self.paginationInfo = PaginationInfo(dictionary: pageDict)
                    }
                }
                
                if persistencyManager.count("OrderInfo") == 0 {
                    self.paginationInfo = nil
                    self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "No orders history", buttonTitle: "REFRESH")
                }
                
                self.prepareOrdersDatasource()
            } else {
                self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "No orders history", buttonTitle: "REFRESH")
            }
            
            if self.paginationInfo != nil && self.paginationInfo?.nextPage > 0 {
                self.footerView.isHidden = false
                self.activityIndicator.startAnimation()
            } else {
                self.footerView.isHidden = true
                self.activityIndicator.stopAnimation()
            }
        }
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return orderSectionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if orderSectionList[section].sectionDataList.count == 0 {
            emptyDataView?.isHidden = false
        } else {
            emptyDataView?.isHidden = true
        }
        
        return orderSectionList[section].sectionDataList.count
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
        
        if (indexPath as NSIndexPath).row == orderSectionList[(indexPath as NSIndexPath).section].sectionDataList.count - 1 {
            fetchOrders()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell

        cell.configureWithCellDetail(orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row])
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let orderInfo = orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellData as? OrderInfo {
            if let orderDetailController = UIStoryboard.orderDetailController() {
                orderDetailController.orderInfo = orderInfo
                self.navigationController?.pushViewController(orderDetailController, animated: true)
            }
        }
    }
}
