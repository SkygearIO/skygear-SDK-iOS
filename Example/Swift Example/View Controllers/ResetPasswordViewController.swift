//
//  ResetPasswordViewController.swift
//  Swift Example
//
//  Created by Ho Wa on 9/3/2018.
//  Copyright © 2018 Oursky Ltd. All rights reserved.
//

import Foundation
import UIKit
import SKYKit

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var expiredAtTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    @IBAction func forgotPassword() {
        SKYContainer.default().auth.forgotPassword(withEmail: emailTextField.text ?? "") {
            (_, error) in
                self.showDialog(title: "Forgot Password", error: error)
        }
    }

    @IBAction func resetPassword() {
        SKYContainer.default().auth.resetPassword(withUserID: userIdTextField.text ?? "",
                                                  code: codeTextField.text ?? "",
                                                  expireAt: Int(expiredAtTextField.text ?? "0") ?? 0,
                                                  password: newPasswordTextField.text ?? "") {
            (_, error) in
                self.showDialog(title: "Reset Password", error: error)

        }
    }

    func showDialog(title: String, error: Error?) {
        let alert = UIAlertController(title: title, message: error != nil ? "Failed" : "Succeeded", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
