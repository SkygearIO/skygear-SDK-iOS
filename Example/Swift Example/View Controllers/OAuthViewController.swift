//
//  OAuthViewController.swift
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

class OAuthViewController: UITableViewController {

    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var userAccessTokenLabel: UILabel!
    @IBOutlet weak var userLastLoginLabel: UILabel!

    let actionSectionIndex = 1
    let loginProviderIndex = 0
    let linkProviderIndex = 1
    let loginProviderWithAccessTokenIndex = 2
    let linkProviderWithAccessTokenIndex = 3
    let unlinkProviderIndex = 4
    let selectedProvider = "google"
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dateFormatter.locale = Locale.current
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        self.dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.providerLabel.text = selectedProvider

        self.updateUsersLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != actionSectionIndex {
            return
        }
        switch indexPath.row {
        case loginProviderIndex:
            loginWithProvider()
        case linkProviderIndex:
            linkWithProvider()
        case loginProviderWithAccessTokenIndex:
            showLoginWithAccessTokenInput()
        case linkProviderWithAccessTokenIndex:
            showLinkWithAccessTokenInput()
        case unlinkProviderIndex:
            unlinkProvider()
        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: - Actions

    func showError(error: Error?) {
        var errorMsg = (error! as NSError).userInfo[SKYErrorMessageKey] as? String
        if errorMsg == nil {
            errorMsg = error?.localizedDescription
        }
        let alert = UIAlertController(title: "Error",
                                      message: errorMsg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func loginWithProvider() {
        weak var weakSelf = self
        SKYContainer.default().auth.loginOAuthProvider(selectedProvider, options: [
            "scheme": "skygearexample"
        ]) {(user, error) in
            if error != nil {
                weakSelf?.showError(error: error)
                return
            }

            print("Login user %@", user.debugDescription)
            weakSelf?.updateUsersLabel()
        }
    }

    func linkWithProvider() {
        weak var weakSelf = self
        SKYContainer.default().auth.linkOAuthProvider(selectedProvider, options: [
            "scheme": "skygearexample"
        ]) {(error) in
            if error != nil {
                weakSelf?.showError(error: error)
                return
            }
            let alert = UIAlertController(title: "Success",
                                          message: "Link provider successfully",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            weakSelf?.present(alert, animated: true, completion: nil)
        }
    }

    func showLoginWithAccessTokenInput() {
        weak var weakSelf = self
        let title = "Login with access token"
        let message = "Input \(selectedProvider) access token"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: .default) { (_) in
            weakSelf?.loginWithAccessToken((alert.textFields?.first)!)
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Access token"
        })
        self.present(alert, animated: true, completion: nil)
    }

    func loginWithAccessToken(_ sender: UITextField) {
        weak var weakSelf = self
        SKYContainer.default().auth.loginOAuthProvider(selectedProvider, accessToken: sender.text!) { (user, error) in
            if error != nil {
                weakSelf?.showError(error: error)
                return
            }
            print("Login user %@", user.debugDescription)
            weakSelf?.updateUsersLabel()
        }
    }

    func showLinkWithAccessTokenInput() {
        weak var weakSelf = self
        let title = "Link with access token"
        let message = "Input \(selectedProvider) access token"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Link", style: .default) { (_) in
            weakSelf?.linkWithAccessToken((alert.textFields?.first)!)
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Access token"
        })
        self.present(alert, animated: true, completion: nil)
    }

    func linkWithAccessToken(_ sender: UITextField) {
        weak var weakSelf = self
        SKYContainer.default().auth.linkOAuthProvider(selectedProvider, accessToken: sender.text!) { (error) in
            if error != nil {
                weakSelf?.showError(error: error)
                return
            }
            let alert = UIAlertController(title: "Success",
                                          message: "Link provider successfully",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            weakSelf?.present(alert, animated: true, completion: nil)
        }
    }

    func unlinkProvider() {
        weak var weakSelf = self
        SKYContainer.default().auth.unlinkOAuthProvider(selectedProvider) { (error) in
            if error != nil {
                weakSelf?.showError(error: error)
                return
            }
            let alert = UIAlertController(title: "Success",
                                          message: "Unlink provider successfully",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            weakSelf?.present(alert, animated: true, completion: nil)
        }
    }

    func updateUsersLabel() {
        if let user = SKYContainer.default().auth.currentUser {
            // swiftlint:disable:next force_cast
            self.userEmailLabel?.text = user["email"] as! String!
            self.userIDLabel?.text = SKYContainer.default().auth.currentUserRecordID
            self.userAccessTokenLabel?.text = SKYContainer.default().auth.currentAccessToken?.tokenString
            // swiftlint:disable:next force_cast
            if let lastLoginAt = user["last_login_at"] as! Date! {
                let f = self.dateFormatter.string(from: lastLoginAt)
                self.userLastLoginLabel?.text = f
            }
        } else {
            self.userEmailLabel?.text = nil
            self.userIDLabel?.text = nil
            self.userAccessTokenLabel?.text = nil
            self.userLastLoginLabel?.text = nil
        }

        self.tableView.reloadData()
    }

}
