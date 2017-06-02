//
//  RecordTypeViewController.swift
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

protocol RecordTypeViewControllerDelegate {
    func recordTypeViewController(_ controller: RecordTypeViewController, didSelectRecordType recordType: String)
}

class RecordTypeViewController: UITableViewController {

    var knownRecordTypes: [String] {
        get {
            if let value = UserDefaults.standard.array(forKey: "KnownRecordTypes") as? [String] {
                return value
            }
            return []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "KnownRecordTypes")
            UserDefaults.standard.synchronize()
        }
    }

    var selectedRecordTypeIndex: Int?

    var selectedRecordType: String? {
        get {
            guard let index = selectedRecordTypeIndex else {
                return nil
            }

            guard index < knownRecordTypes.count else {
                return nil
            }

            return knownRecordTypes[index]
        }
        set {
            guard let val = newValue else {
                self.selectedRecordTypeIndex = nil
                return
            }

            guard val != "" else {
                self.selectedRecordTypeIndex = nil
                return
            }

            guard knownRecordTypes.contains(val) else {
                self.knownRecordTypes.append(val)
                self.selectedRecordTypeIndex = self.knownRecordTypes.count - 1
                return
            }

            self.selectedRecordTypeIndex = knownRecordTypes.index(of: val)
        }
    }

    var delegate: RecordTypeViewControllerDelegate?

    let listSectionIndex = 0
    let addNewSectionIndex = 1

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let delegate = self.delegate {
            if let recordType = self.selectedRecordType {
                delegate.recordTypeViewController(self, didSelectRecordType: recordType)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case listSectionIndex:
            return knownRecordTypes.count
        case addNewSectionIndex:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default", for: indexPath)
        switch indexPath.section {
        case listSectionIndex:
            if self.knownRecordTypes.count > indexPath.row {
                let recordType = self.knownRecordTypes[indexPath.row]
                cell.textLabel?.text = recordType
                cell.accessoryType = self.selectedRecordTypeIndex == indexPath.row ? .checkmark : .none
            } else {
                cell.textLabel?.text = ""
                cell.accessoryType = .none
            }
            break
        case addNewSectionIndex:
            cell.textLabel?.text = "Add New Record Type..."
            break
        default:
            break
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case listSectionIndex:
            return "Record Types"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case listSectionIndex:
            guard indexPath.row < self.knownRecordTypes.count else {
                return
            }

            var indexPathsToUpdate = [indexPath]
            if let selectedRecordTypeIndex = self.selectedRecordTypeIndex {
                indexPathsToUpdate.append(IndexPath(row: selectedRecordTypeIndex, section: listSectionIndex))
            }

            self.selectedRecordTypeIndex = indexPath.row

            self.tableView.reloadRows(at: indexPathsToUpdate, with: .none)
            break
        case addNewSectionIndex:
            let alert = UIAlertController(title: "Add New", message: "Enter name of new record type", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Record Type"
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
                guard let recordTypeToAdd = alert.textFields?.first?.text else {
                    return
                }

                guard !recordTypeToAdd.isEmpty else {
                    return
                }

                var indexPathsToUpdate: [IndexPath] = []
                if let selectedRecordTypeIndex = self.selectedRecordTypeIndex {
                    indexPathsToUpdate.append(IndexPath(row: selectedRecordTypeIndex, section: self.listSectionIndex))
                }

                self.knownRecordTypes.append(recordTypeToAdd)
                self.selectedRecordTypeIndex = self.knownRecordTypes.count - 1

                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: self.knownRecordTypes.count - 1, section: self.listSectionIndex)],
                    with: .automatic)
                if indexPathsToUpdate.count > 0 {
                    self.tableView.reloadRows(at: indexPathsToUpdate, with: .none)
                }
                self.tableView.endUpdates()
            }))
            alert.preferredAction = alert.actions.last
            self.present(alert, animated: true, completion: {
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            break
        default:
            break
        }

    }
}
