//
//  HomeView.swift
//  Octogit
//
//  Created by Chan Hocheung on 2019/9/22.
//  Copyright © 2019 Hocheung. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @State var selectedTab = 0
    
    var body: some View {
        TabbarView()
    }
}

struct TabbarView: View {
    
    @State private var index = 0
    typealias Content = View
    
    var body: some View {
        TabView(selection: $index) {
            EventList()
                .tabItem({
//                    Image(index == 0 ? "tabbar_activities_selected" : "tabbar_activities")
//                        .renderingMode(.original)
                    Image(systemName: "house.fill")
                    Text("Events")
                })
            	.tag(0)

            ExplorationView()
                .tabItem({
//                    Image(index == 1 ? "tabbar_compass_selected" : "tabbar_compass")
//                    	.renderingMode(.original)
                    Image(systemName: "safari.fill")
                    Text("Explore")
                })
            	.tag(1)

            ProfileView()
                .tabItem({
//                    Image(index == 2 ? "tabbar_avatar_selected" : "tabbar_avatar")
//                    	.renderingMode(.original)
                    Image(systemName: "person.crop.circle.fill")
                    Text("Me")
                })
            	.tag(2)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
