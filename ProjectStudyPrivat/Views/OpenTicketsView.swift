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
    @State private var showingAlert = false

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
        .onAppear {
            Task {
                await viewModel.fetchTickets()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Close Ticket"),
                message: Text("Are you sure you want to close this ticket?"),
                primaryButton: .default(Text("OK")) {
                    if let selectedTicket = selectedTicket {
                        viewModel.closeTicket(selectedTicket)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    //views are split to make the code clearer
    private var ticketListView: some View {
        VStack {
            //tickets are passed to the TicketRowView
            List {
                ForEach(viewModel.tickets) { ticket in
                    TicketRowView(selectedTicket: $selectedTicket, ticket: ticket)
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                selectedTicket = ticket
                                showingAlert = true
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
                    //opening the menu
                    viewModel.showMenu()
                }, label: {
                    Image(systemName: "line.3.horizontal")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    //opening the sheet to create a new ticket
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
