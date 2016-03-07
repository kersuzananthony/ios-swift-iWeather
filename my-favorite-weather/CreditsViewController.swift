//
//  CreditsViewController.swift
//  iWeather
//
//  Created by Kersuzan on 10/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    
    @IBAction func previousPressed(sender: UIButton!) {
        self.webView.goBack()
    }
    
    @IBAction func nextPressed(sender: UIButton!) {
        self.webView.goForward()
    }
    
    @IBAction func creditPressed(sender: UIButton!) {
        loadCredits()
    }
    
    
    override func viewDidLayoutSubviews() {
        self.webView.scrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.delegate = self
        
        loadCredits()
    }
    
    func loadCredits() {
        let url = NSBundle.mainBundle().pathForResource("credits", ofType: "html")
        
        do {
            if let url = url {
                let HTMLContent = try NSString(contentsOfFile: url, encoding: NSUTF8StringEncoding)
                self.webView.loadHTMLString(HTMLContent as String, baseURL: nil)
            } else {
                makeAlert()
            }
        } catch _ {
            makeAlert()
        }

    }
    
    func makeAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Cannot load content", comment: "Cannot load content"), preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        })
        
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        self.webView.scrollView.setContentOffset(CGPointZero, animated: false)
        
        return true
    }

    
}
