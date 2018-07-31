//
//  QueryViewController.swift
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
import SKYKit

class QueryViewController: UITableViewController, PredicateViewControllerDelegate, RecordTypeViewControllerDelegate {

    var records = [SKYRecord]()
    var recordType: String?
    var predicates = [NSPredicate]()

    var recordTypeSectionIndex = 0
    var predicateSectionIndex = 1

    var lastQueryRecordType: String? {
        get {
            return UserDefaults.standard.string(forKey: "LastQueryRecordType")
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "LastQueryRecordType")
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        recordType = self.lastQueryRecordType
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    @IBAction func triggerSubmit(_ sender: AnyObject) {
        if recordType == nil || recordType!.isEmpty {
            let alert = UIAlertController(title: "Required", message: "You must choose a record type", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        let query = SKYQuery(recordType: recordType!, predicate: self.predicateFromUI())
        performQuery(query, handler: {
            self.lastQueryRecordType = query.recordType
            self.performSegue(withIdentifier: "submit", sender: nil)
        })
    }

    func predicateFromUI() -> NSPredicate? {
        if self.predicates.count == 0 {
            return nil
        } else if self.predicates.count == 1 {
            return self.predicates.first
        } else {
            let predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: self.predicates)
            return predicate
        }
    }

    func performQuery(_ query: SKYQuery, handler: (() -> Void)?) {
        SKYContainer.default().publicCloudDatabase.performQuery(query) { (records, _, error) in
            if error != nil {
                let alert = UIAlertController(title: "Unable to query", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            guard let records = records else {
                NSException.raise(NSExceptionName.internalInconsistencyException, format: "Unable to cast to Records array", arguments: getVaList([]))
                return
            }

            self.records = records

            if handler != nil {
                handler!()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == recordTypeSectionIndex {
            return 1
        } else if section == predicateSectionIndex {
            return self.predicates.count + 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == recordTypeSectionIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: "record_type", for: indexPath)
            cell.detailTextLabel?.text = self.recordType ?? "Not Selected"
            return cell
        } else if indexPath.section == predicateSectionIndex {
            if indexPath.row == self.predicates.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "new_predicate", for: indexPath)
                return cell
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "predicate", for: indexPath)
            cell.textLabel?.text = self.predicates[indexPath.row].predicateFormat
            return cell
        }

        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case predicateSectionIndex:
            return "Predicates"
        default:
            return ""
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submit" {
            guard let resultUI = segue.destination as? RecordResultViewController else {
                return
            }

            resultUI.records = records
        } else if segue.identifier == "new_predicate" {
            guard let controller = segue.destination as? PredicateViewController else {
                return
            }
            controller.delegate = self
            controller.deletable = false
        } else if segue.identifier == "record_type" {
            guard let controller = segue.destination as? RecordTypeViewController else {
                return
            }
            controller.selectedRecordType = recordType
            controller.delegate = self
        } else {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                guard let controller = segue.destination as? PredicateViewController else {
                    return
                }

                let predicate = predicates[indexPath.row] as? NSComparisonPredicate
                controller.predicate = predicate
                controller.delegate = self
                controller.deletable = true
            }
        }
    }

    // MARK: - RecordTypeViewControllerDelegate

    func recordTypeViewController(_ controller: RecordTypeViewController, didSelectRecordType recordType: String) {
        self.recordType = recordType
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }

    // MARK: - PredicateViewControllerDelegate

    func predicate(_ controller: PredicateViewController, didFinish predicate: NSComparisonPredicate) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if indexPath.row < self.predicates.count {
                predicates[indexPath.row] = predicate
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                predicates.append(predicate)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        } else {
            let indexPath = IndexPath(row: predicates.count-1, section: predicateSectionIndex)
            predicates.append(predicate)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    func predicateDidDelete(_ controller: PredicateViewController) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if indexPath.row < self.predicates.count {
                predicates.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }

}
