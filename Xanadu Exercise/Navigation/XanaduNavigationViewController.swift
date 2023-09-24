//
//  XanaduNavigationViewController.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import UIKit

class XanaduNavigationViewController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            if toVC is NavigationDrawerViewController {
                return LeftToRightAnimationTransitioning()
            }
        case .pop:
            if fromVC is NavigationDrawerViewController {
                return RightToLeftAnimationTransitioning()
            }
        default:
            break
        }
        return nil
    }
}
