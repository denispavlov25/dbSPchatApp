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
    
    init() {
        //ensure there is a current authenticated user
        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("Current user ID not found")
        }
        //set up a reference to the firebase
        self.ref = Database.database().reference().child("users").child(userID).child("tickets")
    }
    
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
    
    func fetchTickets() async {
        do {
            //fetch data from firebase asynchronously
            let snapshot = try await ref.getData()
            
            //going to the main ui thread to update ui components
            DispatchQueue.main.async {
                var fetchedTickets: [Ticket] = []
                
                //iterating through each child snapshot in the retrieved firebase snapshot
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let ticketDict = child.value as? [String: Any],
                          let reference = ticketDict["reference"] as? String,
                          let description = ticketDict["description"] as? String else {
                        //skip to the next child if essential properties are missing
                        continue
                    }
                    //optional: extracting appendedPhotos from the dictionary
                    let appendedPhotos = ticketDict["appendedPhotos"] as? [String]
                    
                    if let ticketId = UUID(uuidString: child.key) {
                        //creating a ticket object using retrieved data and append it to the fetchedTickets array
                        let ticket = Ticket(id: ticketId, reference: reference, description: description, appendedPhotos: appendedPhotos)
                        fetchedTickets.append(ticket)
                    } else {
                        print("Invalid UUID string: \(child.key)")
                    }
                }
                //updating tickets with fetchedTickets on the main ui thread
                self.tickets = fetchedTickets
            }
        } catch {
            print("Failed to fetch tickets: \(error.localizedDescription)")
        }
    }
}
