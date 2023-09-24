//
//  LeftToRightAnimationTransitioning.swift
//  Xanadu Exercise
//
//  Created by Davide Dallan on 24/09/23.
//

import UIKit

class LeftToRightAnimationTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }

        let fromVCFrame = fromVC.view.frame

        let width = toVC.view.frame.size.width
        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.frame = fromVCFrame.offsetBy(dx: -width, dy: 0)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = fromVCFrame.offsetBy(dx: width, dy: 0)
            toVC.view.frame = fromVCFrame
        }) { (finished) in
            fromVC.view.frame = fromVCFrame
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}


class RightToLeftAnimationTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }

        let fromVCFrame = fromVC.view.frame

        let width = toVC.view.frame.size.width
        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.frame = fromVCFrame.offsetBy(dx: width, dy: 0)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = fromVCFrame.offsetBy(dx: -width, dy: 0)
            toVC.view.frame = fromVCFrame
        }) { (finished) in
            fromVC.view.frame = fromVCFrame
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
