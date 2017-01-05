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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let endpoint = NSUserDefaults.standardUserDefaults().stringForKey("SkygearEndpoint")
        if let endpointValue = endpoint {
            SKYContainer.defaultContainer().configAddress(endpointValue)
        }

        let apiKey = NSUserDefaults.standardUserDefaults().stringForKey("SkygearApiKey")
        if let apiKeyValue = apiKey {
            SKYContainer.defaultContainer().configureWithAPIKey(apiKeyValue)
        }

        application.registerUserNotificationSettings(UIUserNotificationSettings(
            forTypes: [.Alert, .Badge, .Sound],
            categories: nil
        ))

        return true
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        guard !notificationSettings.types.isEmpty else {
            print("User does not allow notification")
            return
        }

        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Successfully registered remote notification")

        let skygear = SKYContainer.defaultContainer()
        guard skygear.currentUser != nil else {
            print("User not yet login, abort registering device")
            return
        }

        skygear.registerRemoteNotificationDeviceToken(deviceToken) { (deviceID, error) in
            guard error == nil else {
                print("Failed to register device: \(error.localizedDescription)")
                return
            }

            if let id = deviceID {
                print("Successfully registered device with ID: \(id)")
            } else {
                print("Warning: Got nil device ID")
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register remote notification: \(error.localizedDescription)")
    }
}
