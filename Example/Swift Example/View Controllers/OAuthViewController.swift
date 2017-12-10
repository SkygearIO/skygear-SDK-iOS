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
    let selectedProvider = "google"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        SKYContainer.default().auth.loginOAuthProvider(selectedProvider, options: [
            "scheme": "skygearexample"
        ]) { (user, error) in
            if error != nil {
                self.showError(error: error)
                return
            }
        }
    }

}
