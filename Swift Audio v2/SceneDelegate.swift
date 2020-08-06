//
//  SceneDelegate.swift
//  Swift Audio v2
//
//  Created by Blair Petrachek on 2020-07-10.
//  Copyright © 2020 Blair Petrachek. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        let parameters = sharedSpotifyService.authorize(from: url);

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            sharedSpotifyService.accessToken = access_token
        } else if let _ = parameters?[SPTAppRemoteErrorDescriptionKey] {
            // Show the error
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if !sharedSpotifyService.appRemote.isConnected && sharedSpotifyService.hasAuthorized {
            sharedSpotifyService.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    func sceneWillEnterForeground(_ scene: UIScene) {

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}
