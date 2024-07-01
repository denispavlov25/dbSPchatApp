//
//  SideMenuView.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 10.05.24.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            if isShowing {
                Rectangle()
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                HStack {
                    VStack(alignment: .leading, spacing: 32) {
                        SideMenuRowView()
                        
                        Spacer()
                    }
                    .padding()
                    .frame(width: 270, alignment: .leading)
                    .background(.white)
                    
                    Spacer()
                }
            }
        }
        //moving the view in/out from the left edge
        .transition(.move(edge: .leading))
        .animation(.easeOut, value: isShowing)
    }
}

#Preview {
    SideMenuView(isShowing: .constant(true))
}
