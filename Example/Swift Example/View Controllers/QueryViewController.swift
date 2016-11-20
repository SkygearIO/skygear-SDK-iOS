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
    var recordType: String? = nil
    var predicates = [NSPredicate]()

    var recordTypeSectionIndex = 0
    var predicateSectionIndex = 1

    var lastQueryRecordType: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("LastQueryRecordType")
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "LastQueryRecordType")
            NSUserDefaults.standardUserDefaults().synchronize()
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

    @IBAction func triggerSubmit(sender: AnyObject) {
        if recordType == nil || recordType!.isEmpty {
            let alert = UIAlertController(title: "Required", message: "You must choose a record type", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        let query = SKYQuery(recordType: recordType, predicate: self.predicateFromUI())
        performQuery(query, handler: {
            self.lastQueryRecordType = query.recordType
            self.performSegueWithIdentifier("submit", sender: nil)
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

    func performQuery(query: SKYQuery, handler: (() -> Void)?) {
        SKYContainer.defaultContainer().publicCloudDatabase.performQuery(query) { (objs, error) in
            if error != nil {
                let alert = UIAlertController(title: "Unable to query", message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }

            guard let records = objs as? [SKYRecord] else {
                NSException.raise(NSInternalInconsistencyException, format: "Unable to cast to Records array", arguments: getVaList([]))
                return
            }

            self.records = records

            if handler != nil {
                handler!()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == recordTypeSectionIndex {
            return 1
        } else if section == predicateSectionIndex {
            return self.predicates.count + 1
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == recordTypeSectionIndex {
            let cell = tableView.dequeueReusableCellWithIdentifier("record_type", forIndexPath: indexPath)
            cell.detailTextLabel?.text = self.recordType ?? "Not Selected"
            return cell
        } else if indexPath.section == predicateSectionIndex {
            if indexPath.row == self.predicates.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("new_predicate", forIndexPath: indexPath)
                return cell
            }

            let cell = tableView.dequeueReusableCellWithIdentifier("predicate", forIndexPath: indexPath)
            cell.textLabel?.text = self.predicates[indexPath.row].predicateFormat
            return cell
        }

        return UITableViewCell()
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case predicateSectionIndex:
            return "Predicates"
        default:
            return ""
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "submit" {
            guard let resultUI = segue.destinationViewController as? RecordResultViewController else {
                return
            }

            resultUI.records = records
        } else if segue.identifier == "new_predicate" {
            let controller = segue.destinationViewController as! PredicateViewController
            controller.delegate = self
            controller.deletable = false
        } else if segue.identifier == "record_type" {
            let controller = segue.destinationViewController as! RecordTypeViewController
            controller.selectedRecordType = recordType
            controller.delegate = self
        } else {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let predicate = predicates[indexPath.row]

                let controller = segue.destinationViewController as! PredicateViewController
                controller.predicate = predicate as? NSComparisonPredicate
                controller.delegate = self
                controller.deletable = true
            }
        }
    }

    // MARK: - RecordTypeViewControllerDelegate

    func recordTypeViewController(controller: RecordTypeViewController, didSelectRecordType recordType: String) {
        self.recordType = recordType
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection:0)], withRowAnimation: .None)
    }

    // MARK: - PredicateViewControllerDelegate

    func predicate(controller: PredicateViewController, didFinish predicate: NSComparisonPredicate) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if indexPath.row < self.predicates.count {
                predicates[indexPath.row] = predicate
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            } else {
                predicates.append(predicate)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        } else {
            let indexPath = NSIndexPath(forRow: predicates.count-1, inSection: predicateSectionIndex)
            predicates.append(predicate)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    func predicateDidDelete(controller: PredicateViewController) {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            if indexPath.row < self.predicates.count {
                predicates.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }

}
