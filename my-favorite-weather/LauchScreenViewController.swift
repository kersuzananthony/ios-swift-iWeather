//
//  LauchScreenViewController.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 03/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import UIKit
import FirebaseAuth

class LauchScreenViewController: UIViewController {
    
    // -MARK: Controller variables
    var clouds: [UIImageView] = [UIImageView]()
    let TIMEOUT: TimeInterval = 20.0
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let beginRequest = Date()
        
        for i in 1...16 {
            let id: Int = (i % 4) + 1
            let imageView = UIImageView()
            let sizeCoef = randomInRange(50..<300)
            let yPosition = randomInRange(50..<Int(self.view.bounds.height - 100))
            let duration = randomInRange(2..<10)
            
            imageView.frame.size = CGSize(width: CGFloat(sizeCoef), height: CGFloat(sizeCoef))
            imageView.frame.origin = CGPoint(x: self.view.bounds.size.width + imageView.frame.size.width, y: CGFloat(yPosition))
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.image = UIImage(named: "bg-sunny-cloud-\(id)")
            self.view.addSubview(imageView)
            
            UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(i / 5), options: [UIViewAnimationOptions.repeat, UIViewAnimationOptions.curveLinear], animations: { () -> Void in
                imageView.frame.origin.x = -imageView.frame.width
                }, completion: nil)
        }
        
        //_ = NSTimer.scheduledTimerWithTimeInterval(TIMEOUT, target: self, selector: "requestTimeout:", userInfo: nil, repeats: false)
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error != nil {
                self.makeAlert((error?.localizedDescription)!)
                print(error!.localizedDescription)
            } else {
                print(user?.debugDescription ?? "No VALUE")
                let endRequest = Date()
                let requestDuration = endRequest.timeIntervalSince(beginRequest)
                
                if requestDuration >= 4.0 {
                    self.goToHome(nil)
                } else {
                    _ = Timer.scheduledTimer(timeInterval: TimeInterval(4.0 - requestDuration), target: self, selector: #selector(LauchScreenViewController.goToHome(_:)), userInfo: nil, repeats: false)
                }
            }
        })
    }
    
    func makeAlert(_ message: String) {
        //let message = NSString(string: message).
        
        let alertController = UIAlertController(title: NSLocalizedString("INTERNET CONNECTION", comment: "Internet connection"), message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .cancel) { (action) -> Void in
            print("force close app")
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToHome(_ sender: AnyObject?) {
        self.performSegue(withIdentifier: "goToHome", sender: self)
    }

}
