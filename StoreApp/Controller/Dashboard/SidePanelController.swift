//
//  SidePanelController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 09/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

let kSidePanelMenuCellIdentifier = "SidePanelMenuCell"

enum SidePanelState {
    case opened
    case closed
}

enum AnimationDirection {
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
}

class SidePanelController: UIViewController {

    // MARK: Outlets
    @IBOutlet var tblMenu: UITableView!
    @IBOutlet var lblShopFor: UILabel!
    
    // MARK: Datasource containers
    var selectedCategory: Category?
    var sectionList: [SectionDetail] = []
    
    // MARK: Other properties
    var shouldAnimate: Bool = false
    var animationDirection: AnimationDirection = .leftToRight
    var onAccountOptionSelected: ((_ option: CellType) -> (Void))?
    var onCategorySelected: ((_ category: Category, _ isForListing: Bool) -> (Void))?
    
    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = SidePanelBGColor
        tblMenu.backgroundColor = SidePanelBGColor
        tblMenu.separatorColor = SidePanelBGColor
        lblShopFor.textColor = SidePanelTextColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: SidePanelController()))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        prepareDataSources(true, animateCell: true, direction: .leftToRight)
    }
    
    // MARK: Preparation Operations
    func prepareDataSources(_ shouldReload: Bool, animateCell: Bool = true, direction: AnimationDirection = .leftToRight) {
        
        shouldAnimate = false
        animationDirection = direction
        
        sectionList.removeAll()
        
        tblMenu.setContentOffset(CGPoint.zero, animated: false)
        
        var indexCounter: Double = 0
        // Prepare previous category section if applicable
        if selectedCategory != nil {
            let previousCategorySectionDetail = SectionDetail()
            previousCategorySectionDetail.sectionType = .PreviousCategory
            previousCategorySectionDetail.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
            previousCategorySectionDetail.sectionDataList = [CellDetail()]
            sectionList.append(previousCategorySectionDetail)
            indexCounter += 1
        }
        
        // Prepare category section detail
        let categorySectionDetail = SectionDetail()
        categorySectionDetail.sectionType = .CategoriesList
        categorySectionDetail.sectionInset = UIEdgeInsetsMake(0, 0, 50, 0)
        
        if selectedCategory != nil {
            let allCategoryProductsCellDetail = CellDetail()
            allCategoryProductsCellDetail.cellData = selectedCategory
            allCategoryProductsCellDetail.cellText = "All " + (selectedCategory?.name)!
            allCategoryProductsCellDetail.cellAnimationDelay = indexCounter / 15.0
            indexCounter += 1
            categorySectionDetail.sectionDataList.append(allCategoryProductsCellDetail)
        }
        
        let categoryPredicate = NSPredicate(format: "parent_id == %d", selectedCategory != nil ? (selectedCategory?.id)! : 0)
        let categoryOrder = NSSortDescriptor(key: "position", ascending: true)
        if let categoriesArray: [Category] = persistencyManager.fetchAll("Category", predicate: categoryPredicate, sortDescriptors: [categoryOrder]) {
            for category in categoriesArray {
                let cellDetail = CellDetail()
                cellDetail.cellData = category
                cellDetail.cellSize = CGSize(width: 0, height: 60)
                cellDetail.cellText = category.name
                cellDetail.cellAnimationDelay = indexCounter / 15.0
                indexCounter += 1
                categorySectionDetail.sectionDataList.append(cellDetail)
            }
        }
        sectionList.append(categorySectionDetail)
        
        // Prepare Account section detail
        let accountSectionDetail = SectionDetail()
        accountSectionDetail.sectionType = .AccountSettings
        accountSectionDetail.sectionInset = UIEdgeInsetsMake(50, 0, 0, 0)
        accountSectionDetail.headerSize = CGSize(width: 0, height: 20)
        
        let contactUsCellDetail = CellDetail()
        contactUsCellDetail.cellType = .ContactUs
        contactUsCellDetail.cellSize = CGSize(width: 0, height: 60)
        contactUsCellDetail.cellText = "Contact Us"
        contactUsCellDetail.cellAnimationDelay = indexCounter / 15.0
        indexCounter += 1
        accountSectionDetail.sectionDataList.append(contactUsCellDetail)

        if customerManager.isCustomerLoggedIn {
            let accountCellDetail = CellDetail()
            accountCellDetail.cellType = .MyAccount
            accountCellDetail.cellSize = CGSize(width: 0, height: 60)
            accountCellDetail.cellText = "My Account"
            accountCellDetail.cellAnimationDelay = indexCounter / 15.0
            indexCounter += 1
            accountSectionDetail.sectionDataList.append(accountCellDetail)
            
            let logoutCellDetail = CellDetail()
            logoutCellDetail.cellType = .Logout
            logoutCellDetail.cellSize = CGSize(width: 0, height: 60)
            logoutCellDetail.cellText = "Logout"
            logoutCellDetail.cellAnimationDelay = indexCounter / 15.0
            indexCounter += 1
            accountSectionDetail.sectionDataList.append(logoutCellDetail)
        } else {
            let loginCellDetail = CellDetail()
            loginCellDetail.cellType = .Login
            loginCellDetail.cellSize = CGSize(width: 0, height: 60)
            loginCellDetail.cellText = "Login"
            loginCellDetail.cellAnimationDelay = indexCounter / 15.0
            indexCounter += 1
            accountSectionDetail.sectionDataList.append(loginCellDetail)
            
            let signUpCellDetail = CellDetail()
            signUpCellDetail.cellType = .SignUp
            signUpCellDetail.cellSize = CGSize(width: 0, height: 60)
            signUpCellDetail.cellText = "Sign Up"
            signUpCellDetail.cellAnimationDelay = indexCounter / 15.0
            indexCounter += 1
            accountSectionDetail.sectionDataList.append(signUpCellDetail)
        }
        
        sectionList.append(accountSectionDetail)
        
        // Reload tableview if specified
        if shouldReload {
            tblMenu.reloadData()
        }
    }
    
    // MARK: Scroll view delegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        shouldAnimate = false
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        shouldAnimate = false
    }
}

// MARK: Tableview delegate methods
extension SidePanelController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch sectionList[(indexPath as NSIndexPath).section].sectionType {
        case .PreviousCategory:
            if selectedCategory != nil {
                let parentCategoryPredicate = NSPredicate(format: "id == %d", (selectedCategory?.parent_id)!)
                selectedCategory = persistencyManager.fetchFirst("Category", predicate: parentCategoryPredicate, sortDescriptors: nil)
                prepareDataSources(true, animateCell: true, direction: .leftToRight)
            }
            break
        case .CategoriesList:
            if let category = sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellData as? Category {
                
                if category.id != selectedCategory?.id {
                    let subCategoryPredicate = NSPredicate(format: "parent_id == %d", category.id)
                    if persistencyManager.count("Category", predicate: subCategoryPredicate) > 0 {
                        selectedCategory = category
                        prepareDataSources(true, animateCell: true, direction: .rightToLeft)
                    } else {
                        onCategorySelected!(category, false)
                    }
                } else {
                    onCategorySelected!(category, categoryListing.contains(category.id))
                }

            }
            
        case .AccountSettings:
            if onAccountOptionSelected != nil {
                onAccountOptionSelected!(sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellType)
            }
            break
        default:
            break
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
        
        
        if shouldAnimate {
            
            switch animationDirection {
            case .leftToRight:
                cell.frame = CGRect(x: -cell.frame.size.width, y: cell.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height)
            case .rightToLeft:
                cell.frame = CGRect(x: cell.frame.size.width, y: cell.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height)
            default:
                cell.frame = CGRect(x: cell.frame.size.width, y: cell.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height)
            }
            
            UIView.animate(withDuration: 0.5, delay: sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellAnimationDelay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations: {
                cell.frame = CGRect(x: 0, y: cell.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height)
                }, completion: { finished in
                    
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionList[section].headerSize.height
    }
}

// MARK: Tablview datasource methods
extension SidePanelController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionList[section].sectionDataList.count
    }
    
    private func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerRect = CGRect(x: 0, y: 0, width: self.view!.frame.size.width, height: sectionList[section].headerSize.height)
        let headerView = UIView(frame: headerRect)
        headerView.backgroundColor = SidePanelBGColor
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kSidePanelMenuCellIdentifier, for: indexPath) as! SidePanelMenuCell
        
        // Configure the cell...
        switch sectionList[(indexPath as NSIndexPath).section].sectionType {
        case .PreviousCategory:
            cell.configureForPreviousCategoryView()
            
        case .CategoriesList:
            cell.configureForCellDetail(sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row], selectedCategoryId: selectedCategory != nil ? Int((selectedCategory?.id)!) : 0)
            
        case .AccountSettings:
            cell.configureForCellDetail(sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row], selectedCategoryId: selectedCategory != nil ? Int((selectedCategory?.id)!) : 0)
            break
            
        default:
            break
        }
        
        return cell
    }
}
