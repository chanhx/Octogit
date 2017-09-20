//
//  File+DataProcess.swift
//  iGithub
//
//  Created by Chan Hocheung on 9/13/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation

extension File {    
    var shortSHA: String {
        return String(sha![...sha!.index(sha!.startIndex, offsetBy: 7)])
    }
}
