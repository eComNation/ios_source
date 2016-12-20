//
//  OrderDetailController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 22/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class OrderDetailController: UITableViewController {

    // MARK: Other variables
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    // MARK: Datasource containers
    var orderSectionList: [SectionDetail] = []
    var orderInfo: OrderInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title of navigation bar
        if let orderNumber = orderInfo?.number {
            self.title = "Order #\(orderNumber)"
        }

        fetchOrderInfo()
        
        emptyDataView?.frame = self.tableView.bounds
        self.tableView.backgroundView = emptyDataView
        
        emptyDataView?.onActionButtonTap = {
            self.fetchOrderInfo()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: MyFavouritesController()))
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
        
        if orderInfo != nil {
            
            // Prepare basic cell info
            let orderBasicCellDetail = CellDetail()
            orderBasicCellDetail.cellType = .OrderBasicInfo
            orderBasicCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 160)
            orderBasicCellDetail.cellData = orderInfo
            mainSection.sectionDataList.append(orderBasicCellDetail)
            
            // Prepare items cell info
            let orderItemPredicate = NSPredicate(format: "SELF.orderInfo.id == %d", (orderInfo?.id)!)
            let orderItemOrder = NSSortDescriptor(key: "position", ascending: true)
            if let allOrderItems = persistencyManager.fetchAll("OrderItem", predicate: orderItemPredicate, sortDescriptors: [orderItemOrder]) ,  allOrderItems.count > 0 {
             
                for orderItem in allOrderItems {
                    let orderItemCellDetail = CellDetail()
                    orderItemCellDetail.cellType = .OrderItemsInfo
                    orderItemCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 100)
                    orderItemCellDetail.cellData = orderItem
                    mainSection.sectionDataList.append(orderItemCellDetail)
                }
            }
            
            // Prepare pricing cell info
            let orderPricingCellDetail = CellDetail()
            orderPricingCellDetail.cellType = .OrderPricingInfo
            orderPricingCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 160)
            orderPricingCellDetail.cellData = orderInfo
            mainSection.sectionDataList.append(orderPricingCellDetail)
        }
        
        orderSectionList.append(mainSection)
        tableView.reloadData()
    }
    
    // MARK: Service methods
    func fetchOrderInfo() {
        
        emptyDataView?.showIndicatorView()
        
        networkManager.fetchOrderInfo(Int((orderInfo?.id)!)) { (success, message, response) -> (Void) in
            
            if success {
                if let orderDict = response!["order"] as? [String : AnyObject] {
                    self.orderInfo?.setWithDictionary(orderDict, position: Int((self.orderInfo?.position)!))
                    persistencyManager.saveContext()
                    self.prepareOrdersDatasource()
                }
            } else {
                self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "No order info to show", buttonTitle: "REFRESH")
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellSize.height
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
        
        let cellDetail = orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row]
        
        switch cellDetail.cellType {
        
        case .OrderBasicInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderBasicInfoCell", for: indexPath) as! OrderBasicInfoCell
            cell.configureWithCellDetail(orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row])
            return cell
            
        case .OrderItemsInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemInfoCell", for: indexPath) as! OrderItemInfoCell
            cell.configureWithCellDetail(orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row])
            return cell
            
        case .OrderPricingInfo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderPricingInfoCell", for: indexPath) as! OrderPricingInfoCell
            cell.configureWithCellDetail(orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row])
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
}
