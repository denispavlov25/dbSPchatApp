//
//  OpenTicketsView.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 08.05.24.
//

import SwiftUI

struct OpenTicketsView: View {
    @StateObject private var viewModel = OpenTicketsViewModel()
    @State private var selectedTicket: Ticket?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ticketListView
                SideMenuView(isShowing: $viewModel.isShowingMenu)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(viewModel.isShowingMenu ? .hidden : .visible, for: .navigationBar)
            .navigationTitle("Open Tickets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                topBar
            }
        }
    }
    
    // Views are split to make the code clearer
    private var ticketListView: some View {
        VStack {
            // Tickets are passed to the TicketRowView
            List {
                ForEach(viewModel.tickets) { ticket in
                    TicketRowView(selectedTicket: $selectedTicket, ticket: ticket)
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                // Handle close ticket action here
                                viewModel.closeTicket(ticket)
                            }) {
                                Text("Close ticket")
                            }
                            .tint(.red)
                        }
                }
            }
        }
    }
    
    private var topBar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.showMenu()
                }, label: {
                    Image(systemName: "line.3.horizontal")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.showNewTicketDialog()
                }, label: {
                    Image(systemName: "plus")
                })
                .sheet(isPresented: $viewModel.isAddButtonClicked, content: {
                    NewTicketView(openTicketsViewModel: viewModel)
                })
            }
        }
    }
}

#Preview {
    OpenTicketsView()
}
