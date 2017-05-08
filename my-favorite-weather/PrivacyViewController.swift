//
//  PrivacyViewController.swift
//  iWeather
//
//  Created by Kersuzan on 10/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLayoutSubviews() {
        self.textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
