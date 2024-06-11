//
//  OpenTicketsViewModel.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 10.05.24.
//

import Foundation

class OpenTicketsViewModel: ObservableObject {
    @Published var isShowingMenu = false
    @Published var isAddButtonClicked = false
    @Published var tickets: [Ticket] = []
    
    func showMenu() {
        isShowingMenu.toggle()
    }
    
    func showNewTicketDialog() {
        isAddButtonClicked.toggle()
    }
    
    func addTicket(_ ticket: Ticket) {
        tickets.append(ticket)
    }
    
    func closeTicket(_ ticket: Ticket) {
        if let index = tickets.firstIndex(where: { $0.id == ticket.id }) {
            tickets.remove(at: index)
        }
    }
}
