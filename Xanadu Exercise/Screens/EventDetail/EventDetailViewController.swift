//
//  EventDetailViewController.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import UIKit

class EventDetailViewController: UIViewController {

    static func instance(navigationItem: NavigationItem) -> EventDetailViewController {
        let vc = UIStoryboard(name: "EventDetailViewController", bundle: nil)
            .instantiateInitialViewController() as! EventDetailViewController
        vc.viewModel = EventDetailViewModelImpl(navigationItem: navigationItem, appDependencies: AppDelegate.getAppDependencies())
        return vc
    }
    
    private var viewModel: EventDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.navigationItem.name
        navigationItem.hidesBackButton = false
    }
}
