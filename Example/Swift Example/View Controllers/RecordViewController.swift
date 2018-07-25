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

protocol RecordViewControllerDelegate: class {
    func recordViewController(_ controller: RecordViewController, didSaveRecord record: SKYRecord)
    func recordViewController(_ controller: RecordViewController, didDeleteRecordID recordID: String)
}

class RecordViewController: UITableViewController, RecordTypeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    enum TableSection {
        case recordType
        case metadata
        case data
    }

    @IBOutlet weak var editButton: UIBarButtonItem!

    var recordType: String?
    var record: SKYRecord? = nil {
        didSet {
            if let record = self.record, let dict = record.dictionary as? [String: AnyObject] {
                self.attributes = dict.keys.sorted()
            } else {
                self.attributes = []
            }
        }
    }

    weak var delegate: RecordViewControllerDelegate?
    var creatingNewRecord: Bool = false
    var readonly: Bool = false
    var selectedAttributeName: String?

    internal var attributes: [String] = []
    internal var dateFormatter: DateFormatter?
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
            metadata.append(("Type", record.recordType as AnyObject))
            metadata.append(("ID", record.recordID as AnyObject))

            if record.creatorUserRecordID != nil {
                metadata.append(("Created by", record.creatorUserRecordID as AnyObject))
            }

            if record.creationDate != nil {
                metadata.append(("Created at", record.creationDate as AnyObject))
            }

            if record.lastModifiedUserRecordID != nil {
                metadata.append(("Modified by", record.lastModifiedUserRecordID as AnyObject))
            }

            if record.modificationDate != nil {
                metadata.append(("Modified at", record.modificationDate as AnyObject))
            }

            if record.ownerUserRecordID != nil {
                metadata.append(("Owner", record.ownerUserRecordID as AnyObject))
            }
            return metadata
        }
    }

    var sections: [TableSection] {
        get {
            var sections: [TableSection] = []
            if self.creatingNewRecord {
                sections.append(.recordType)
            }

            if let record = self.record {
                if record.dictionary.count > 0 || self.canAddRecordAttribute() {
                    sections.append(.data)
                }

                sections.append(.metadata)
            }
            return sections
        }
    }

    var recordTypeSectionIndex: Int? {
        get {
            return self.sections.index(of: .recordType)
        }
    }

    var dataSectionIndex: Int? {
        get {
            return self.sections.index(of: .data)
        }
    }

    var metadataSectionIndex: Int? {
        get {
            return self.sections.index(of: .metadata)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter = DateFormatter()
        dateFormatter!.dateStyle = .full
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        if canDeleteCurrentRecord() {
            super.navigationController?.setToolbarHidden(false, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if canDeleteCurrentRecord() {
            super.navigationController?.setToolbarHidden(true, animated: animated)
        }
    }

    // MARK: - Actions

    func canDeleteCurrentRecord() -> Bool {
        return !creatingNewRecord && !readonly
    }

    func deleteCurrentRecord() {
        guard let record = self.record else {
            return
        }

        SKYContainer.default().publicCloudDatabase.deleteRecord(type: record.recordType, recordID: record.recordID) { (recordID, error) in
            guard error == nil else {
                let alert = UIAlertController(title: "Unable to delete", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            if let delegate = self.delegate {
                delegate.recordViewController(self, didDeleteRecordID: recordID!)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    func canSaveCurrentRecord() -> Bool {
        return self.modified && !readonly
    }

    func saveCurrentRecord() {
        guard let record = self.record else {
            return
        }

        SKYContainer.default().publicCloudDatabase.saveRecord(record) { (record, error) in
            if error != nil {
                let alert = UIAlertController(title: "Unable to Save", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            self.modified = false
            self.creatingNewRecord = false
            if let delegate = self.delegate {
                delegate.recordViewController(self, didSaveRecord: record!)
            }
            self.record = record
            self.tableView.reloadData()
        }
    }

    @IBAction func triggerSaveRecord(_ sender: AnyObject) {
        self.saveCurrentRecord()
    }

    @IBAction func triggerDeleteRecord(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Delete Record", message: String(format: "Record %@ will be deleted", (record?.recordID)!), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            self.deleteCurrentRecord()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.preferredAction = alert.actions.last
        self.present(alert, animated: true, completion: nil)
    }

    func updateModifiedState() {
        if canSaveCurrentRecord() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(RecordViewController.triggerSaveRecord(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    func canEditRecordAttribute(_ attribute: String) -> Bool {
        guard !readonly else {
            return false
        }

        guard let record = self.record else {
            return false
        }

        if let _ = record.object(forKey: attribute) as? String {
            return true
        } else if let _ = record.object(forKey: attribute) as? SKYAsset {
            return true
        }
        return false
    }

    func editRecordAttribute(_ attribute: String) {
        guard let record = self.record else {
            return
        }

        selectedAttributeName = attribute

        if let _ = record.object(forKey: attribute) as? String {
            editStringRecordAttribute()
        } else if let _ = record.object(forKey: attribute) as? SKYAsset {
            editAssetRecordAttribute()
        }
    }

    func replaceCurrentRecordWithType(_ recordType: String) {
        let data = self.record?.dictionary
        let record = SKYRecord(type: recordType, recordID: nil, data: data)
        self.record = record

        self.tableView.reloadData()
    }

    func canAddRecordAttribute() -> Bool {
        return !self.readonly
    }

    func addRecordAttribute() {
        let alert = UIAlertController(title: "New Attribute", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Attribute Name"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
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
        self.present(alert, animated: true, completion: nil)
    }

    func chooseRecordAttributeType() {
        let alert = UIAlertController(title: "Attribute Type", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "String", style: .default, handler: { (_) in
            self.editStringRecordAttribute()
        }))
        alert.addAction(UIAlertAction(title: "Asset", style: .default, handler: { (_) in
            self.editAssetRecordAttribute()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.preferredAction = alert.actions.last
        self.present(alert, animated: true, completion: nil)
    }

    func editStringRecordAttribute() {
        let alert = UIAlertController(title: "String Value", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Value"

            if let record = self.record, let attributeName = self.selectedAttributeName {
                textField.text = record.object(forKey: attributeName) as? String
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            guard let record = self.record else {
                return
            }
            guard let fieldName = self.selectedAttributeName, let fieldValue = alert.textFields?.last?.text else {
                return
            }
            guard !fieldName.isEmpty else {
                return
            }

            record.setObject(fieldValue, forKey: fieldName as NSCopying)
            self.insertOrReloadAttribute(fieldName)
            self.modified = true
        }))
        alert.preferredAction = alert.actions.last
        self.present(alert, animated: true, completion: nil)
    }

    func editAssetRecordAttribute() {
        let alert = UIAlertController(title: "Asset",
                                      message: "Choose image from:",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            self.editAssetRecordAttribute(.camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
            self.editAssetRecordAttribute(.photoLibrary)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func editAssetRecordAttribute(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.delegate = self
        self.navigationController?.present(imagePicker, animated: true, completion: nil)
    }

    func insertOrReloadAttribute(_ attribute: String) {
        if !self.attributes.contains(attribute) {
            self.attributes.append(attribute)
            self.tableView.insertRows(at: [IndexPath(row: self.attributes.count - 1, section: self.dataSectionIndex!)],
                                                  with: .automatic)
        } else {
            self.tableView.reloadRows(at: [IndexPath(row: self.attributes.count - 1, section: self.dataSectionIndex!)],
                                                  with: .automatic)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "record_type" {
            if let controller = segue.destination as? RecordTypeViewController {
                controller.delegate = self
                controller.selectedRecordType = self.recordType
            }
        }
    }

    // MARK: - RecordTypeViewControllerDelegate

    func recordTypeViewController(_ controller: RecordTypeViewController, didSelectRecordType recordType: String) {
        self.recordType = recordType
        self.replaceCurrentRecordWithType(recordType)
        self.modified = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == metadataSectionIndex {
            return "Metadata"
        } else {
            return ""
        }
    }

    func detailText(_ attributeValue: AnyObject?) -> String {
        guard attributeValue != nil else {
            return ""
        }

        if let value = attributeValue as? String {
            return value
        } else if let value = attributeValue as? Date {
            return dateFormatter!.string(from: value)
        } else {
            return attributeValue!.description
        }
    }

    func cellForMetadataRow(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "metadata", for: indexPath)

        var titleText: String, detailValue: AnyObject
        (titleText, detailValue) = self.metadata[indexPath.row]

        cell.textLabel?.text = titleText
        cell.detailTextLabel?.text = detailText(detailValue)
        return cell
    }

    func cellForDataRow(_ indexPath: IndexPath) -> UITableViewCell {
        guard let record = self.record else {
            return UITableViewCell()
        }

        guard indexPath.row < self.attributes.count else {
            return UITableViewCell()
        }

        let attribute = self.attributes[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "data", for: indexPath)
        cell.textLabel?.text = attribute
        cell.detailTextLabel?.text = detailText((record.dictionary[attribute])! as AnyObject)
        cell.accessoryType = self.canEditRecordAttribute(attribute) ? .disclosureIndicator : .none
        return cell
    }

    func cellForNewAttributeRow(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "new_attribute", for: indexPath)
        return cell
    }

    func cellForRecordTypeRow(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "record_type", for: indexPath)
        cell.detailTextLabel?.text = recordType
        return cell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == dataSectionIndex {
            if indexPath.row == self.attributes.count {
                self.addRecordAttribute()
            } else if indexPath.row < self.attributes.count {
                self.editRecordAttribute(attributes[indexPath.row])
            }
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        guard let data = UIImagePNGRepresentation(image) else {
            return
        }

        let asset = SKYAsset(data: data)
        asset.mimeType = "image/png"

        guard let fieldName = self.selectedAttributeName else {
            return
        }

        record?.setObject(asset, forKey: fieldName as NSCopying)
        self.insertOrReloadAttribute(fieldName)
        self.modified = true
    }
}
