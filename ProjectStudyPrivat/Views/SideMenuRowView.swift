//
//  SideMenuRowView.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 10.05.24.
//

import SwiftUI

struct SideMenuRowView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .imageScale(.medium)
            
            Text("Profile")
                .font(.title3)
            
            Spacer()
        }
        .padding(.leading)
    }
}

#Preview {
    SideMenuRowView()
}
