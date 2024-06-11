//
//  TicketRowViewModel.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 14.05.24.
//

import Foundation

class TicketRowViewModel: ObservableObject {
    @Published var shouldNavigate = false
    @Published var isInfoButtonClicked = false

    private func addNewTicket() {
        self.shouldNavigate = true
    }
    
    func showInfoTicketDialog() {
        isInfoButtonClicked.toggle()
    }

}
