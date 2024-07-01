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
        
        Task {
            await fetchMessages()
        }
    }
    
    func handleSend() {
        guard !chatText.isEmpty else { return }
        
        let messageId = UUID().uuidString
        let messageDict: [String: Any] = [
            "text": chatText,
            "timestamp": ServerValue.timestamp()
        ]
        
        let messageRef = ref.child(messageId)
        
        messageRef.setValue(messageDict) { error, _ in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
                self.chatText = ""
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
                          let timestampDouble = messageDict["timestamp"] as? Double,
                          let id = UUID(uuidString: child.key) else {
                        print("Invalid or incomplete data in \(child.key)")
                        continue
                    }
                    
                    let timestamp = Date(timeIntervalSince1970: timestampDouble / 1000)
                    
                    let message = Message(id: id, text: text, timestamp: timestamp)
                    fetchedMessages.append(message)
                }
                
                self.messages = fetchedMessages.sorted { $0.timestamp < $1.timestamp }
            }
        } catch {
            print("Failed to fetch messages: \(error.localizedDescription)")
        }
    }
}
