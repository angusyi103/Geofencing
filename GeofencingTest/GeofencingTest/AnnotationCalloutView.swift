//
//  AnnotationCalloutView.swift
//  GeofencingTest
//
//  Created by Angus Yi on 2020/11/16.
//

import SwiftUI

protocol AnnotationCalloutViewDelegate {
    func saveBtnPressed()
}

class AnnotationCalloutView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var pinNameTextfield: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var delegate: AnnotationCalloutViewDelegate?
   
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "\(self)", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as! UIView
    }
    
    func initUI() {
        saveBtn.isHidden = true
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        delegate?.saveBtnPressed()
    }
    
    //MARK: textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var name = textField.text
        if name!.count >= range.location + string.count {
            name = (name! as NSString).replacingCharacters(in: range, with: string)
        } else {
            name = name?.appending(string)
        }
        
        saveBtn.isHidden = name!.count > 0 ? true : false
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.count != 0 {
            saveBtn.isHidden = false
        }
        return true
    }
    
}

