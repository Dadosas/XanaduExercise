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
        
        let navigationServiceImpl: NavigationService = DefaultNavigationService()
        let navigationRepository: NavigationRepository = DefaultNavigationRepository(navigationService: navigationServiceImpl)
        
        let matchService: MatchService = DefaultMatchService()
        let socket: Socket = MockSocket()
        let matchRepository: MatchRepository = DefaultMatchRepository(matchService: matchService, socket: socket)
        
        appDependencies = DefaultAppDependencies(navigationRepository: navigationRepository,
                                                 matchRepository: matchRepository)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

protocol AppDependencies {
    var navigationRepository: NavigationRepository { get }
    var matchRepository: MatchRepository { get }
}

struct DefaultAppDependencies: AppDependencies {
    let navigationRepository: NavigationRepository
    let matchRepository: MatchRepository
}
