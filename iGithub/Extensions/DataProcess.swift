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
import TTTAttributedLabel

extension NSDate {
    var naturalString: String {
        let date = NSDate()
        
        if self < date - 1.months {
            return self.toString(dateStyle: .ShortStyle, timeStyle: .NoStyle)!
        }
        
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

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
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

extension TTTAttributedLabel {
    func addLink(url: NSURL, toText text: String) {
        let regexString = NSString(format: "^%1$@\\s|\\s%1$@\\s|\\s%1$@$", text) as String
        let range = (self.text! as NSString).rangeOfString(regexString, options: .RegularExpressionSearch)
        addLinkToURL(url, withRange: range)
    }
}

extension NSData {
    static func dataFromGHBase64String(base64String: String) -> NSData? {
        let encodedString = base64String.stringByReplacingOccurrencesOfString("\n", withString: "")
        return NSData(base64EncodedString: encodedString, options: NSDataBase64DecodingOptions(rawValue: 0))
    }
}

extension String {
    static func stringFromGHBase64String(base64String: String) -> String? {
        let data = NSData.dataFromGHBase64String(base64String)
        return String(data: data!, encoding: NSUTF8StringEncoding)
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
}
