//
//  PopAnimator.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 30/12/2015.
//  Copyright © 2015 Kersuzan. All rights reserved.
//

import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration    = 0.3
    var presenting  = true
    var originFrame = CGRect.zero
    
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        let detailView = presenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        let initialFrame = presenting ? originFrame : detailView.frame
        let finalFrame = presenting ? detailView.frame : originFrame
        
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        
        let scaleTransform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor)
        
        if presenting {
            detailView.transform = scaleTransform
            detailView.center = CGPoint(
                x: CGRectGetMidX(initialFrame),
                y: CGRectGetMidY(initialFrame))
            detailView.clipsToBounds = true
        }
        
        containerView!.addSubview(toView)
        containerView!.bringSubviewToFront(detailView)
        
        UIView.animateWithDuration(duration, delay: 0.0, options: [.CurveEaseOut], animations: { () -> Void in
            detailView.transform = self.presenting ? CGAffineTransformIdentity : scaleTransform
            detailView.center = CGPoint(x: CGRectGetMidX(finalFrame), y: CGRectGetMidY(finalFrame))
            }) { (_) -> Void in
                transitionContext.completeTransition(true)
        }
        
        let round = CABasicAnimation(keyPath: "cornerRadius")
        round.fromValue = presenting ? 20.0/xScaleFactor : 0.0
        round.toValue = presenting ? 0.0 : 20.0/xScaleFactor
        round.duration = duration / 2
        detailView.layer.addAnimation(round, forKey: nil)
        detailView.layer.cornerRadius = presenting ? 0.0 : 20.0/xScaleFactor
    }

    
    
}
