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
    
    private let ref: DatabaseReference
    private var ticketsListenerHandle: DatabaseHandle?
    var isSupportAccount: Bool
    
    init(isSupportAccount: Bool) {
        self.isSupportAccount = isSupportAccount
        if isSupportAccount {
            self.ref = Database.database().reference().child("users").child("regularAccounts")
        } else {
            //ensure there is a current authenticated user
            guard let userID = Auth.auth().currentUser?.uid else {
                fatalError("Current user ID not found")
            }
            self.ref = Database.database().reference().child("users").child("regularAccounts").child(userID).child("tickets")
        }
    }
    
    func showMenu() {
        isShowingMenu.toggle()
    }
    
    func showNewTicketDialog() {
        isAddButtonClicked.toggle()
    }
    
    func addTicket(_ ticket: Ticket) {
        if !tickets.contains(where: { $0.id == ticket.id }) {
            tickets.append(ticket)
        }
    }
    
    func closeTicket(_ ticket: Ticket) {
        if let index = tickets.firstIndex(where: { $0.reference == ticket.reference }) {
            //remove locally
            tickets.remove(at: index)
        }
        
        //remove from firebase
        ref.child(ticket.id.uuidString).removeValue { error, _ in
            if let error = error {
                print("Failed to remove ticket from Firebase: \(error.localizedDescription)")
            } else {
                print("Ticket removed successfully from Firebase")
            }
        }
    }
    
    func startListeningForTickets() {
        ticketsListenerHandle = ref.observe(.value) { [weak self] snapshot in
            self?.handleTicketsSnapshot(snapshot)
        }
    }
        
    func stopListeningForTickets() {
        if let handle = ticketsListenerHandle {
            ref.removeObserver(withHandle: handle)
        }
    }
    
    private func handleTicketsSnapshot(_ snapshot: DataSnapshot) {
        DispatchQueue.main.async {
            self.tickets = self.parseTickets(snapshot: snapshot, forSupportAccount: self.isSupportAccount)
        }
    }
    
    func fetchTickets() async {
        do {
            //fetch data from firebase asynchronously
            let snapshot = try await ref.getData()
            
            //going to the main ui thread to update ui components
            DispatchQueue.main.async {
                self.tickets = self.parseTickets(snapshot: snapshot, forSupportAccount: self.isSupportAccount)
            }
        } catch {
            print("Failed to fetch tickets: \(error.localizedDescription)")
        }
    }

    private func parseTickets(snapshot: DataSnapshot, forSupportAccount: Bool) -> [Ticket] {
        var fetchedTickets: [Ticket] = []

        if forSupportAccount {
            //iterating through each child snapshot in the retrieved firebase snapshot
            for userSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let userTicketsRef = userSnapshot.childSnapshot(forPath: "tickets")

                //iterating through each ticket in the user's tickets
                for ticketSnapshot in userTicketsRef.children.allObjects as! [DataSnapshot] {
                    if let ticket = parseTicket(snapshot: ticketSnapshot) {
                        fetchedTickets.append(ticket)
                    }
                }
            }
        } else {
            //iterating through each ticket for the current user
            for ticketSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                if let ticket = parseTicket(snapshot: ticketSnapshot) {
                    fetchedTickets.append(ticket)
                }
            }
        }

        return fetchedTickets
    }

    private func parseTicket(snapshot: DataSnapshot) -> Ticket? {
        guard let ticketDict = snapshot.value as? [String: Any],
              let reference = ticketDict["reference"] as? String,
              let description = ticketDict["description"] as? String else {
            //skip to the next child if essential properties are missing
            return nil
        }

        let appendedPhotos = ticketDict["appendedPhotos"] as? [String]

        if let ticketId = UUID(uuidString: snapshot.key) {
            //creating a ticket object using retrieved data and append it to the fetchedTickets array
            return Ticket(id: ticketId, reference: reference, description: description, appendedPhotos: appendedPhotos)
        } else {
            print("Invalid UUID string: \(snapshot.key)")
            return nil
        }
    }
}
