//
//  TermsOfUseViewController.swift
//  iWeather
//
//  Created by Kersuzan on 10/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import UIKit

class TermsOfUseViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewWillLayoutSubviews() {
        self.webView.scrollView.setContentOffset(CGPointZero, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSBundle.mainBundle().pathForResource("termsOfUse", ofType: "html")
        
        do {
            let HTMLContent = try NSString(contentsOfFile: url!, encoding: NSUTF8StringEncoding)
            self.webView.loadHTMLString(HTMLContent as String, baseURL: nil)
            
        } catch _ {
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Cannot load content", comment: "Cannot load content"), preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)

        }
    }

}
