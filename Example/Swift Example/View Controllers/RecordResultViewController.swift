//
//  RecordResultViewController.swift
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

class RecordResultViewController: UITableViewController, RecordViewControllerDelegate {

    var records: [SKYRecord] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "view_record" {
            guard let recordUI = segue.destination as? RecordViewController else {
                return
            }

            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            recordUI.record = self.records[(selectedIndexPath?.row)!]
            recordUI.delegate = self
        }

    }

    // MARK: - Misc

    func indexOfRecord(_ recordID: String) -> Int? {
        for (index, element) in self.records.enumerated() {
            if element.recordID.isEqual(recordID) {
                return index
            }
        }
        return nil
    }

    // MARK: - RecordViewControllerDelegate

    func recordViewController(_ controller: RecordViewController, didSaveRecord record: SKYRecord) {
        guard let index = self.indexOfRecord(record.recordID) else {
            return
        }

        guard index < self.records.count else {
            return
        }

        records[index] = record
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func recordViewController(_ controller: RecordViewController, didDeleteRecordID recordID: String) {
        guard let index = self.indexOfRecord(recordID) else {
            return
        }

        guard index < self.records.count else {
            return
        }

        records.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "record", for: indexPath)
        cell.textLabel?.text = self.records[indexPath.row].recordID
        return cell
    }

}
