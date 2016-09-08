//
//  RecordViewController.swift
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

protocol RecordViewControllerDelegate {
    func recordViewController(controller: RecordViewController, didSaveRecord record:SKYRecord)
    func recordViewController(controller: RecordViewController, didDeleteRecordID recordID:SKYRecordID)
}

class RecordViewController: UITableViewController, RecordTypeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    enum TableSection {
        case RecordType
        case Metadata
        case Data
    }
    
    @IBOutlet weak var editButton: UIBarButtonItem!

    var recordType: String? = nil
    var record: SKYRecord? = nil {
        didSet {
            if let record = self.record {
                self.attributes = (record.dictionary as! Dictionary<String, AnyObject>).keys.sort()
            } else {
                self.attributes = []
            }
        }
    }
    
    var delegate: RecordViewControllerDelegate? = nil
    var creatingNewRecord: Bool = false
    var readonly: Bool = false
    var selectedAttributeName: String? = nil
    
    internal var attributes: [String] = []
    internal var dateFormatter: NSDateFormatter? = nil
    internal var modified: Bool = false {
        didSet {
            updateModifiedState()
        }
    }
    
    internal var metadata: [(String, AnyObject)] {
        get {
            guard let record = self.record else {
                return []
            }
            
            var metadata: [(String, AnyObject)] = []
            if record.recordID != nil {
                metadata.append(("ID", record.recordID))
            }

            if record.creatorUserRecordID != nil {
                metadata.append(("Created by", record.creatorUserRecordID))
            }

            if record.creationDate != nil {
                metadata.append(("Created at", record.creationDate))
            }

            if record.lastModifiedUserRecordID != nil {
                metadata.append(("Modified by", record.lastModifiedUserRecordID))
            }

            if record.modificationDate != nil {
                metadata.append(("Modified at", record.modificationDate))
            }

            if record.ownerUserRecordID != nil {
                metadata.append(("Owner", record.ownerUserRecordID))
            }
            return metadata
        }
    }
    
    var sections: [TableSection] {
        get {
            var sections: [TableSection] = []
            if self.creatingNewRecord {
                sections.append(.RecordType)
            }
            
            if let record = self.record {
                if record.dictionary.count > 0 || self.canAddRecordAttribute() {
                    sections.append(.Data)
                }
                
                sections.append(.Metadata)
            }
            return sections
        }
    }
    
    var recordTypeSectionIndex: Int? {
        get {
            return self.sections.indexOf(.RecordType)
        }
    }
    
    var dataSectionIndex: Int? {
        get {
            return self.sections.indexOf(.Data)
        }
    }
    
    var metadataSectionIndex: Int? {
        get {
            return self.sections.indexOf(.Metadata)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter = NSDateFormatter()
        dateFormatter!.dateStyle = .FullStyle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        if canDeleteCurrentRecord() {
            super.navigationController?.setToolbarHidden(false, animated: animated)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if canDeleteCurrentRecord() {
            super.navigationController?.setToolbarHidden(true, animated: animated)
        }
    }
    
    // MARK: - Actions
    
    func canDeleteCurrentRecord() -> Bool {
        return !creatingNewRecord && !readonly
    }

    func deleteCurrentRecord() {
        SKYContainer.defaultContainer().publicCloudDatabase.deleteRecordWithID(record?.recordID) { (recordID, error) in
            guard error == nil else  {
                let alert = UIAlertController(title: "Unable to delete", message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            if let delegate = self.delegate {
                delegate.recordViewController(self, didDeleteRecordID: recordID)
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func canSaveCurrentRecord() -> Bool {
        return self.modified && !readonly
    }
    
    func saveCurrentRecord() {
        SKYContainer.defaultContainer().publicCloudDatabase.saveRecord(self.record) { (record, error) in
            if error != nil {
                let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            self.modified = false
            self.creatingNewRecord = false
            if let delegate = self.delegate {
                delegate.recordViewController(self, didSaveRecord: record)
            }
            self.record = record
            self.tableView.reloadData()
        }
    }
    
    @IBAction func triggerSaveRecord(sender: AnyObject) {
        self.saveCurrentRecord()
    }
    
    @IBAction func triggerDeleteRecord(sender: AnyObject) {
        let alert = UIAlertController(title: "Delete Record", message: String(format: "Record %@ will be deleted", (record?.recordID.recordName)!), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) in
            self.deleteCurrentRecord()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.preferredAction = alert.actions.last
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateModifiedState() {
        if canSaveCurrentRecord() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(RecordViewController.triggerSaveRecord(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func canEditRecordAttribute(attribute: String) -> Bool {
        guard !readonly else {
            return false
        }
        
        guard let record = self.record else {
            return false
        }
        
        if let _ = record.objectForKey(attribute) as? String {
            return true
        } else if let _ = record.objectForKey(attribute) as? SKYAsset {
            return true
        }
        return false
    }
    
    func editRecordAttribute(attribute: String) {
        guard let record = self.record else {
            return
        }
        
        selectedAttributeName = attribute
        
        if let _ = record.objectForKey(attribute) as? String {
            editStringRecordAttribute()
        } else if let _ = record.objectForKey(attribute) as? SKYAsset {
            editAssetRecordAttribute()
        }
    }
    
    func replaceCurrentRecordWithType(recordType: String) {
        let data = self.record?.dictionary
        let record = SKYRecord(recordID: SKYRecordID(recordType: recordType), data: data)
        self.record = record
        
        self.tableView.reloadData()
    }
    
    func canAddRecordAttribute() -> Bool {
        return !self.readonly
    }
    
    func addRecordAttribute() {
        let alert = UIAlertController(title: "New Attribute", message: "", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) in
            textField.placeholder = "Attribute Name"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) in
            guard self.record != nil else {
                return
            }

            guard let fieldName = alert.textFields?.first?.text else {
                return
            }
            guard !fieldName.isEmpty else {
                return
            }
            
            self.selectedAttributeName = fieldName
            self.chooseRecordAttributeType()
        }))
        alert.preferredAction = alert.actions.last
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func chooseRecordAttributeType() {
        let alert = UIAlertController(title: "Attribute Type", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "String", style: .Default, handler: { (action) in
            self.editStringRecordAttribute()
        }))
        alert.addAction(UIAlertAction(title: "Asset", style: .Default, handler: { (action) in
            self.editAssetRecordAttribute()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.preferredAction = alert.actions.last
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func editStringRecordAttribute() {
        let alert = UIAlertController(title: "String Value", message: "", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) in
            textField.placeholder = "Value"
            
            if let record = self.record {
                textField.text = record.objectForKey(self.selectedAttributeName) as? String
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) in
            guard let record = self.record else {
                return
            }
            guard let fieldName = self.selectedAttributeName, fieldValue = alert.textFields?.last?.text else {
                return
            }
            guard !fieldName.isEmpty else {
                return
            }
            
            record.setObject(fieldValue, forKey: fieldName)
            self.insertOrReloadAttribute(fieldName)
            self.modified = true
        }))
        alert.preferredAction = alert.actions.last
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func editAssetRecordAttribute() {
        let alert = UIAlertController(title: "Asset",
                                      message: "Choose image from:",
                                      preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) in
            self.editAssetRecordAttribute(.Camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) in
            self.editAssetRecordAttribute(.PhotoLibrary)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func editAssetRecordAttribute(type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .SavedPhotosAlbum
        imagePicker.delegate = self
        self.navigationController?.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func insertOrReloadAttribute(attribute: String) {
        if !self.attributes.contains(attribute) {
            self.attributes.append(attribute)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.attributes.count - 1, inSection: self.dataSectionIndex!)],
                                                  withRowAnimation: .Automatic)
        } else {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: self.attributes.count - 1, inSection: self.dataSectionIndex!)],
                                                  withRowAnimation: .Automatic)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "record_type" {
            let controller = segue.destinationViewController as! RecordTypeViewController
            controller.delegate = self
            controller.selectedRecordType = self.recordType
        }
    }

    // MARK: - RecordTypeViewControllerDelegate
    
    func recordTypeViewController(controller: RecordTypeViewController, didSelectRecordType recordType: String) {
        self.recordType = recordType
        self.replaceCurrentRecordWithType(recordType)
        self.modified = true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == recordTypeSectionIndex {
            return 1
        } else if section == dataSectionIndex {
            guard let record = self.record else {
                return 0
            }
            
            var count = record.dictionary.count
            if canAddRecordAttribute() {
                count += 1
            }
            return count
        } else if section == metadataSectionIndex {
            return self.record != nil ? metadata.count : 0
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == metadataSectionIndex {
            return "Metadata"
        } else {
            return ""
        }
    }
    
    func detailText(attributeValue: AnyObject?) -> String {
        guard attributeValue != nil else {
            return ""
        }
        
        if let value = attributeValue as? String {
            return value
        } else if let value = attributeValue as? NSDate {
            return dateFormatter!.stringFromDate(value)
        } else if let value = attributeValue as? SKYRecordID {
            return value.canonicalString
        } else {
            return attributeValue!.description
        }
    }
    
    func cellForMetadataRow(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("metadata", forIndexPath: indexPath)

        var titleText: String, detailValue: AnyObject
        (titleText, detailValue) = self.metadata[indexPath.row]
        
        cell.textLabel?.text = titleText
        cell.detailTextLabel?.text = detailText(detailValue)
        return cell
    }
    
    func cellForDataRow(indexPath: NSIndexPath) -> UITableViewCell {
        guard let record = self.record else {
            return UITableViewCell()
        }
        
        guard indexPath.row < self.attributes.count else {
            return UITableViewCell()
        }
        
        let attribute = self.attributes[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("data", forIndexPath: indexPath)
        cell.textLabel?.text = attribute
        cell.detailTextLabel?.text = detailText((record.dictionary[attribute])!)
        cell.accessoryType = self.canEditRecordAttribute(attribute) ? .DisclosureIndicator : .None
        return cell
    }
    
    func cellForNewAttributeRow(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("new_attribute", forIndexPath: indexPath)
        return cell
    }
    
    func cellForRecordTypeRow(indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("record_type", forIndexPath: indexPath)
        cell.detailTextLabel?.text = recordType
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == recordTypeSectionIndex {
            return cellForRecordTypeRow(indexPath)
        } else if indexPath.section == dataSectionIndex {
            if indexPath.row == self.attributes.count {
                return cellForNewAttributeRow(indexPath)
            } else if indexPath.row < self.attributes.count {
                return cellForDataRow(indexPath)
            } else {
                return UITableViewCell()
            }
        } else if indexPath.section == metadataSectionIndex {
            return cellForMetadataRow(indexPath)
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == dataSectionIndex {
            if indexPath.row == self.attributes.count {
                return self.canAddRecordAttribute() ? indexPath : nil
            } else if indexPath.row < self.attributes.count {
                return self.canEditRecordAttribute(attributes[indexPath.row]) ? indexPath : nil
            } else {
                return nil
            }
        } else if indexPath.section == recordTypeSectionIndex {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == dataSectionIndex {
            if indexPath.row == self.attributes.count {
                self.addRecordAttribute()
            } else if indexPath.row < self.attributes.count {
                self.editRecordAttribute(attributes[indexPath.row])
            }
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        let asset = SKYAsset(data: UIImagePNGRepresentation(image))
        asset.mimeType = "image/png"

        SKYContainer.defaultContainer().uploadAsset(asset) { (asset, error) in
            if error != nil {
                let alert = UIAlertController(title: "Unable to upload", message: error!.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            
            guard let record = self.record else{
                return
            }
            
            guard let fieldName = self.selectedAttributeName else {
                return
            }

            record.setObject(asset, forKey: fieldName)
            self.insertOrReloadAttribute(fieldName)
            self.modified = true
        }
    }
}
