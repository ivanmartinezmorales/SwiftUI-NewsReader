//
//  CachePlugin.swift
//  NewsReader
//
//  Created by Basem Emara on 2019-11-21.
//

import UIKit
import BackgroundTasks
import NewsCore

final class CachePlugin: ApplicationPlugin {
    private let dataWorker: DataWorkerType
    private let log: LogWorkerType
    private let backgroundRefreshID = "io.zamzam.NewsReader.backgroundRefresh"
    
    init(dataWorker: DataWorkerType, log: LogWorkerType) {
        self.dataWorker = dataWorker
        self.log = log
    }
}

extension CachePlugin {
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        dataWorker.configure()
        dataWorker.pull() // Prefetch
        return true
    }
}

extension CachePlugin {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Enable background fetch for refreshing local cache
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundRefreshID, using: nil) { [weak self] in
            guard let task = $0 as? BGAppRefreshTask else { return }
            self?.log.info("Background fetching starting from `BGTaskScheduler`...")
            
            // Refresh local cache data from remote
            self?.dataWorker.pull { [weak self] result in
                switch result {
                case .success:
                    self?.log.info("Background fetching completed")
                    task.setTaskCompleted(success: true)
                case .failure(let error):
                    guard case .nonExistent = error else {
                        self?.log.error("Background fetching failed: \(error)")
                        task.setTaskCompleted(success: false)
                        break
                    }
                    
                    self?.log.info("Background fetching completed with no data")
                    task.setTaskCompleted(success: true)
                }
            }
        }
    }
}

extension CachePlugin: ScenePlugin {
    
    func sceneDidEnterBackground() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        
        let request = BGAppRefreshTaskRequest(identifier: backgroundRefreshID).with {
            $0.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60)
        }
        
        do {
            try BGTaskScheduler.shared.submit(request)
            log.info("Scheduled background refresh for '\(backgroundRefreshID)'")
        } catch {
            log.error("Could not schedule background refresh for '\(backgroundRefreshID)': \(error)")
        }
    }
}
