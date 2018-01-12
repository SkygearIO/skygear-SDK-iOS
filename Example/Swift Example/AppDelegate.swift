//
//  AppDelegate.swift
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let endpoint = UserDefaults.standard.string(forKey: "SkygearEndpoint")
        if let endpointValue = endpoint {
            SKYContainer.default().configAddress(endpointValue)
        }

        let apiKey = UserDefaults.standard.string(forKey: "SkygearApiKey")
        if let apiKeyValue = apiKey {
            SKYContainer.default().configure(withAPIKey: apiKeyValue)
        }

        application.registerUserNotificationSettings(UIUserNotificationSettings(
            types: [.alert, .badge, .sound],
            categories: nil
        ))

        return true
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        guard !notificationSettings.types.isEmpty else {
            print("User does not allow notification")
            return
        }

        application.registerForRemoteNotifications()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered remote notification")

        let skygear = SKYContainer.default()
        guard skygear.auth.currentUser != nil else {
            print("User not yet login, abort registering device")
            return
        }

        skygear.push.registerDevice(withDeviceToken: deviceToken) { (deviceID, error) in
            guard error == nil else {
                print("Failed to register device: \(error?.localizedDescription)")
                return
            }

            if let id = deviceID {
                print("Successfully registered device with ID: \(id)")
            } else {
                print("Warning: Got nil device ID")
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register remote notification: \(error.localizedDescription)")
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return SKYContainer.default().auth.resumeOAuthFlow(url, options: options)
    }
}
