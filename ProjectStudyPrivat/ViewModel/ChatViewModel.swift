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
    @Published var messages: [Message] = []
    
    private let ticket: Ticket
    private let ref: DatabaseReference
    
    init(ticket: Ticket) {
        self.ticket = ticket

        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("Current user ID not found")
        }
        self.ref = Database.database().reference().child("users").child(userID).child("tickets").child(ticket.id.uuidString).child("messages")
    }
    
    func handleSend() {
        //ensuring the chatText is not empty
        guard !chatText.isEmpty else { return }
        
        //generating a unique id
        let messageId = UUID().uuidString
        //get standard timestamp
        let unixTimestamp = Date().timeIntervalSince1970
        //creating a dictionary containing the message data
        let messageDict: [String: Any] = [
            "text": chatText,
            "timestamp": unixTimestamp
        ]
        
        //reference to the specific message
        let messageRef = ref.child(messageId)
        
        //set the message data to the firebase
        messageRef.setValue(messageDict) { error, _ in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
                //clear chatText after sending message
                self.chatText = ""
                
                //fetching updated messages asynchronously on the ui
                Task {
                    await self.fetchMessages()
                }
            }
        }
    }
    
    func fetchMessages() async {
        do {
            let snapshot = try await ref.getData()
            
            DispatchQueue.main.async {
                var fetchedMessages: [Message] = []
                
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    guard let messageDict = child.value as? [String: Any],
                          let text = messageDict["text"] as? String,
                          let timestamp = messageDict["timestamp"] as? Double else {
                        continue
                    }

                    if let messageId = UUID(uuidString: child.key) {
                        let message = Message(id: messageId, text: text, timestamp: timestamp)
                        fetchedMessages.append(message)
                    } else {
                        print("Invalid UUID string: \(child.key)")
                    }
                }
                
                self.messages = fetchedMessages.sorted { $0.timestamp < $1.timestamp }
            }
        } catch {
            print("Failed to fetch messages: \(error.localizedDescription)")
        }
    }
}
