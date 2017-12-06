//
//  PredicateViewController.swift
//  SKYKit - Swift Example
//
//  Copyright 2015 Oursky Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

protocol PredicateViewControllerDelegate: class {
    func predicate(_ controller: PredicateViewController, didFinish predicate: NSComparisonPredicate)
    func predicateDidDelete(_ controller: PredicateViewController)
}

class PredicateViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    weak var delegate: PredicateViewControllerDelegate?
    var attributeNameCell: TextFieldTableViewCell?
    var attributeValueCell: TextFieldTableViewCell?
    var comparisonPickerCell: PickerTableViewCell?
    var attributeName: String?
    var predicateOperator: Int = 0
    var attributeValue: AnyObject?
    var deletable: Bool = true
    var isDeleting: Bool = false

    var predicate: NSComparisonPredicate? {
        get {
            return self.createPredicateWithUI()
        }

        set {
            self.updateUIWithPredicate(newValue)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if !deletable {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if let attributeNameCell = self.attributeNameCell {
            attributeNameCell.textField.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let cell = self.attributeNameCell {
            attributeName = cell.textField.text
        }
        if let cell = self.attributeValueCell {
            attributeValue = cell.textField.text as AnyObject
        }
        if let cell = self.comparisonPickerCell {
            predicateOperator = cell.picker.selectedRow(inComponent: 0)
        }

        if self.predicate != nil && !isDeleting {
            if let delegate = self.delegate {
                delegate.predicate(self, didFinish: predicate!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    func updateUIWithPredicate(_ optionalPredicate: NSComparisonPredicate?) {
        guard let predicate = optionalPredicate else {
            attributeName = nil
            predicateOperator = 0
            attributeValue = nil
            return
        }

        attributeName = predicate.leftExpression.keyPath
        attributeValue = predicate.rightExpression.constantValue as AnyObject

        switch predicate.predicateOperatorType {
        case .equalTo:
            predicateOperator = 0
        case .notEqualTo:
            predicateOperator = 1
        case .like:
            if predicate.options == .caseInsensitive {
                predicateOperator = 3
            } else {
                predicateOperator = 2
            }
        default:
            predicateOperator = 0
        }
    }

    func createPredicateWithUI() -> NSComparisonPredicate? {
        guard let attributeName = self.attributeName else {
            return nil
        }

        guard !attributeName.isEmpty else {
            return nil
        }

        guard let attributeValue = self.attributeValue else {
            return nil
        }

        let leftExpr = NSExpression(forKeyPath: attributeName)
        let rightExpr = NSExpression(forConstantValue: attributeValue)
        var predicate: NSComparisonPredicate? = nil

        switch predicateOperator {
        case 0:
            predicate = NSComparisonPredicate(leftExpression: leftExpr,
                                              rightExpression: rightExpr,
                                              modifier: .direct,
                                              type: .equalTo,
                                              options: .normalized)
        case 1:
            predicate = NSComparisonPredicate(leftExpression: leftExpr,
                                              rightExpression: rightExpr,
                                              modifier: .direct,
                                              type: .notEqualTo,
                                              options: .normalized)
        case 2:
            predicate = NSComparisonPredicate(leftExpression: leftExpr,
                                              rightExpression: rightExpr,
                                              modifier: .direct,
                                              type: .like,
                                              options: .normalized)
        case 3:
            predicate = NSComparisonPredicate(leftExpression: leftExpr,
                                              rightExpression: rightExpr,
                                              modifier: .direct,
                                              type: .like,
                                              options: .caseInsensitive)
        default:
            break
        }
        return predicate
    }

    @IBAction func triggerDelete(_ sender: AnyObject) {
        isDeleting = true
        if let delegate = self.delegate {
            delegate.predicateDidDelete(self)
        }
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Attribute Name"
        case 1:
            return "Comparison"
        case 2:
            return "Attribute Value"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let attributeNameCell = self.attributeNameCell {
                    return attributeNameCell
                }
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "textfield", for: indexPath) as! TextFieldTableViewCell
                attributeNameCell = cell
                attributeNameCell?.textField.text = attributeName
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if let comparisonPickerCell = self.comparisonPickerCell {
                    return comparisonPickerCell
                }
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "picker", for: indexPath) as! PickerTableViewCell
                comparisonPickerCell = cell
                comparisonPickerCell?.picker.selectRow(predicateOperator, inComponent: 0, animated: true)
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                if let attributeValueCell = self.attributeValueCell {
                    return attributeValueCell
                }
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "textfield", for: indexPath) as! TextFieldTableViewCell
                attributeValueCell = cell
                attributeValueCell?.textField.text = attributeValue as? String
                return cell
            }
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 0, section: 1) {
            return 150
        } else {
            return tableView.rowHeight
        }
    }

    // MARK: - UIPickerViewDelegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "equals"
        case 1:
            return "not equal to"
        case 2:
            return "like"
        case 3:
            return "case-insensitive like"
        default:
            return ""
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == attributeNameCell?.textField {
            textField.resignFirstResponder()
            return true
        }
        return true
    }

}
