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

    var subscribedChannel: String? = nil
    var messageDictionaries: [NSDictionary] = []

    var pubsubClient: SKYPubsub {
        get {
            return SKYContainer.defaultContainer().pubsubClient
        }
    }

    var lastSubscribedChannel: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("LastSubscribedChannel")
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "LastSubscribedChannel")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillChangeFrameNotification, object: nil, queue: nil) { (note) in
            let keyboardFrame: CGRect = (note.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let animationDuration: NSTimeInterval = (note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let animationCurve: UIViewAnimationCurve = UIViewAnimationCurve(rawValue: (note.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue)!
            UIView.animateWithDuration(animationDuration, animations: {
                UIView.setAnimationCurve(animationCurve)
                self.bottomEdgeConstraint.constant = keyboardFrame.height
                self.view.layoutIfNeeded()
            })
        }

        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { (note) in
            let animationDuration: NSTimeInterval = (note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

            UIView.animateWithDuration(animationDuration, animations: {
                self.bottomEdgeConstraint.constant = 0
                self.view.layoutIfNeeded()
            })

        }

        updateMessageWidgetState()
    }

    override func viewDidDisappear(animated: Bool) {
        if let channel: String = subscribedChannel {
            self.unsubscribe(channel)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    @IBAction func triggerSubscribe(sender: AnyObject?) {
        let alert = UIAlertController(title: "Subscribe", message: "Enter the channel name to subscribe", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.text = self.lastSubscribedChannel
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Subscribe", style: .Default, handler: { (action) in
            let channel: String = alert.textFields!.first!.text as String!

            guard channel.characters.count > 0 else {
                return
            }

            self.subscribe(channel)
            self.subscribedChannel = channel
            self.lastSubscribedChannel = channel

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unsubscribe", style: .Plain, target: self, action: #selector(PubSubViewController.triggerUnsubscribe(_:)))
            self.updateMessageWidgetState()
            self.messageTextField.becomeFirstResponder()
        }))
        alert.preferredAction = alert.actions.last
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func triggerUnsubscribe(sender: AnyObject) {
        guard let channel = self.subscribedChannel else {
            return
        }

        self.unsubscribe(channel)
        self.subscribedChannel = nil

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Subscribe", style: .Plain, target: self, action: #selector(PubSubViewController.triggerSubscribe(_:)))
        self.updateMessageWidgetState()
    }

    @IBAction func triggerSendMessage(sender: AnyObject) {
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

    func updateMessageWidgetState() {
        self.sendMessageButton.enabled = self.messageTextField.text?.characters.count > 0 && self.subscribedChannel != nil
        self.messageTextField.enabled = self.subscribedChannel != nil
    }

    func isLastRowVisible() -> Bool {
        let indexPaths = self.tableView.indexPathsForVisibleRows
        guard indexPaths != nil else {
            return true
        }

        guard let lastVisibleIndexPath: NSIndexPath = indexPaths!.last else {
            return true
        }

        return lastVisibleIndexPath.row >= self.messageDictionaries.count-2
    }

    // MARK: - Publish/Subscribe

    func sendMessage(message: String, channel: String) {
        self.pubsubClient.publishMessage(["message": message], toChannel: channel)
        self.messageTextField.text = ""
    }

    func handle(info: NSDictionary) {
        messageDictionaries.append(info)
        let indexPath = NSIndexPath(forRow: messageDictionaries.count-1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

        if isLastRowVisible() {
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        }
    }

    func subscribe(channel: String) {
        self.pubsubClient.subscribeTo(channel) { (obj) in
            guard let info: NSDictionary = obj as NSDictionary else {
                return
            }
            self.handle(info)
        }
    }

    func unsubscribe(channel: String) {
        self.pubsubClient.unsubscribe(channel)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
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

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        updateMessageWidgetState()
        return true
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageDictionaries.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "message")
        cell.textLabel?.text = messageDictionaries[indexPath.row]["message"] as? String
        return cell
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
}
