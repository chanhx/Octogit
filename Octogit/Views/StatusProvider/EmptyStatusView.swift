//
//  EmptyStatusView
//
//  Created by MarioHahn on 25/08/16.
//

import Foundation
import UIKit

open class EmptyStatusView: UIView {
    
    public let emptyTitleLabel: UILabel = {
        $0.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        
        return $0
    }(UILabel())
    
    public let emptyDescriptionLabel: UILabel = {
        $0.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption2)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        $0.numberOfLines = 0
        
        return $0
    }(UILabel())
    
    public let emptyImageView: UIImageView = {
        $0.contentMode = .center
        
        return $0
    }(UIImageView())
    
    let stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = 10
        
        return $0
    }(UIStackView())
    
    public convenience init(title: String?, caption: String? = nil, image: UIImage? = nil) {
        self.init(frame: CGRect.zero)
        
        if let title = title , title.count > 0 {
            emptyTitleLabel.text = title
        } else {
            emptyTitleLabel.isHidden = true
        }
        
        if let caption = caption , caption.count > 0 {
            emptyDescriptionLabel.text = caption
        } else {
            emptyDescriptionLabel.isHidden = true
        }
        
        if let image = image {
            emptyImageView.image = image
        } else {
            emptyImageView.isHidden = true
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        
        stackView.addArrangedSubview(emptyImageView)
        stackView.addArrangedSubview(emptyTitleLabel)
        stackView.addArrangedSubview(emptyDescriptionLabel)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    open override var tintColor: UIColor! {
        didSet {
            emptyTitleLabel.textColor = tintColor
            emptyDescriptionLabel.textColor = tintColor
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
