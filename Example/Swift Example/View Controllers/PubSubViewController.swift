//
//  PubSubViewController.swift
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

class PubSubViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var bottomEdgeConstraint: NSLayoutConstraint!

    var subscribedChannel: String?
    var messageDictionaries: [[AnyHashable: Any]] = []

    var pubsub: SKYPubsubContainer {
        get {
            return SKYContainer.default().pubsub
        }
    }

    var lastSubscribedChannel: String? {
        get {
            return UserDefaults.standard.string(forKey: "LastSubscribedChannel")
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "LastSubscribedChannel")
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // swiftlint:disable:next discarded_notification_center_observer
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { (note) in
            // swiftlint:disable force_cast
            let keyboardFrame: CGRect = (note.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let animationDuration: TimeInterval = (note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let animationCurve: UIViewAnimationCurve = UIViewAnimationCurve(rawValue: (note.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue)!
            // swiftlint:enable force_cast
            UIView.animate(withDuration: animationDuration, animations: {
                UIView.setAnimationCurve(animationCurve)
                self.bottomEdgeConstraint.constant = keyboardFrame.height
                self.view.layoutIfNeeded()
            })
        }

        // swiftlint:disable:next discarded_notification_center_observer
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { (note) in
            // swiftlint:disable:next force_cast
            let animationDuration: TimeInterval = (note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

            UIView.animate(withDuration: animationDuration, animations: {
                self.bottomEdgeConstraint.constant = 0
                self.view.layoutIfNeeded()
            })

        }

        self.pubsub.onOpenCallback = { [weak self] in
            self?.pubsubDidOpened()
        }

        self.pubsub.onCloseCallback = { [weak self] in
            self?.pubsubDidClosed()
        }

        self.pubsub.onErrorCallback = { [weak self] (error) in
            self?.pubsubDidGetError(error: error)
        }

        updateMessageWidgetState()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.pubsub.onOpenCallback = nil
        self.pubsub.onCloseCallback = nil
        self.pubsub.onErrorCallback = nil
        if let channel: String = subscribedChannel {
            self.unsubscribe(channel)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    @IBAction func triggerSubscribe(_ sender: AnyObject?) {
        let alert = UIAlertController(title: "Subscribe", message: "Enter the channel name to subscribe", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.lastSubscribedChannel
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default, handler: { (action) in
            let channel: String = alert.textFields!.first!.text as String!

            guard channel.characters.count > 0 else {
                return
            }

            self.subscribe(channel)
            self.subscribedChannel = channel
            self.lastSubscribedChannel = channel

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unsubscribe", style: .plain, target: self, action: #selector(PubSubViewController.triggerUnsubscribe(_:)))
            self.updateMessageWidgetState()
        }))
        alert.preferredAction = alert.actions.last
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func triggerUnsubscribe(_ sender: AnyObject) {
        guard let channel = self.subscribedChannel else {
            return
        }

        self.unsubscribe(channel)
        self.subscribedChannel = nil

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Subscribe", style: .plain, target: self, action: #selector(PubSubViewController.triggerSubscribe(_:)))
        self.updateMessageWidgetState()
    }

    @IBAction func triggerSendMessage(_ sender: AnyObject) {
        guard let message: String = self.messageTextField.text else {
            return
        }

        guard message.characters.count >= 0 else {
            return
        }

        guard let channel = self.subscribedChannel else {
            return
        }

        self.sendMessage(message, channel: channel)
    }

    func pubsubDidOpened() {
        let alert = UIAlertController(title: nil, message: "Pubsub connection is open", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func pubsubDidClosed() {
        let alert = UIAlertController(title: nil, message: "Pubsub connection is closed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func pubsubDidGetError(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Got it", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func updateMessageWidgetState() {
        if let message = self.messageTextField.text {
            self.sendMessageButton.isEnabled = message.characters.count > 0 && self.subscribedChannel != nil
        } else {
            self.sendMessageButton.isEnabled = false
        }
        self.messageTextField.isEnabled = self.subscribedChannel != nil
    }

    func isLastRowVisible() -> Bool {
        let indexPaths = self.tableView.indexPathsForVisibleRows
        guard indexPaths != nil else {
            return true
        }

        guard let lastVisibleIndexPath: IndexPath = indexPaths!.last else {
            return true
        }

        return lastVisibleIndexPath.row >= self.messageDictionaries.count-2
    }

    // MARK: - Publish/Subscribe

    func sendMessage(_ message: String, channel: String) {
        self.pubsub.publishMessage(["message": message], toChannel: channel)
        self.messageTextField.text = ""
    }

    func handle(_ info: [AnyHashable: Any]) {
        messageDictionaries.append(info)
        let indexPath = IndexPath(row: messageDictionaries.count-1, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)

        if isLastRowVisible() {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func subscribe(_ channel: String) {
        self.pubsub.subscribe(to: channel) { (obj) in
            self.handle(obj)
        }
    }

    func unsubscribe(_ channel: String) {
        self.pubsub.unsubscribe(channel)

        // close on purpose to demonstate onClose callback
        self.pubsub.close()
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let message: String = self.messageTextField.text else {
            return false
        }

        guard message.characters.count >= 0 else {
            return false
        }

        guard let channel = self.subscribedChannel else {
            return false
        }

        self.sendMessage(message, channel: channel)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateMessageWidgetState()
        return true
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageDictionaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "message")
        cell.textLabel?.text = messageDictionaries[indexPath.row]["message"] as? String
        return cell
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
