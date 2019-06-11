//
//  IndicatorButton.swift
//  iGithub
//
//  Created by Chan Hocheung on 10/08/2017.
//  Copyright © 2017 Hocheung. All rights reserved.
//

import UIKit

class IndicatorButton: GradientButton {
    
    let indicatorView = UIActivityIndicatorView(style: .gray)
    var originalImage: UIImage?

    func showIndicator() {
        
        isEnabled = false
        
        if let currentImage = self.currentImage {
            UIGraphicsBeginImageContextWithOptions(currentImage.size, false, 0)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            super.setImage(image, for: .normal)
        }
        
        var frame = titleLabel?.frame
        
        frame?.origin.x -= 23
        frame?.origin.y -= 1
        frame?.size.width = 20
        frame?.size.height = 20
        
        indicatorView.frame = frame!
        addSubview(indicatorView)
        indicatorView.startAnimating()
    }
    
    func stopIndictorAnimation() {
        super.setImage(originalImage, for: .normal)
        indicatorView.removeFromSuperview()
        
        isEnabled = true
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        originalImage = image
        super.setImage(image, for: state)
    }
}
