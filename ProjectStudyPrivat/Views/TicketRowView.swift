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
            Text(ticket.reference)
                .foregroundColor(isHighlighted ? .gray : .primary)
            
            Spacer()
            
            Button(action: {
                viewModel.showInfoTicketDialog()
            }) {
                Image(systemName: "info.circle")
                    .padding()
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $viewModel.isInfoButtonClicked, content: {
                TicketDetailsView(ticket: ticket)
            })
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // color will change after 0.3 seconds after clicking the button
            isHighlighted = true
            openChat(ticket)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isHighlighted = false
            }
        }
    }
    
    private func openChat(_ ticket: Ticket) {
        selectedTicket = ticket
        print("Ticket is clicked \(ticket.reference)")
        // have to implement: chat with support
    }
}

#Preview {
    TicketRowView(selectedTicket: .constant(nil), ticket: Ticket(reference: "Example Ticket", description: "Example Description"))
}
