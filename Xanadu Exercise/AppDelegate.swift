//
//  AppDelegate.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private static var instance: AppDelegate!
    
    static func getAppDependencies() -> AppDependencies {
        return instance.appDependencies
    }
    
    var appDependencies: AppDependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.instance = self
        let navigationServiceImpl: NavigationService = MockNavigationService()
        let navigationRepository: NavigationRepository = NavigationRepositoryImpl(navigationService: navigationServiceImpl)
        appDependencies = AppDependenciesImpl(navigationRepository: navigationRepository)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

protocol AppDependencies {
    var navigationRepository: NavigationRepository { get }
}

struct AppDependenciesImpl: AppDependencies {
    let navigationRepository: NavigationRepository
}
