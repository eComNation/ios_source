//
//  TextCell.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 26/11/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var txtName: UITextField!
    
    var textChanged: ((String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Configuration
    func configureCell() {
        lblName.text = "Enter Text Here"
        txtName.text = ""
    }
    
    @IBAction func textEdited(_ sender: UITextField) {
        if textChanged != nil {
            textChanged!(txtName.text!)
        }
    }
}
