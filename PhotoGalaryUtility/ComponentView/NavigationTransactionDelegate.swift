//
//  NavigationTransactionDelegate.swift
//  PhotoGalaryUtility
//
//  Created by Mykhailo Dovhyi on 13.01.2026.
//

import UIKit

class NavigationTransactionDelegate: NSObject, UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        self
    }
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        0.23
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let array = [transitionContext.viewController(forKey: .from), transitionContext.viewController(forKey: .to)]
        let fromVC = array.first {
            ($0 as? BaseViewController)?.navigationTransactionAnimatedView != nil
        }
        let toVC = array.first {
            ($0 as? BaseViewController)?.navigationTransactionTargetView != nil
        }
        if let fromVC = fromVC as? BaseViewController, let toVC = toVC as? BaseViewController {
            self.galaryZoomAnimation(
                fromViewController: fromVC,
                toViewController: toVC,
                isForward: toVC == transitionContext.viewController(forKey: .to),
                transating: transitionContext)
            
        }
    }
}

fileprivate extension NavigationTransactionDelegate {
    func galaryZoomAnimation(
        fromViewController: BaseViewController,
        toViewController: BaseViewController, isForward: Bool, transating: UIViewControllerContextTransitioning) {
            let containerView = transating.containerView
            let toVC = transating.viewController(forKey: .to)! as! BaseViewController
            let fromVC = transating.viewController(forKey: .from)! as! BaseViewController

            let cell = fromVC.getTransactionAnimationView!
            let cellSnapshoot = cell.snapshotView(afterScreenUpdates: false)!
            let startFrame = cell.convert(cell.bounds, to: containerView)
            print(startFrame, " yegtrfsed ")
            cellSnapshoot.frame = startFrame
            cell.isHidden = true
            containerView.addSubview(toVC.view)
            containerView.addSubview(cellSnapshoot)
            var destinationFrame = toVC.getTransactionAnimationView!.convert(toVC.getTransactionAnimationView!.bounds, to: containerView)
            if isForward {
                destinationFrame.origin.y += fromVC.view.safeAreaInsets.top
                destinationFrame.size.height -= fromVC.view.safeAreaInsets.top
            }
            
            if isForward {
                toVC.getTransactionAnimationView?.alpha = 0
            }
            let animation = UIViewPropertyAnimator(duration: transitionDuration(using: transating), curve: .linear) {
                cellSnapshoot.frame = destinationFrame

            }
            animation.addCompletion { _ in
                UIView.animate(withDuration: 0.3) {
                    toVC.getTransactionAnimationView?.alpha = 1
                    cellSnapshoot.alpha = 0
                    cell.isHidden = false
                } completion: { _ in
                    cellSnapshoot.removeFromSuperview()
                    transating.completeTransition(true)

                }

            }
            animation.startAnimation()
        }
}
