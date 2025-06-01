//
//  ProfilePage.swift
//  IMDAConnect
//
//  Created by Joseph Kevin Fredric on 29/5/25.
//


import SwiftUI


struct ProfilePage: View {
    @AppStorage("name") var name: String = "Your Name"
    @AppStorage("role") var role: String = "Your Role"
    @AppStorage("school") var school: String = "Your School"
    @AppStorage("about") var about: String = "About Yourself"
    @State private var showEditSheet: Bool = false
    @Namespace private var animation
    @State private var isLoading = false
    
    @State private var pulse = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 74/255, green: 31/255, blue: 91/255),
                        Color(red: 100/255, green: 42/255, blue: 122/255)
                    ]),
                    startPoint: pulse ? .topLeading : .bottomTrailing,
                    endPoint: pulse ? .bottomTrailing : .topLeading
                )
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: pulse)
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer().frame(height: 40)
                        Circle()
                            .fill(Color.white.opacity(0.95))
                            .frame(width: 160, height: 160)
                            .shadow(color: .purple.opacity(0.4), radius: 15, x: 0, y: 5)
                            .scaleEffect(pulse ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                            .matchedGeometryEffect(id: "profilePic", in: animation)
                            .overlay(
                                Text(nameInitials())
                                    .font(.system(size: 64, weight: .bold))
                                    .foregroundColor(Color.purple.opacity(0.8))
                            )
                        
                        if isLoading {
                            loadingView()
                        } else {
                            VStack(spacing: 6) {
                                Text(name)
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                
                                
                                Text(role)
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.85))
                                    .transition(.opacity)
                                
                                
                                Text(school)
                                    .font(.title3.weight(.medium))
                                    .foregroundColor(.white.opacity(0.85))
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            .padding(.horizontal)
                            .animation(.easeOut(duration: 0.6), value: isLoading)
                        }
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showEditSheet = true
                            }
                        } label: {
                            Text("Edit Profile")
                                .fontWeight(.semibold)
                                .frame(width: 340, height: 45)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.15))
                                )
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Text("About")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        Text(about)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.white.opacity(0.1))
                            .frame(width: 370, height: 2)
                        Text("Past Projects")
                            .font(.title2.bold())
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                PastProject(title: "Teaching", date: "22 May", about: "Taught App creation at the School Of Science and Technology", image: "star.fill")
                                PastProject(title: "Teaching", date: "22 May", about: "Taught App creation at the School Of Science and Technology", image: "star.fill")
                                PastProject(title: "Teaching", date: "22 May", about: "Taught App creation at the School Of Science and Technology", image: "star.fill")
                                PastProject(title: "Teaching", date: "22 May", about: "Taught App creation at the School Of Science and Technology", image: "star.fill")
                            }
                        }
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.white.opacity(0.1))
                            .frame(width: 370, height: 2)
                        
                    }
                    .padding(.bottom, 50)
                }
                .onAppear {
                    pulse = true
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                }
                .sheet(isPresented: $showEditSheet) {
                    EditProfileSheet(name: $name, role: $role, school: $school, about: $about)
                }
            }
        }
    }
    
    func nameInitials() -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return initials.map { String($0) }.joined()
    }
    
    @ViewBuilder
    func loadingView() -> some View {
        VStack(spacing: 10) {
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 160, height: 24)
            
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 120, height: 18)
            
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 140, height: 18)
            
        }
        .padding(.top, 6)
    }
}


#Preview {
    ProfilePage()
}
