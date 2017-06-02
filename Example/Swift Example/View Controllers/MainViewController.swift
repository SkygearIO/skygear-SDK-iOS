//
//  MainViewController.swift
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

class MainViewController: UITableViewController {

    var hasPromptedForConfiguration: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "HasPromptedForConfiguration")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "HasPromptedForConfiguration")
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if !self.hasPromptedForConfiguration {
            let alert = UIAlertController(title: "Configuration Required",
                                          message: "The app does not know how to connect to your Skygear Server. Configure the app now?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ignore", style: .cancel, handler: { (_) in
                self.hasPromptedForConfiguration = true
            }))
            alert.addAction(UIAlertAction(title: "Configure", style: .default, handler: { (_) in
                self.hasPromptedForConfiguration = true
                self.performSegue(withIdentifier: "server_configuration", sender: self)
            }))
            alert.preferredAction = alert.actions.last
            self.present(alert, animated: true, completion: nil)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "create_record" {
            let controller = segue.destination as! RecordViewController
            controller.creatingNewRecord = true
        }
    }

}
