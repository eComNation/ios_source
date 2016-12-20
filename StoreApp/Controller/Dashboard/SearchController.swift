//
//  SearchController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 01/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class SearchController: UIViewController {

    @IBOutlet var txtSearch: UITextField!
    @IBOutlet var tblRecentSearch: UITableView!
    @IBOutlet var btnClearSearch: UIButton!
    @IBOutlet var btnClearSearchHeight: NSLayoutConstraint!
    
    var cancelledSearch: (() -> ())?
    var searchForString: ((String) -> ())?
    var searchString: String?
    var sectionList: [SectionDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if searchString != nil {
            txtSearch.text = searchString
        }
        
        btnClearSearch.backgroundColor = GeneralButtonColor
        prepareRecentSearchDatasource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: SearchController()))
        
        txtSearch.becomeFirstResponder()
        
        btnClearSearchHeight.constant = 0
        if searchString?.isNotEmpty == true {
            btnClearSearchHeight.constant = 30
        }
        
        self.view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Data source preparation
    func prepareRecentSearchDatasource() {
        
        // Remove all previous sections from filter section list
        sectionList.removeAll()
        
        let sortDescriptor = NSSortDescriptor(key: "position", ascending: true)
        
        if let recentSearchArray: [RecentSearch] = persistencyManager.fetchAll("RecentSearch", predicate: nil, sortDescriptors: [sortDescriptor]) , recentSearchArray.count > 0 {
            
            print(recentSearchArray.count)
            
            let sectionDetail = SectionDetail()
            sectionDetail.sectionType = .RecentSearch
            
            for recentSearch in recentSearchArray {
                let cellDetail = CellDetail()
                cellDetail.cellData = recentSearch
                cellDetail.cellSize = CGSize(width: 0, height: 40)
                cellDetail.cellText = recentSearch.searchString
                sectionDetail.sectionDataList.append(cellDetail)
            }
            
            sectionList.append(sectionDetail)
        }
        
        tblRecentSearch.reloadData()
    }
    
    // MARK: Button events
    @IBAction func cancelTapped(_ sender: UIButton) {

        if cancelledSearch != nil {
            cancelledSearch!()
        }
    }
    
    @IBAction func searchTapped(_ sender: UIButton) {
    
        if searchForString != nil {
            searchForString!(txtSearch.text!)
        }
    }
    
    @IBAction func clearSearchTapped(_ sender: UIButton) {
        
        if searchForString != nil {
            searchForString!("")
        }
    }
    
    @IBAction func clearRecentSearchTapped(_ sender: UIButton) {
        
        persistencyManager.deleteAll("RecentSearch")
        prepareRecentSearchDatasource()
    }
}

extension SearchController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if searchForString != nil {
            searchForString!(textField.text!)
        }
        
        return true
    }
}

// MARK: Tableview delegate methods
extension SearchController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellDetail = sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row]
        if searchForString != nil {
            searchForString!(cellDetail.cellText!)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionList[section].headerSize.height
    }
}

// MARK: Tablview datasource methods
extension SearchController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionList[section].sectionDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath) as! RecentSearchCell
        let cellDetail = sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row]
        
        cell.configureWithCellDetail(cellDetail)
        
        return cell
    }
}

