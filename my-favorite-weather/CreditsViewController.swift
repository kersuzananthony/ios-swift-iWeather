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
    
    
    @IBAction func previousPressed(_ sender: UIButton!) {
        self.webView.goBack()
    }
    
    @IBAction func nextPressed(_ sender: UIButton!) {
        self.webView.goForward()
    }
    
    @IBAction func creditPressed(_ sender: UIButton!) {
        loadCredits()
    }
    
    
    override func viewDidLayoutSubviews() {
        self.webView.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.delegate = self
        
        loadCredits()
    }
    
    func loadCredits() {
        let url = Bundle.main.path(forResource: "credits", ofType: "html")
        
        do {
            if let url = url {
                let HTMLContent = try NSString(contentsOfFile: url, encoding: String.Encoding.utf8.rawValue)
                self.webView.loadHTMLString(HTMLContent as String, baseURL: nil)
            } else {
                makeAlert()
            }
        } catch _ {
            makeAlert()
        }

    }
    
    func makeAlert() {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Cannot load content", comment: "Cannot load content"), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)

    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        self.webView.scrollView.setContentOffset(CGPoint.zero, animated: false)
        
        return true
    }

    
}
