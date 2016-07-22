//
//  UserAuthenticationViewController.swift
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

class UserAuthenticationViewController: UITableViewController {
    
    let actionSectionIndex = 0
    let statusSectionIndex = 1
    
    var lastUsername : String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("LastUsername")
        }
        set(value) {
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "LastUsername")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.loginStatusDidChange()
        }
    }
    
    internal var isLoggedIn: Bool {
        get {
            return SKYContainer.defaultContainer().currentUserRecordID != nil
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(SKYContainerDidChangeCurrentUserNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note) in
            
            self.loginStatusDidChange()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions

    func showAuthenticationError(user: SKYUser?, error: NSError?, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Unable to Authenticate", message: error?.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            if let c = completion {
                c()
            }
        }))
        self.presentViewController(alert, animated: true, completion: completion)
    }
    
    func loginStatusDidChange() {
        self.tableView.reloadData()
    }
    
    func login(username: String?) {
        let alert = UIAlertController(title: "Login", message: "Please enter your username and password.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Username"
            textField.text = username
        }
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: .Default, handler: { (action) in
            let username = alert.textFields?.first?.text
            let password = alert.textFields?.last?.text
            
            if (username ?? "").isEmpty || (password ?? "").isEmpty {
                return
            }
            
            SKYContainer.defaultContainer().loginWithUsername(username, password: password, completionHandler: { (user, error) in
                if error != nil {
                    self.showAuthenticationError(user, error: error, completion: {
                        self.login(username)
                    })
                    return
                }
                
                self.lastUsername = username
            })
        }))
        alert.preferredAction = alert.actions.last
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func signup(username: String?) {
        let alert = UIAlertController(title: "Signup", message: "Please enter your username and password.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Username"
        }
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Signup", style: .Default, handler: { (action) in
            let username = alert.textFields?.first?.text
            let password = alert.textFields?.last?.text
            
            if (username ?? "").isEmpty || (password ?? "").isEmpty {
                return
            }
            
            SKYContainer.defaultContainer().signupWithUsername(username, password: password, completionHandler: { (user, error) in
                if error != nil {
                    self.showAuthenticationError(user, error: error, completion: {
                        self.signup(username)
                    })
                    return
                }
                
                self.lastUsername = username
            })
        }))
        alert.preferredAction = alert.actions.last
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func logout() {
        if !self.isLoggedIn {
            return
        }
        
        SKYContainer.defaultContainer().logoutWithCompletionHandler { (user, error) in
            if error != nil {
                self.showAuthenticationError(user, error: error, completion: nil)
                return
            }
            
            let alert = UIAlertController(title: "Logged out", message: "You have successfully logged out.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isLoggedIn {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case self.actionSectionIndex:
            return self.isLoggedIn ? 3 : 2
        case self.statusSectionIndex:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case self.actionSectionIndex:
            return "Actions"
        case self.statusSectionIndex:
            return "Login Status"
        default:
            return ""
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case self.actionSectionIndex:
            let cell = tableView.dequeueReusableCellWithIdentifier("action", forIndexPath: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Login"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Signup"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Logout"
            }
            return cell
        case self.statusSectionIndex:
            let cell = tableView.dequeueReusableCellWithIdentifier("plain", forIndexPath: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Username"
                cell.detailTextLabel?.text = self.lastUsername
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "User Record ID"
                cell.detailTextLabel?.text = SKYContainer.defaultContainer().currentUserRecordID
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Access Token"
                cell.detailTextLabel?.text = SKYContainer.defaultContainer().currentAccessToken.tokenString
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case self.actionSectionIndex:
            if indexPath.row == 0 {
                self.login(self.lastUsername)
            } else if indexPath.row == 1 {
                self.signup(nil)
            } else if indexPath.row == 2 {
                self.logout()
            }
        default:
            break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
