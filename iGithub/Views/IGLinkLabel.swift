//
//  IGLinkLabel.swift
//  iGithub
//
//  Created by Chan Hocheung on 8/5/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

// modified edition of INDLinkLabel ( https://github.com/indragiek/INDLinkLabel )

import UIKit

@objc protocol IGLinkLabelDelegate {
    optional func linkLabel(label: IGLinkLabel, didTapLinkWithURL URL: NSURL)    
    optional func linkLabel(label: IGLinkLabel, didLongPressLinkWithURL URL: NSURL)
}

class IGLinkLabel: UILabel {
    
    private let textStorage = NSTextStorage()
    private let layoutManager = NSLayoutManager()
    private let textContainer = NSTextContainer()
    
    private var linkRanges: [LinkRange]?
    private var tappedLinkRange: LinkRange?
    
    weak var delegate: IGLinkLabelDelegate?
    
    override var attributedText: NSAttributedString? {
        didSet {
            processLinks()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        textContainer.maximumNumberOfLines = 0
        textContainer.lineBreakMode = .ByWordWrapping
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        userInteractionEnabled = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(IGLinkLabel.handleTap(_:))))
    }
    
    private struct LinkRange {
        let URL: NSURL
        let glyphRange: NSRange
    }
    
    private func processLinks() {
        var ranges = [LinkRange]()
        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
            
            textStorage.enumerateAttribute(NSLinkAttributeName, inRange: NSRange(location: 0, length: textStorage.length), options: []) { (value, range, _) in
                // Because NSLinkAttributeName supports both NSURL and NSString
                // values. *sigh*
                let URL: NSURL? = {
                    if let string = value as? String {
                        return NSURL(string: string)
                    } else {
                        return value as? NSURL
                    }
                }()
                
                if let URL = URL {
                    let glyphRange = self.layoutManager.glyphRangeForCharacterRange(range, actualCharacterRange: nil)
                    ranges.append(LinkRange(URL: URL, glyphRange: glyphRange))
                    
                    // Remove `NSLinkAttributeName` to prevent `UILabel` from applying
                    // the default styling.
                    self.textStorage.removeAttribute(NSLinkAttributeName, range: range)
                    
                    let originalAttributes = self.textStorage.attributesAtIndex(range.location, effectiveRange: nil)
                    var proposedAttributes = originalAttributes
                    
                    if originalAttributes[NSForegroundColorAttributeName] == nil {
                        proposedAttributes[NSForegroundColorAttributeName] = UIColor(netHex: 0x80A6CD)
                    }
                    if originalAttributes[NSUnderlineStyleAttributeName] == nil {
                        proposedAttributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.StyleNone.rawValue
                    }
                    self.textStorage.setAttributes(proposedAttributes, range: range)
                }
            }
        }
        
        linkRanges = ranges
        super.attributedText = textStorage
    }
    
    // MARK: Touches
    
    private func linkRangeAtPoint(point: CGPoint) -> LinkRange? {
        if let linkRanges = linkRanges {
            // Passing in the UILabel's fitting size here doesn't work, the height
            // needs to be unrestricted for it to correctly lay out all the text.
            // Might be due to a difference in the computed text sizes of `UILabel`
            // and `NSLayoutManager`.
            textContainer.size = CGSize(width: CGRectGetWidth(bounds), height: CGFloat.max)
            layoutManager.ensureLayoutForTextContainer(textContainer)
            let boundingRect = layoutManager.boundingRectForGlyphRange(layoutManager.glyphRangeForTextContainer(textContainer), inTextContainer: textContainer)
            
            if boundingRect.contains(point) {
                let glyphIndex = layoutManager.glyphIndexForPoint(point, inTextContainer: textContainer)
                for linkRange in linkRanges {
                    if NSLocationInRange(glyphIndex, linkRange.glyphRange) {
                        return linkRange
                    }
                }
            }
        }
        return nil
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        // Any taps that don't hit a link are ignored and passed to the next
        // responder.
        return linkRangeAtPoint(point) != nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            tappedLinkRange = linkRangeAtPoint(touch.locationInView(self))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        tappedLinkRange = nil
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        tappedLinkRange = nil
    }
    
    @objc private func handleTap(gestureRecognizer: UIGestureRecognizer) {
        if let linkRange = tappedLinkRange {
            delegate?.linkLabel?(self, didTapLinkWithURL: linkRange.URL)
        }
    }
    
}