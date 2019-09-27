//
//  EventList.swift
//  Octogit
//
//  Created by Chan Hocheung on 2019/9/22.
//  Copyright © 2019 Hocheung. All rights reserved.
//

import SwiftUI

struct EventList: View {
    
    private var avatarSize: CGFloat = 42
    
    var body: some View {
        List {
            ForEach (0 ..< 3) { _ in
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "film")
                            .frame(width: self.avatarSize, alignment: .trailing)
                        Text("3 days ago")
                    }
                    HStack(spacing: 8) {
                        Image("tabbar_activities_selected")
                            .frame(width: self.avatarSize, height: self.avatarSize, alignment: .center)
                        Text("abcewdwe")
                    }
                    Text("adfasdjfadjsfoiai")
                }
            }
        }
    }
}

struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        EventList()
    }
}
