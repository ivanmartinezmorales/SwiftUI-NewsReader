//
//  SceneDelegate.swift
//  GoogleNews iOS
//
//  Created by Basem Emara on 2019-11-13.
//

import UIKit
import NewsCore
import SwiftUI

class SceneDelegate: ScenePluggableDelegate {
    private lazy var log: LogProviderType = core.dependency()
        
    override func plugins() -> [ScenePlugin] {[
        LoggerPlugin(log: log)
    ]}
}

// MARK: - Events

extension SceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        guard let scene = scene as? UIWindowScene else { return }
        
        // Build and assign main window
        window = UIWindow(windowScene: scene)
        defer { window?.makeKeyAndVisible() }
        
        // Handle deep link if applicable
        if let userActivity = connectionOptions.userActivities.first(where: { $0.activityType == NSUserActivityTypeBrowsingWeb }),
            let webpageURL = userActivity.webpageURL
        {
            log.info("Link passed to app: \(webpageURL.absoluteString)")
            set(rootViewTo: render.fetch(for: webpageURL))
            return
        }
        
        // Assign default view
        set(rootViewTo: render.launchMain())
    }
}

extension SceneDelegate {
    
    override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        super.scene(scene, continue: userActivity)
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let webpageURL = userActivity.webpageURL else {
                return
        }
        
        log.info("Link passed to app: \(webpageURL.absoluteString)")
        set(rootViewTo: render.fetch(for: webpageURL))
    }
}

// MARK: - Helpers

private extension SceneDelegate {
    
    /// Assign root view to window. Adds any environment objects if needed.
    func set<T: View>(rootViewTo view: T) {
        window?.rootViewController = UIHostingController(
            rootView: view
        )
    }
}
