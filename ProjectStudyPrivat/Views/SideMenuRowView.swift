//
//  SideMenuRowView.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 10.05.24.
//

import SwiftUI

struct SideMenuRowView: View {
    @State private var navigateToLoginView = false
    
    var body: some View {
        NavigationStack {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                    .imageScale(.medium)
                    .foregroundStyle(Color.red)
                Button {
                    navigateToLoginView = true
                } label: {
                    Text("Log out")
                        .font(.title3)
                        .foregroundStyle(Color.black)
                }
                
                Spacer()
            }
            .padding(.leading)
        }
        .navigationDestination(isPresented: $navigateToLoginView) {
            LoginView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SideMenuRowView()
}
