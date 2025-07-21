//
//  CustomTabBar.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 2/6/25.
//

import SwiftUI
import FirebaseAuth

enum Tab: String, CaseIterable {
    case home, posts, idea, announcements, profile

    var displayName: String {
        switch self {
        case .home: return "Home"
        case .posts: return "Posts"
        case .idea: return "Idea Incubator"
        case .announcements: return "Announcements"
        case .profile: return "Profile"
        }
    }
}


let tabItems: [TabItem] = [
    TabItem(tab: .home, iconName: "house.fill"),
    
    TabItem(tab: .posts, iconName: "message.fill"),
    TabItem(tab: .idea, iconName: "lightbulb.fill"),
    TabItem(tab: .announcements, iconName: "megaphone.fill"),
    TabItem(tab: .profile, iconName: "person.crop.circle.fill"),
]

struct TabItem: Identifiable {
    let id = UUID()
    let tab: Tab
    let iconName: String
}



struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 40) {
            ForEach(tabItems) { item in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedTab = item.tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.iconName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(selectedTab == item.tab ? Color.white : Color.white.opacity(0.4))
                            .scaleEffect(selectedTab == item.tab ? 1.5 : 1.0)
                            .opacity(selectedTab == item.tab ? 1 : 0.7)
                        
                        if selectedTab == item.tab {
                            Capsule()
                                .fill(Color.white)
                                .matchedGeometryEffect(id: "underline", in: animation)
                                .frame(width: 20, height: 4)
                                .offset(y: 2)
                        } else {
                            Color.clear.frame(height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .accessibilityLabel(item.tab.displayName)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Color(.purple)
                .opacity(0.1)
                .background(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal)
    }
}

struct TabBarContainer: View {
    @State private var selectedTab: Tab = .profile
    var body: some View {
        ZStack {
            Group {
                switch selectedTab {
                    case .home:
                        HomeView()
                    case .posts:
                        PostsView()
                    case .idea:
                        IdeaIncubatorView()
                    case .announcements:
                        AnnouncementsView()
                    case .profile:
                        ProfilePage()
                    @unknown default:
                        EmptyView()
                }
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            
            
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    TabBarContainer()
}




