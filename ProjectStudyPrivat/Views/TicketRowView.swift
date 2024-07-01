//
//  TicketRowView.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 14.05.24.
//

import SwiftUI

struct TicketRowView: View {
    @Binding var selectedTicket: Ticket?
    @StateObject private var viewModel = TicketRowViewModel()
    @State private var isHighlighted: Bool = false
    
    let ticket: Ticket
    
    var body: some View {
        HStack {
            // change the color of selected text
            Button(action: {
                viewModel.navigateToChatView = true
            }) {
                Text(ticket.reference)
                    .foregroundStyle(Color.black)
            }
            .sheet(isPresented: $viewModel.navigateToChatView, content: {
                ChatView(ticket: ticket)
            })
            
            Spacer()
            
            Button(action: {
                viewModel.showInfoTicketDialog()
            }) {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color.blue)
                    .padding()
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $viewModel.isInfoButtonClicked, content: {
                TicketDetailsView(ticket: ticket)
            })
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    TicketRowView(selectedTicket: .constant(nil), ticket: Ticket(id: UUID(), reference: "Example Ticket", description: "Example Description"))
}
