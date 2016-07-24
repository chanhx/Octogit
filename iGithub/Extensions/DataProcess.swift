//
//  DataProcess.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/24/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import Foundation
import SwiftDate

extension NSDate {
    var naturalString: String {
        let date = NSDate()
        let suffix = self < date ? "ago" : "later"
        return "\(self.toNaturalString(date, style: FormatterStyle(style: .Full, max: 1))!) \(suffix)"
    }
}