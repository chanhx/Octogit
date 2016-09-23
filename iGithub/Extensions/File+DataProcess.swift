//
//  File+DataProcess.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/13/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

extension File {
    var MIMEType: String {
        let ext = self.name!.pathExtension
        switch ext {
        case "gif", "jpg", "jpeg", "png", "tif", "tiff":
            return "image/\(ext)"
        case "pdf", "rar", "zip":
            return "application/\(ext)"
        default:
            return "text/\(ext)"
        }
    }
    
    var shortenSHA: String {
        return sha!.substring(to: sha!.characters.index(sha!.startIndex, offsetBy: 7))
    }
}
