//
//  ChatViewModel.swift
//  ProjectStudyPrivat
//
//  Created by Denis Pavlov on 26.06.24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import PhotosUI
import SwiftUI
import FirebaseStorage

class ChatViewModel: ObservableObject {
    @Published var chatText = ""
    @Published var messages: [Message] = []
    @Published var appendImages: [UIImage] = []
    @Published var appendItems: [PhotosPickerItem] = []
    
    private let ticket: Ticket
    private let ref: DatabaseReference
    private let storageRef: StorageReference
    
    init(ticket: Ticket) {
        self.ticket = ticket

        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("Current user ID not found")
        }
        self.ref = Database.database().reference().child("users").child(userID).child("tickets").child(ticket.id.uuidString).child("messages")
        self.storageRef = Storage.storage().reference().child("ticket_images")
    }
    
    func handleSend() {
        //ensuring the chatText is not empty
        guard !chatText.isEmpty || !appendImages.isEmpty else { return }
        
        //generating a unique id
        let messageId = UUID().uuidString
        //get standard timestamp
        let unixTimestamp = Date().timeIntervalSince1970
        //creating a dictionary containing the message data
        
        if !appendImages.isEmpty {
            Task {
                do {
                    let imageUrls = try await uploadImages(messageId: messageId)
                    let messageDict: [String: Any] = [
                        "text": chatText,
                        "timestamp": unixTimestamp,
                        "appendedImages": imageUrls
                    ]
                    
                    sendMessage(messageId: messageId, messageDict: messageDict)
                } catch {
                    print("Error uploading images: \(error.localizedDescription)")
                }
            }
        } else {
            let messageDict: [String: Any] = [
                "text": chatText,
                "timestamp": unixTimestamp
            ]
            sendMessage(messageId: messageId, messageDict: messageDict)
        }
    }
        
    private func sendMessage(messageId: String, messageDict: [String: Any]) {
        //reference to the specific message
        let messageRef = ref.child(messageId)
        
        //set the message data to the firebase
        messageRef.setValue(messageDict) { error, _ in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully!")
                //clear chatText and appendImages after sending message
                self.chatText = ""
                self.appendImages.removeAll()
                
                //fetching updated messages asynchronously on the ui
                Task {
                    await self.fetchMessages()
                }
            }
        }
    }
    
    private func uploadImages(messageId: String) async throws -> [String] {
        var imageURLs: [String] = []
        
        for (index, image) in appendImages.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            let imageRef = self.storageRef.child("\(ticket.id.uuidString)_\(index).jpg")
            
            do {
                _ = try await imageRef.putDataAsync(imageData)
                
                let imageURL = try await imageRef.downloadURL()
                imageURLs.append(imageURL.absoluteString)
            } catch {
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
        
        return imageURLs
    }
    
    func addImage(_ image: UIImage) {
        appendImages.append(image)
    }
    
    func removeImage(at index: Int) {
        appendImages.remove(at: index)
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
                    
                    let appendedImages = messageDict["appendedImages"] as? [String]

                    if let messageId = UUID(uuidString: child.key) {
                        let message = Message(id: messageId, text: text, timestamp: timestamp, appendedImages: appendedImages)
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
