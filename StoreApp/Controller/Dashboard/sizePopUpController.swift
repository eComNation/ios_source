//
//  sizePopUpController.swift
//  ViraniGems
//
//  Created by Coruscate's macmini on 9/1/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class sizePopUpController: UIViewController {

    /*var metalSize: [MetalSizeInfo] = []
    var selectedIndex : Int = Int()
    var isValue : Bool = Bool()
    
    
    @IBOutlet var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isValue = false
        tableview.separatorStyle = UITableViewCellSeparatorStyle.none
        
        for index in 0..<metalSize.count {
            
            if metalSize[index].is_default == true {
                
                tableview.scrollToRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .Middle, animated: false)
 
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("metalSizeCell", forIndexPath: indexPath) as! ProductCell
        cell.selectionStyle = .None
        cell.titleLbl.text = metalSize[indexPath.row].name
        
        if metalSize[indexPath.row].is_default == true {
            
            cell.radioBtn.selected = true
        }
        else
        {
            cell.radioBtn.selected = false
        }
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        for index in 0..<metalSize.count {
            
            metalSize[index].is_default = false
        }
        
        metalSize[indexPath.row].is_default = true
        selectedIndex = indexPath.row
        isValue = true
     
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }*/
   
}
