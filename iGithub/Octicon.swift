//
//  Octicon.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

enum Octicon : String, CustomStringConvertible {
    case alert = "\u{f02d}"
    case arrowdown = "\u{f03f}"
    case arrowleft = "\u{f040}"
    case arrowright = "\u{f03e}"
    case arrowsmalldown = "\u{f0a0}"
    case arrowsmallleft = "\u{f0a1}"
    case arrowsmallright = "\u{f071}"
    case arrowsmallup = "\u{f09f}"
    case arrowup = "\u{f03d}"
    case beaker = "\u{f0dd}"
    case bell = "\u{f0de}"
    case bold = "\u{f0e2}"
    case book = "\u{f007}"
    case bookmark = "\u{f07b}"
    case briefcase = "\u{f0d3}"
    case broadcast = "\u{f048}"
    case browser = "\u{f0c5}"
    case bug = "\u{f091}"
    case calendar = "\u{f068}"
    case check = "\u{f03a}"
    case checklist = "\u{f076}"
    case chevrondown = "\u{f0a3}"
    case chevronleft = "\u{f0a4}"
    case chevronright = "\u{f078}"
    case chevronup = "\u{f0a2}"
    case circleslash = "\u{f084}"
    case circuitboard = "\u{f0d6}"
    case clippy = "\u{f035}"
    case clock = "\u{f046}"
    case clouddownload = "\u{f00b}"
    case cloudupload = "\u{f00c}"
    case code = "\u{f05f}"
    case commentdiscussion = "\u{f04f}"
    case comment = "\u{f02b}"
    case creditcard = "\u{f045}"
    case dash = "\u{f0ca}"
    case dashboard = "\u{f07d}"
    case database = "\u{f096}"
    case desktopdownload = "\u{f0dc}"
    case devicecameravideo = "\u{f057}"
    case devicecamera = "\u{f056}"
    case devicedesktop = "\u{f27c}"
    case devicemobile = "\u{f038}"
    case diffadded = "\u{f06b}"
    case diffignored = "\u{f099}"
    case diffmodified = "\u{f06d}"
    case diffremoved = "\u{f06c}"
    case diffrenamed = "\u{f06e}"
    case diff = "\u{f04d}"
    case ellipsis = "\u{f09a}"
    case eye = "\u{f04e}"
    case filebinary = "\u{f094}"
    case filecode = "\u{f010}"
    case filedirectory = "\u{f016}"
    case filemedia = "\u{f012}"
    case filepdf = "\u{f014}"
    case filesubmodule = "\u{f017}"
    case filesymlinkdirectory = "\u{f0b1}"
    case filesymlinkfile = "\u{f0b0}"
    case filetext = "\u{f011}"
    case filezip = "\u{f013}"
    case flame = "\u{f0d2}"
    case fold = "\u{f0cc}"
    case gear = "\u{f02f}"
    case gift = "\u{f042}"
    case gistsecret = "\u{f08c}"
    case gist = "\u{f00e}"
    case gitbranch = "\u{f020}"
    case gitcommit = "\u{f01f}"
    case gitcompare = "\u{f0ac}"
    case gitmerge = "\u{f023}"
    case gitpullrequest = "\u{f009}"
    case globe = "\u{f0b6}"
    case graph = "\u{f043}"
    case heart = "\u{2665}"
    case history = "\u{f07e}"
    case home = "\u{f08d}"
    case horizontalrule = "\u{f070}"
    case hubot = "\u{f09d}"
    case inbox = "\u{f0cf}"
    case info = "\u{f059}"
    case issueclosed = "\u{f028}"
    case issueopened = "\u{f026}"
    case issuereopened = "\u{f027}"
    case italic = "\u{f0e4}"
    case jersey = "\u{f019}"
    case key = "\u{f049}"
    case keyboard = "\u{f00d}"
    case law = "\u{f0d8}"
    case lightbulb = "\u{f000}"
    case linkexternal = "\u{f07f}"
    case link = "\u{f05c}"
    case listordered = "\u{f062}"
    case listunordered = "\u{f061}"
    case location = "\u{f060}"
    case lock = "\u{f06a}"
    case logogist = "\u{f0ad}"
    case logogithub = "\u{f092}"
    case mailread = "\u{f03c}"
    case mailreply = "\u{f051}"
    case mail = "\u{f03b}"
    case markgithub = "\u{f00a}"
    case markdown = "\u{f0c9}"
    case megaphone = "\u{f077}"
    case mention = "\u{f0be}"
    case milestone = "\u{f075}"
    case mirror = "\u{f024}"
    case mortarboard = "\u{f0d7}"
    case mute = "\u{f080}"
    case nonewline = "\u{f09c}"
    case octoface = "\u{f008}"
    case organization = "\u{f037}"
    case package = "\u{f0c4}"
    case paintcan = "\u{f0d1}"
    case pencil = "\u{f058}"
    case person = "\u{f018}"
    case pin = "\u{f041}"
    case plug = "\u{f0d4}"
    case plus = "\u{f05d}"
    case primitivedot = "\u{f052}"
    case primitivesquare = "\u{f053}"
    case pulse = "\u{f085}"
    case question = "\u{f02c}"
    case quote = "\u{f063}"
    case radiotower = "\u{f030}"
    case repoclone = "\u{f04c}"
    case repoforcepush = "\u{f04a}"
    case repoforked = "\u{f002}"
    case repopull = "\u{f006}"
    case repopush = "\u{f005}"
    case repo = "\u{f001}"
    case rocket = "\u{f033}"
    case rss = "\u{f034}"
    case ruby = "\u{f047}"
    case search = "\u{f02e}"
    case server = "\u{f097}"
    case settings = "\u{f07c}"
    case shield = "\u{f0e1}"
    case signin = "\u{f036}"
    case signout = "\u{f032}"
    case smiley = "\u{f0e7}"
    case squirrel = "\u{f0b2}"
    case star = "\u{f02a}"
    case stop = "\u{f08f}"
    case sync = "\u{f087}"
    case tag = "\u{f015}"
    case tasklist = "\u{f0e5}"
    case telescope = "\u{f088}"
    case terminal = "\u{f0c8}"
    case textsize = "\u{f0e3}"
    case threebars = "\u{f05e}"
    case thumbsdown = "\u{f0db}"
    case thumbsup = "\u{f0da}"
    case tools = "\u{f031}"
    case trashcan = "\u{f0d0}"
    case triangledown = "\u{f05b}"
    case triangleleft = "\u{f044}"
    case triangleright = "\u{f05a}"
    case triangleup = "\u{f0aa}"
    case unfold = "\u{f039}"
    case unmute = "\u{f0ba}"
    case unverified = "\u{f0e8}"
    case verified = "\u{f0e6}"
    case versions = "\u{f064}"
    case watch = "\u{f0e0}"
    case x = "\u{f081}"
    case zap = "\u{26a1}"
    
    func iconString(_ text: String, iconSize: CGFloat = 14, iconColor: UIColor? = nil, attributes: [String: AnyObject]? = nil) -> NSAttributedString {
        
        var iconAttributes: [String: AnyObject] = [NSFontAttributeName: UIFont.OcticonOfSize(iconSize)]
        if iconColor != nil {
            iconAttributes[NSForegroundColorAttributeName] = iconColor
        }
        
        let iconString = NSMutableAttributedString(string: "\(self)", attributes: iconAttributes)
        let attributedText = NSMutableAttributedString(string: " \(text)")
        
        if let unwrapAttributes = attributes {
            attributedText.addAttributes(unwrapAttributes, range: NSMakeRange(1, text.characters.count))
        }
        
        iconString.append(attributedText)
        
        return iconString
    }
    
    var description : String {
        get {
            return self.rawValue
        }
    }
}

extension UIFont {
    @inline(__always) class func OcticonOfSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "octicons", size: fontSize)!
    }
}
