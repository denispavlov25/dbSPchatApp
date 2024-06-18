//
//  OpenTicketsViewModel.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 10.05.24.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class OpenTicketsViewModel: ObservableObject {
    @Published var isShowingMenu = false
    @Published var isAddButtonClicked = false
    @Published var tickets: [Ticket] = []
    
    private lazy var ref: DatabaseReference = {
        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("Current user ID not found")
        }
        return Database.database().reference().child("users").child(userID).child("tickets")
    }()
    
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
            // remove locally
            tickets.remove(at: index)
            
            // remove from Firebase
            ref.child(ticket.reference).removeValue { error, _ in
                if let error = error {
                    print("Failed to remove ticket from Firebase: \(error.localizedDescription)")
                } else {
                    print("Ticket removed successfully from Firebase")
                }
            }
        }
    }
    
    func fetchTickets() async {
        do {
            let snapshot = try await ref.getData()
            
            DispatchQueue.main.async {
                var fetchedTickets: [Ticket] = []
                
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let ticketDict = childSnapshot.value as? [String: Any],
                       let reference = ticketDict["reference"] as? String,
                       let description = ticketDict["description"] as? String,
                       let appendedPhotos = ticketDict["appendedPhotos"] as? [String] {
                        let ticket = Ticket(reference: reference, description: description, appendedPhotos: appendedPhotos)
                        fetchedTickets.append(ticket)
                    }
                }
                
                self.tickets = fetchedTickets
            }
        } catch {
            print("Failed to fetch tickets: \(error.localizedDescription)")
        }
    }
}
