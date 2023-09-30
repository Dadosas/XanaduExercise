//
//  WelcomeViewController.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 23/09/23.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Matchbook"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(didTapOnMenuBarButtonItem))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
        welcomeLabel.text = "Welcome"
        welcomeLabel.textAlignment = .center
    }
    
    @IBAction func didTapOnMenuBarButtonItem() {
        let viewModel = DefaultNavigationDrawerViewModel(appDependencies: AppDelegate.getAppDependencies())
        let navigationDrawerViewController = NavigationDrawerViewController.instance(viewModel: viewModel)
        navigationController?.pushViewController(navigationDrawerViewController, animated: true)
    }
}
