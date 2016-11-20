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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "view_record" {
            guard let recordUI = segue.destinationViewController as? RecordViewController else {
                return
            }

            let selectedIndexPath = self.tableView.indexPathForSelectedRow
            recordUI.record = self.records[(selectedIndexPath?.row)!]
            recordUI.delegate = self
        }

    }

    // MARK: - Misc

    func indexOfRecord(recordID: SKYRecordID) -> Int? {
        for (index, element) in self.records.enumerate() {
            if element.recordID.isEqual(recordID) {
                return index
            }
        }
        return nil
    }

    // MARK: - RecordViewControllerDelegate

    func recordViewController(controller: RecordViewController, didSaveRecord record: SKYRecord) {
        guard let index = self.indexOfRecord(record.recordID) else {
            return
        }

        guard index < self.records.count else {
            return
        }

        records[index] = record
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
    }

    func recordViewController(controller: RecordViewController, didDeleteRecordID recordID: SKYRecordID) {
        guard let index = self.indexOfRecord(recordID) else {
            return
        }

        guard index < self.records.count else {
            return
        }

        records.removeAtIndex(index)
        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("record", forIndexPath: indexPath)
        cell.textLabel?.text = self.records[indexPath.row].recordID.recordName
        return cell
    }

}
