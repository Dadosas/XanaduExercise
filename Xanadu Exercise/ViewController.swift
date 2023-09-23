//
//  ViewController.swift
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
        navigationItem.leftBarButtonItem
        welcomeLabel.text = "WELCOME"
    }
}
