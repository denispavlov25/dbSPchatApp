//
//  ChatViewModel.swift
//  ProjectStudyPrivat
//
//  Created by Denis Pavlov on 26.06.24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class ChatViewModel: ObservableObject {
    @Published var chatText = ""
    
    private let ref: DatabaseReference
    
    init(ticket: Ticket) {
        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("Current user ID not found")
        }
        self.ref = Database.database().reference().child("users").child(userID).child("tickets").child(ticket.id.uuidString).child("messages")
    }
    
    func handleSend() {
        guard !chatText.isEmpty else { return }
        
        // create a dictionary representing the message
        let messageDict: [String: Any] = [
            "text": chatText,
            "timestamp": ServerValue.timestamp()
        ]
        
        // generate a new message reference with a unique key
        let messageRef = ref.childByAutoId()
        
        // save the message to the database
        messageRef.setValue(messageDict) { error, _ in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
                self.chatText = ""
            }
        }
    }
}
