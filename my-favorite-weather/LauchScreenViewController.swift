//
//  LauchScreenViewController.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 03/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import UIKit
import Firebase

class LauchScreenViewController: UIViewController {
    
    // -MARK: Controller variables
    let firebaseRef = Firebase(url: FIREBASE_URL_AUTH)
    var clouds: [UIImageView] = [UIImageView]()
    let TIMEOUT: NSTimeInterval = 20.0
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let beginRequest = NSDate()
        
        for i in 1...16 {
            let id: Int = (i % 4) + 1
            let imageView = UIImageView()
            let sizeCoef = randomInRange(50...300)
            let yPosition = randomInRange(50...Int(self.view.bounds.height - 100))
            let duration = randomInRange(2...10)
            
            imageView.frame.size = CGSize(width: CGFloat(sizeCoef), height: CGFloat(sizeCoef))
            imageView.frame.origin = CGPoint(x: self.view.bounds.size.width + imageView.frame.size.width, y: CGFloat(yPosition))
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            imageView.image = UIImage(named: "bg-sunny-cloud-\(id)")
            self.view.addSubview(imageView)
            
            UIView.animateWithDuration(NSTimeInterval(duration), delay: NSTimeInterval(i / 5), options: [UIViewAnimationOptions.Repeat, UIViewAnimationOptions.CurveLinear], animations: { () -> Void in
                imageView.frame.origin.x = -imageView.frame.width
                }, completion: nil)
        }
        
        //_ = NSTimer.scheduledTimerWithTimeInterval(TIMEOUT, target: self, selector: "requestTimeout:", userInfo: nil, repeats: false)
        
        firebaseRef.authAnonymouslyWithCompletionBlock { error, authData in
            if error != nil {
                self.makeAlert(error.localizedDescription)
                print(error.description)
            } else {
                print(authData)
                let endRequest = NSDate()
                let requestDuration = endRequest.timeIntervalSinceDate(beginRequest)
                
                if requestDuration >= 4.0 {
                    self.goToHome(nil)
                } else {
                    _ = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(4.0 - requestDuration), target: self, selector: #selector(LauchScreenViewController.goToHome(_:)), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    func makeAlert(message: String) {
        //let message = NSString(string: message).
        
        let alertController = UIAlertController(title: NSLocalizedString("INTERNET CONNECTION", comment: "Internet connection"), message: message, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .Cancel) { (action) -> Void in
            print("force close app")
        }
        
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func goToHome(sender: AnyObject?) {
        self.performSegueWithIdentifier("goToHome", sender: self)
    }

}
