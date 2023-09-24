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
        
        let navigationServiceImpl: NavigationService = NavigationServiceImpl()
        let navigationRepository: NavigationRepository = NavigationRepositoryImpl(navigationService: navigationServiceImpl)
        
        let matchService: MatchService = MatchServiceImpl()
        
        appDependencies = AppDependenciesImpl(navigationRepository: navigationRepository,
                                              matchService: matchService)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

protocol AppDependencies {
    var navigationRepository: NavigationRepository { get }
    var matchService: MatchService { get }
}

struct AppDependenciesImpl: AppDependencies {
    let navigationRepository: NavigationRepository
    let matchService: MatchService
}
