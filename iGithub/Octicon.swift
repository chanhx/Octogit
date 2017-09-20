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
    case arrowDown = "\u{f03f}"
    case arrowLeft = "\u{f040}"
    case arrowRight = "\u{f03e}"
    case arrowSmallDown = "\u{f0a0}"
    case arrowSmallLeft = "\u{f0a1}"
    case arrowSmallRight = "\u{f071}"
    case arrowSmallUp = "\u{f09f}"
    case arrowUp = "\u{f03d}"
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
    case checkList = "\u{f076}"
    case chevronDown = "\u{f0a3}"
    case chevronLeft = "\u{f0a4}"
    case chevronRight = "\u{f078}"
    case chevronUp = "\u{f0a2}"
    case circleSlash = "\u{f084}"
    case circuitBoard = "\u{f0d6}"
    case clippy = "\u{f035}"
    case clock = "\u{f046}"
    case cloudDownload = "\u{f00b}"
    case cloudUpload = "\u{f00c}"
    case code = "\u{f05f}"
    case commentDiscussion = "\u{f04f}"
    case comment = "\u{f02b}"
    case creditCard = "\u{f045}"
    case dash = "\u{f0ca}"
    case dashboard = "\u{f07d}"
    case database = "\u{f096}"
    case desktopDownload = "\u{f0dc}"
    case deviceCameraVideo = "\u{f057}"
    case deviceCamera = "\u{f056}"
    case deviceDesktop = "\u{f27c}"
    case deviceMobile = "\u{f038}"
    case diffAdded = "\u{f06b}"
    case diffIgnored = "\u{f099}"
    case diffModified = "\u{f06d}"
    case diffRemoved = "\u{f06c}"
    case diffRenamed = "\u{f06e}"
    case diff = "\u{f04d}"
    case ellipsis = "\u{f09a}"
    case eye = "\u{f04e}"
    case fileBinary = "\u{f094}"
    case fileCode = "\u{f010}"
    case fileDirectory = "\u{f016}"
    case fileMedia = "\u{f012}"
    case filePDF = "\u{f014}"
    case fileSubmodule = "\u{f017}"
    case fileSymlinkDirectory = "\u{f0b1}"
    case fileSymlinkFile = "\u{f0b0}"
    case fileText = "\u{f011}"
    case fileZip = "\u{f013}"
    case flame = "\u{f0d2}"
    case fold = "\u{f0cc}"
    case gear = "\u{f02f}"
    case gift = "\u{f042}"
    case gistSecret = "\u{f08c}"
    case gist = "\u{f00e}"
    case gitBranch = "\u{f020}"
    case gitCommit = "\u{f01f}"
    case gitCompare = "\u{f0ac}"
    case gitMerge = "\u{f023}"
    case gitPullrequest = "\u{f009}"
    case globe = "\u{f0b6}"
    case graph = "\u{f043}"
    case heart = "\u{2665}"
    case history = "\u{f07e}"
    case home = "\u{f08d}"
    case horizontalRule = "\u{f070}"
    case hubot = "\u{f09d}"
    case inbox = "\u{f0cf}"
    case info = "\u{f059}"
    case issueClosed = "\u{f028}"
    case issueOpened = "\u{f026}"
    case issueReopened = "\u{f027}"
    case italic = "\u{f0e4}"
    case jersey = "\u{f019}"
    case key = "\u{f049}"
    case keyboard = "\u{f00d}"
    case law = "\u{f0d8}"
    case lightBulb = "\u{f000}"
    case linkExternal = "\u{f07f}"
    case link = "\u{f05c}"
    case listOrdered = "\u{f062}"
    case listUnordered = "\u{f061}"
    case location = "\u{f060}"
    case lock = "\u{f06a}"
    case logoGist = "\u{f0ad}"
    case logoGithub = "\u{f092}"
    case mailRead = "\u{f03c}"
    case mailReply = "\u{f051}"
    case mail = "\u{f03b}"
    case markGithub = "\u{f00a}"
    case markDown = "\u{f0c9}"
    case megaphone = "\u{f077}"
    case mention = "\u{f0be}"
    case milestone = "\u{f075}"
    case mirror = "\u{f024}"
    case mortarBoard = "\u{f0d7}"
    case mute = "\u{f080}"
    case noNewline = "\u{f09c}"
    case octoface = "\u{f008}"
    case organization = "\u{f037}"
    case package = "\u{f0c4}"
    case paintcan = "\u{f0d1}"
    case pencil = "\u{f058}"
    case person = "\u{f018}"
    case pin = "\u{f041}"
    case plug = "\u{f0d4}"
    case plus = "\u{f05d}"
    case primitiveDot = "\u{f052}"
    case primitiveSquare = "\u{f053}"
    case pulse = "\u{f085}"
    case question = "\u{f02c}"
    case quote = "\u{f063}"
    case radioTower = "\u{f030}"
    case repoClone = "\u{f04c}"
    case repoForcePush = "\u{f04a}"
    case repoForked = "\u{f002}"
    case repoPull = "\u{f006}"
    case repoPush = "\u{f005}"
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
    case textSize = "\u{f0e3}"
    case threeBars = "\u{f05e}"
    case thumbsdown = "\u{f0db}"
    case thumbsup = "\u{f0da}"
    case tools = "\u{f031}"
    case trashcan = "\u{f0d0}"
    case triangleDown = "\u{f05b}"
    case triangleLeft = "\u{f044}"
    case triangleRight = "\u{f05a}"
    case triangleUp = "\u{f0aa}"
    case unfold = "\u{f039}"
    case unmute = "\u{f0ba}"
    case unverified = "\u{f0e8}"
    case verified = "\u{f0e6}"
    case versions = "\u{f064}"
    case watch = "\u{f0e0}"
    case x = "\u{f081}"
    case zap = "\u{26a1}"
    
    func iconString(_ text: String, iconSize: CGFloat = 14, iconColor: UIColor? = nil, attributes: [NSAttributedStringKey: AnyObject]? = nil) -> NSMutableAttributedString {
        
        var iconAttributes: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont.OcticonOfSize(iconSize)]
        if iconColor != nil {
            iconAttributes[NSAttributedStringKey.foregroundColor] = iconColor
        }
        
        let iconString = NSMutableAttributedString(string: "\(self)", attributes: iconAttributes)
        let attributedText = NSMutableAttributedString(string: " \(text)")
        
        if let attributes = attributes {
            attributedText.addAttributes(attributes, range: NSMakeRange(1, text.characters.count))
        }
        
        iconString.append(attributedText)
        
        return iconString
    }
    
    func image(color: UIColor = UIColor(netHex: 0x333333), backgroundColor: UIColor = .clear, iconSize: CGFloat, size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        (rawValue as NSString).draw(in: CGRect(origin: CGPoint.zero, size: size),
                                    withAttributes: [
                                        NSAttributedStringKey.font: UIFont.OcticonOfSize(iconSize),
                                        NSAttributedStringKey.foregroundColor: color,
                                        NSAttributedStringKey.backgroundColor: backgroundColor])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    var description: String {
        return self.rawValue
    }
}

extension UIFont {
    @inline(__always) class func OcticonOfSize(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "octicons", size: fontSize)!
    }
}
