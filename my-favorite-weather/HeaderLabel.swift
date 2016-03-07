//
//  HeaderLabel.swift
//  my-favorite-weather
//
//  Created by Kersuzan on 04/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import UIKit

class HeaderLabel: UILabel {
    
    override func awakeFromNib() {
        self.font = UIFont(name: "Helvetica", size: 17)
        self.textColor = UIColor.whiteColor()
        self.textAlignment = NSTextAlignment.Center
        self.sizeToFit()
        self.shadowColor = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.6)
        self.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.masksToBounds = true
        self.numberOfLines = 2
        self.minimumScaleFactor = 0.7
    }
    
}
