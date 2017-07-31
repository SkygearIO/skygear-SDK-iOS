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

    let dateFormatter = DateFormatter()

    var lastUsername: String? {
        get {
            return UserDefaults.standard.string(forKey: "LastUsername")
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "LastUsername")
            UserDefaults.standard.synchronize()
        }
    }

    internal var isLoggedIn: Bool {
        get {
            return SKYContainer.default().auth.currentUserRecordID != nil
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.SKYContainerDidChangeCurrentUser, object: nil, queue: OperationQueue.main) { (_) in

            self.loginStatusDidChange()
        }

        self.dateFormatter.locale = Locale.current
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        self.dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if SKYContainer.default().auth.currentUserRecordID != nil {
            self.whoami()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions

    func showAuthenticationError(_ user: SKYRecord?, error: NSError?, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Unable to Authenticate", message: error?.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let c = completion {
                c()
            }
        }))
        self.present(alert, animated: true, completion: completion)
    }

    func whoami() {
        SKYContainer.default().auth.getWhoAmI { (user, error) in
            if error != nil {
                self.showAuthenticationError(user, error: error as! NSError, completion: {
                    self.login(nil)
                })
                return
            }
        }
    }

    func loginStatusDidChange() {
        if let user = SKYContainer.default().auth.currentUser {
            self.lastUsername = user["username"] as! String!
        }

        self.tableView.reloadData()
    }

    func login(_ username: String?) {
        let alert = UIAlertController(title: "Login", message: "Please enter your username and password.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Username"
            textField.text = username
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in
            let username = alert.textFields?.first?.text ?? ""
            let email = alert.textFields?[1].text ?? ""
            let password = alert.textFields?.last?.text ?? ""

            if (username.isEmpty && email.isEmpty) || password.isEmpty {
                return
            }

            var authData: [String: Any] = [:]
            if !username.isEmpty {
                authData["username"] = username
            }

            if !email.isEmpty {
                authData["email"] = email
            }

            SKYContainer.default().auth.login(withAuthData: authData, password: password, completionHandler: { (user, error) in
                guard error == nil else {
                    self.showAuthenticationError(user, error: error as! NSError, completion: {
                        self.login(username)
                    })
                    return
                }
            })
        }))
        alert.preferredAction = alert.actions.last
        self.present(alert, animated: true, completion: nil)
    }

    func signup() {
        let alert = UIAlertController(title: "Signup", message: "Please enter your username and password.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Email"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Signup", style: .default, handler: { (_) in
            let username = alert.textFields?.first?.text ?? ""
            let email = alert.textFields?[1].text ?? ""
            let password = alert.textFields?.last?.text ?? ""

            if (username.isEmpty && email.isEmpty) || password.isEmpty {
                return
            }

            var authData: [String: Any] = [:]
            if !username.isEmpty {
                authData["username"] = username
            }

            if !email.isEmpty {
                authData["email"] = email
            }

            SKYContainer.default().auth.signup(withAuthData: authData, password: password, completionHandler: { (user, error) in
                if error != nil {
                    self.showAuthenticationError(user, error: error as! NSError, completion: {
                        self.signup()
                    })
                    return
                }
            })
        }))
        alert.preferredAction = alert.actions.last
        self.present(alert, animated: true, completion: nil)
    }

    func logout() {
        if !self.isLoggedIn {
            return
        }

        SKYContainer.default().auth.logout { (user, error) in
            if error != nil {
                self.showAuthenticationError(user, error: error as! NSError, completion: nil)
                return
            }

            let alert = UIAlertController(title: "Logged out", message: "You have successfully logged out.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.isLoggedIn {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case self.actionSectionIndex:
            return self.isLoggedIn ? 3 : 2
        case self.statusSectionIndex:
            return 4
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case self.actionSectionIndex:
            return "Actions"
        case self.statusSectionIndex:
            return "Login Status"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case self.actionSectionIndex:
            let cell = tableView.dequeueReusableCell(withIdentifier: "action", for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Login"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Signup"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Logout"
            }
            return cell
        case self.statusSectionIndex:
            let cell = tableView.dequeueReusableCell(withIdentifier: "plain", for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Username"
                if let user = SKYContainer.default().auth.currentUser {
                    cell.detailTextLabel?.text = user["username"] as! String!
                } else {
                    cell.detailTextLabel?.text = "(Unavailable)"
                }
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "User Record ID"
                cell.detailTextLabel?.text = SKYContainer.default().auth.currentUserRecordID
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Access Token"
                cell.detailTextLabel?.text = SKYContainer.default().auth.currentAccessToken.tokenString
            } else if indexPath.row == 3 {
                cell.textLabel?.text = "Last Login At"
                if let user = SKYContainer.default().auth.currentUser {
                    if let lastLoginAt = user["last_login_at"] as! Date! {
                        let f = self.dateFormatter.string(from: lastLoginAt)
                        cell.detailTextLabel?.text = f
                    } else {
                        cell.detailTextLabel?.text = "Querying..."
                    }
                } else {
                    cell.detailTextLabel?.text = "(Unavailable)"
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case self.actionSectionIndex:
            if indexPath.row == 0 {
                self.login(self.lastUsername)
            } else if indexPath.row == 1 {
                self.signup()
            } else if indexPath.row == 2 {
                self.logout()
            }
        default:
            break
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
