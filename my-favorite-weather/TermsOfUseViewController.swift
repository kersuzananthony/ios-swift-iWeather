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
        self.webView.scrollView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.path(forResource: "termsOfUse", ofType: "html")
        
        do {
            let HTMLContent = try NSString(contentsOfFile: url!, encoding: String.Encoding.utf8.rawValue)
            self.webView.loadHTMLString(HTMLContent as String, baseURL: nil)
            
        } catch _ {
            let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Cannot load content", comment: "Cannot load content"), preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)

        }
    }

}
