//
//  SizeSelectionView.swift
//  Timberfruit
//
//  Created by Rakesh Pethani on 01/08/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class SizeSelectionView: UIView {

    var level = 1
    
    var selectionMadeForLevel: ((Int, String, Int) -> ())?
    
    let sizePicker = UIPickerView()
    let quantityPicker = UIPickerView()
    
    var sizeList: [String] = ["Standard"]
    var quantityList: [String] = ["0", "1", "2", "3", "4", "5", "6"]
    
    var selectedSize = ""
    var selectedQuantity = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUIElementsWithTitle(_ title: String, size: String, quantity: String, lvl: Int, sizes:[String]) {
        
        level = lvl
        sizeList = sizes
        
        selectedSize = size
        selectedQuantity = Int(quantity)!
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        var y: CGFloat = 8
        let width = self.frame.size.width
        let portionWidth = (width / 2) - 16
        
        let firstX: CGFloat = 8
        let secondX: CGFloat = (width / 2) + 8
        
        let lblTitle = UILabel(frame: CGRect(x: firstX, y: y, width: width - 16, height: 21))
        if #available(iOS 8.2, *) {
            lblTitle.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        } else {
            lblTitle.font = UIFont.systemFont(ofSize: 14)
        }
        lblTitle.text = title.uppercased()
        lblTitle.textAlignment = .center
        lblTitle.tag = 1
        self.addSubview(lblTitle)
        
        y += 28
        
        let lblSize = UILabel(frame: CGRect(x: firstX, y: y, width: 21, height: 11))
        lblSize.font = UIFont.systemFont(ofSize: 9)
        lblSize.text = "SIZE"
        self.addSubview(lblSize)
        
        let lblQuantity = UILabel(frame: CGRect(x: secondX, y: y, width: 48, height: 11))
        lblQuantity.font = UIFont.systemFont(ofSize: 9)
        lblQuantity.text = "QUANTITY"
        self.addSubview(lblQuantity)
        
        y += 18
        
        let txtSize = UITextField(frame: CGRect(x: firstX, y: y, width: portionWidth, height: 47))
        txtSize.text = "  " + size
        txtSize.borderStyle = .none
        txtSize.backgroundColor = UIColor(hexString: "E6E6E6")
        txtSize.layer.borderColor = UIColor.lightGray.cgColor
        txtSize.layer.borderWidth = 0.5
        txtSize.layer.cornerRadius = 2.0
        txtSize.layer.masksToBounds = true
        txtSize.rightViewMode = .always
        txtSize.rightView = UIImageView(image: UIImage(named: "sort"))
        sizePicker.delegate = self
        txtSize.inputView = sizePicker
        txtSize.tag = 2
        self.addSubview(txtSize)
        
        let txtQuantity = UITextField(frame: CGRect(x: secondX, y: y, width: portionWidth, height: 47))
        txtQuantity.text = "  " + quantity
        txtQuantity.borderStyle = .none
        txtQuantity.backgroundColor = UIColor(hexString: "E6E6E6")
        txtQuantity.layer.borderColor = UIColor.lightGray.cgColor
        txtQuantity.layer.borderWidth = 0.5
        txtQuantity.layer.cornerRadius = 2.0
        txtQuantity.layer.masksToBounds = true
        txtQuantity.rightViewMode = .always
        txtQuantity.rightView = UIImageView(image: UIImage(named: "sort"))
        quantityPicker.delegate = self
        txtQuantity.inputView = quantityPicker
        txtQuantity.tag = 3
        self.addSubview(txtQuantity)
        
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
        
        txtSize.inputAccessoryView = doneToolbar
        txtQuantity.inputAccessoryView = doneToolbar
    }
    
    func selectButtonTapped() {
        print("Select tapped")
        
        if let txtSize = self.viewWithTag(2) as? UITextField, let txtQuantity = self.viewWithTag(3) as? UITextField {
            if txtSize.isFirstResponder {
                
                txtSize.resignFirstResponder()
                
                if sizeList.isEmpty {
                    return
                }
                
                selectedSize = sizeList[sizePicker.selectedRow(inComponent: 0)]
                txtSize.text = "  " + sizeList[sizePicker.selectedRow(inComponent: 0)]

            }  else if txtQuantity.isFirstResponder {
                
                txtQuantity.resignFirstResponder()
                
                if quantityList.isEmpty {
                    return
                }

                selectedQuantity = Int(quantityList[quantityPicker.selectedRow(inComponent: 0)])!
                txtQuantity.text = "  " + quantityList[quantityPicker.selectedRow(inComponent: 0)]
            }
            
            if selectionMadeForLevel != nil {
//                selectionMadeForLevel!(level, sizeList[sizePicker.selectedRowInComponent(0)], Int(quantityList[quantityPicker.selectedRowInComponent(0)])!)
                selectionMadeForLevel!(level, selectedSize, selectedQuantity)
            }
        }
    }
    
    func cancelButtonTapped() {
        print("Cancel tapped")
        self.endEditing(true)
    }
}

// MARK: Picker view extensions
extension SizeSelectionView: UIPickerViewDelegate {
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == sizePicker {
            return sizeList.count
        } else {
            return quantityList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == sizePicker {
            return sizeList[row]
        } else {
            return quantityList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}
