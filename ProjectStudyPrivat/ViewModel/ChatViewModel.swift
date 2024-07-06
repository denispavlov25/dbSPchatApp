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
    @Published var isImageFullScreenPresented = false
    @Published var selectedImageURL: String = ""
    @Published var isUploadingImages = false
    
    private let ticket: Ticket
    private let ref: DatabaseReference
    private let storageRef: StorageReference
    var isSupportAccount: Bool
    
    init(ticket: Ticket, isSupportAccount: Bool) {
        self.ticket = ticket
        self.isSupportAccount = isSupportAccount
        
        if isSupportAccount {
            self.ref = Database.database().reference().child("users").child("regularAccounts")
        } else {
            guard let userID = Auth.auth().currentUser?.uid else {
                fatalError("Current user ID not found")
            }
            self.ref = Database.database().reference().child("users").child("regularAccounts").child(userID).child("tickets").child(ticket.id.uuidString).child("messages")
        }
        
        self.storageRef = Storage.storage().reference().child("ticket_images")
    }
    
    func handleSend() {
        //ensuring the chatText is not empty
        guard !chatText.isEmpty || !appendImages.isEmpty else { return }
        
        //generating a unique id
        let messageId = UUID().uuidString
        //get standard timestamp
        let unixTimestamp = Date().timeIntervalSince1970
        
        //setting flag to indicate image upload in progress
        isUploadingImages = true
        
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
                    self.isUploadingImages = false
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
            self.isUploadingImages = false
        }
    }
    
    private func uploadImages(messageId: String) async throws -> [String] {
        var imageURLs: [String] = []
        
        for (_, image) in appendImages.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { continue }
            
            let uniqueImageId = UUID().uuidString
            let imageRef = self.storageRef.child("\(ticket.id.uuidString)_\(messageId)_\(uniqueImageId).jpg")
            
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
                
                if self.isSupportAccount {
                    //iterating through users
                    for userSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                        let ticketsSnapshot = userSnapshot.childSnapshot(forPath: "tickets")
                        
                        //iterating through tickets
                        for ticketSnapshot in ticketsSnapshot.children.allObjects as! [DataSnapshot] {
                            let ticketId = ticketSnapshot.key
                            
                            //checking if the ticket id matches the current ticket
                            if ticketId == self.ticket.id.uuidString {
                                let messagesSnapshot = ticketSnapshot.childSnapshot(forPath: "messages")
                                
                                //iterating through messages
                                for messageSnapshot in messagesSnapshot.children.allObjects as! [DataSnapshot] {
                                    if let message = self.parseMessage(snapshot: messageSnapshot) {
                                        fetchedMessages.append(message)
                                    } else {
                                        print("Failed to parse message snapshot: \(messageSnapshot.key)")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    //fetching messages for regular user
                    for messageSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                        if let message = self.parseMessage(snapshot: messageSnapshot) {
                            fetchedMessages.append(message)
                        } else {
                            print("Failed to parse message snapshot: \(messageSnapshot.key)")
                        }
                    }
                }
                
                self.messages = fetchedMessages.sorted { $0.timestamp < $1.timestamp }
            }
        } catch {
            print("Failed to fetch messages: \(error.localizedDescription)")
        }
    }

    private func parseMessage(snapshot: DataSnapshot) -> Message? {
        guard let messageDict = snapshot.value as? [String: Any],
              let text = messageDict["text"] as? String,
              let timestamp = messageDict["timestamp"] as? Double else {
            return nil
        }

        let appendedImages = messageDict["appendedImages"] as? [String]

        if let messageId = UUID(uuidString: snapshot.key) {
            return Message(id: messageId, text: text, timestamp: timestamp, appendedImages: appendedImages)
        } else {
            print("Invalid UUID string: \(snapshot.key)")
            return nil
        }
    }
    
    func openImage(_ imageURL: String) {
        selectedImageURL = imageURL
        isImageFullScreenPresented = true
    }

    func closeImageFullScreen() {
        isImageFullScreenPresented = false
        selectedImageURL = ""
    }
}
