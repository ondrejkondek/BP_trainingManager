//
//  SceneDelegate.swift
//  TrainingManager
//
//  Created by Ondrej Kondek on 12/02/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
   
    /// handle siri/widget
    var play = false
    var pause = false
    var reset = false
    var widgetPlay = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    /// Handling Siri voiceshortcuts
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        switch userActivity.activityType {
        
        case "ondrejkondek.TrainingManager.StartTraining":
            
            if let tabBar = self.window!.rootViewController as? UITabBarController {
                
                self.play = true
                tabBar.selectedIndex = 2
                
            }
                
        case "ondrejkondek.TrainingManager.StopTraining":
            
            if let tabBar = self.window!.rootViewController as? UITabBarController {
                self.pause = true
                tabBar.selectedIndex = 2
                
            }
            
        case "ondrejkondek.TrainingManager.ShowStats":
            
            if let tabBar = self.window!.rootViewController as? UITabBarController {
                tabBar.selectedIndex = 0
            }

        default:
            print(userActivity.activityType , "No user acttivity")
        }
        
        return
    }

    /// Handling context menu shortcuts
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        switch shortcutItem.type {
        
        case "startTrainingShortcutItem":
            
            if let tabBar = self.window!.rootViewController as? UITabBarController {
                
                self.play = true
                tabBar.selectedIndex = 2
            }
        
        
        case "stopTrainingShortcutItem":
            
            if let tabBar = self.window!.rootViewController as? UITabBarController {
                self.pause = true
                tabBar.selectedIndex = 2
            }
            
        default:
            break
        }
            
        return
    }
   
    /// Handling Widget actions "buttons"
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
            if let url = URLContexts.first?.url {
                
                let key = url.absoluteString
                
                if key.contains("start"){
                    if let tabBar = self.window!.rootViewController as? UITabBarController {
                        self.widgetPlay = true
                        tabBar.selectedIndex = 2
                    }
                }
                else if key.contains("reset") {
                    if let tabBar = self.window!.rootViewController as? UITabBarController {
                        self.reset = true
                        tabBar.selectedIndex = 2
                    }
                }
                else if key.contains("choose") {
                    if let tabBar = self.window!.rootViewController as? UITabBarController {
                        tabBar.selectedIndex = 2

                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "sportSelect")
                        tabBar.selectedViewController?.present(vc, animated: true, completion: nil)
                    }
                }
  
            }
    }

}

