//
//  SceneDelegate.swift
//  Polimats
//
//  Created by Atakan Başaran on 20.12.2023.
//

import UIKit
import AppTrackingTransparency
import OneSignalFramework

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var savedShortCutItem: UIApplicationShortcutItem?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if let shortcutItem = connectionOptions.shortcutItem { // get the shortCutItem here
            savedShortCutItem = shortcutItem
           }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            
            ATTrackingManager.requestTrackingAuthorization { status in
                
                switch status {
                case .authorized:
                    OneSignal.setConsentGiven(true)
                    print("accept")
                case .denied:
                    print("denied")
                    OneSignal.setConsentGiven(false)
                case .notDetermined:
                    OneSignal.setConsentGiven(false)
                    print("not determined")
                case .restricted:
                    OneSignal.setConsentGiven(false)
                    print("restricted")
                @unknown default:
                    print("unkown")
                }
            }
        })
        
        if savedShortCutItem != nil {
            if savedShortCutItem!.type == "com.polimats.contactus" {
                openMail()
            } else {
                print("wrong type")
            }
    }
}
            

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    //MARK: - Quick Action
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        print("application")
        handleShortcut(shortcutItem)
        completionHandler(true) //quick action done successfully
    }
    
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) {
        print("Handling shortcut: \(shortcutItem.type)")
        if shortcutItem.type == "com.polimats.contactus" {
            openMail()
        } else {
            print("wrong type")
        }
    }
    
    func openMail() {
        print("Opening mail")
        if let url = URL(string: "mailto:iletisim@polimats.com?subject=Destek%20Talebi") {
            UIApplication.shared.open(url)
        }
    }
    
}

