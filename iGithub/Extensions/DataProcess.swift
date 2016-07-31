//
//  DataProcess.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit
import SwiftDate
import Kingfisher

extension NSDate {
    var naturalString: String {
        let date = NSDate()
        let suffix = self < date ? "ago" : "later"
        return "\(self.toNaturalString(date, style: FormatterStyle(style: .Full, max: 1))!) \(suffix)"
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIImageView {
    func setAvatarWithURL(avatarURL: NSURL?) {
        self.kf_setImageWithURL(avatarURL, placeholderImage: UIImage(named: "default-avatar"))
    }
}

extension UIView {
    func addSubviews(subviews: [UIView], usingAutoLayout: Bool = true) {
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = !usingAutoLayout
            self.addSubview(view)
        }
    }
}