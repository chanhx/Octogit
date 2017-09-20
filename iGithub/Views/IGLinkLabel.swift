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
    @objc optional func linkLabel(_ label: IGLinkLabel, didTapLinkWithURL URL: URL)    
    @objc optional func linkLabel(_ label: IGLinkLabel, didLongPressLinkWithURL URL: URL)
}

class IGLinkLabel: UILabel {
    
    fileprivate let textStorage = NSTextStorage()
    fileprivate let layoutManager = NSLayoutManager()
    fileprivate let textContainer = NSTextContainer()
    
    fileprivate var linkRanges: [LinkRange]?
    fileprivate var tappedLinkRange: LinkRange?
    
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
    
    fileprivate func commonInit() {
        textContainer.maximumNumberOfLines = 0
        textContainer.lineBreakMode = .byWordWrapping
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        isUserInteractionEnabled = true
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(IGLinkLabel.handleTap(_:))))
    }
    
    fileprivate struct LinkRange {
        let URL: Foundation.URL
        let glyphRange: NSRange
    }
    
    fileprivate func processLinks() {
        var ranges = [LinkRange]()
        if let attributedText = attributedText {
            textStorage.setAttributedString(attributedText)
            
            textStorage.enumerateAttribute(NSAttributedStringKey.link, in: NSRange(location: 0, length: textStorage.length), options: []) { (value, range, _) in
                // Because NSLinkAttributeName supports both NSURL and NSString
                // values. *sigh*
                let URL: Foundation.URL? = {
                    if let string = value as? String {
                        return Foundation.URL(string: string)
                    } else {
                        return value as? Foundation.URL
                    }
                }()
                
                if let URL = URL {
                    let glyphRange = self.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                    ranges.append(LinkRange(URL: URL, glyphRange: glyphRange))
                    
                    // Remove `NSLinkAttributeName` to prevent `UILabel` from applying
                    // the default styling.
                    self.textStorage.removeAttribute(NSAttributedStringKey.link, range: range)
                    
                    let originalAttributes = self.textStorage.attributes(at: range.location, effectiveRange: nil)
                    var proposedAttributes = originalAttributes
                    
                    if originalAttributes[NSAttributedStringKey.foregroundColor] == nil {
                        proposedAttributes[NSAttributedStringKey.foregroundColor] = UIColor(netHex: 0x80A6CD)
                    }
                    if originalAttributes[NSAttributedStringKey.underlineStyle] == nil {
                        proposedAttributes[NSAttributedStringKey.underlineStyle] = NSUnderlineStyle.styleNone.rawValue
                    }
                    self.textStorage.setAttributes(proposedAttributes, range: range)
                }
            }
        }
        
        linkRanges = ranges
        super.attributedText = textStorage
    }
    
    // MARK: Touches
    
    fileprivate func linkRangeAtPoint(_ point: CGPoint) -> LinkRange? {
        if let linkRanges = linkRanges {
            // Passing in the UILabel's fitting size here doesn't work, the height
            // needs to be unrestricted for it to correctly lay out all the text.
            // Might be due to a difference in the computed text sizes of `UILabel`
            // and `NSLayoutManager`.
            textContainer.size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
            layoutManager.ensureLayout(for: textContainer)
            let boundingRect = layoutManager.boundingRect(forGlyphRange: layoutManager.glyphRange(for: textContainer), in: textContainer)
            
            if boundingRect.contains(point) {
                let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
                for linkRange in linkRanges {
                    if NSLocationInRange(glyphIndex, linkRange.glyphRange) {
                        return linkRange
                    }
                }
            }
        }
        return nil
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Any taps that don't hit a link are ignored and passed to the next
        // responder.
        return linkRangeAtPoint(point) != nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            tappedLinkRange = linkRangeAtPoint(touch.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tappedLinkRange = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        tappedLinkRange = nil
    }
    
    @objc fileprivate func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if let linkRange = tappedLinkRange {
            delegate?.linkLabel?(self, didTapLinkWithURL: linkRange.URL)
        }
    }
    
}
