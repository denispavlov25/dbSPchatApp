//
//  NewTicketViewModel.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 14.05.24.
//

import Foundation
import SwiftUI
import PhotosUI
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class NewTicketViewModel: ObservableObject {
    @Published var shouldNavigate = false
    @Published var description = ""
    @Published var reference = ""
    @Published var appendItems: [PhotosPickerItem] = []
    @Published var appendImages: [UIImage] = []

    private let ref: DatabaseReference
    private let storageRef = Storage.storage().reference().child("ticket_images")
    
    init() {
        guard let userID = Auth.auth().currentUser?.uid else {
            fatalError("Current user ID not found")
        }
        self.ref = Database.database().reference().child("users").child(userID).child("tickets")
    }

    func saveTicket() async -> Ticket? {
        do {
            let imageURLs = try await uploadImages()
            
            //checking if image URLs are successfully uploaded
            guard !imageURLs.isEmpty || appendImages.isEmpty else {
                print("Failed to upload images")
                return nil
            }
            
            //creating the ticket
            let newTicket = Ticket(id: UUID(), reference: reference, description: description, appendedPhotos: imageURLs)
            
            //converting the ticket to a dictionary
            let ticketDict: [String: Any] = [
                "reference": newTicket.reference,
                "description": newTicket.description,
                "appendedPhotos": imageURLs
            ]
            
            //saving the ticket dictionary to firebase
            let ticketRef = ref.child(newTicket.id.uuidString)
            try await ticketRef.setValue(ticketDict)
            
            return newTicket
        } catch {
            print("Error saving ticket: \(error.localizedDescription)")
            return nil
        }
    }
    
    //saving the chosen images to the firebase storage
    private func uploadImages() async throws -> [String] {
        //initializing an empty array to store the URLs of the uploaded images
        var imageURLs: [String] = []
        
        for (index, image) in appendImages.enumerated() {
            //converting the UIImage to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { continue }
            //creating a reference in firebase for the image with a unique name
            let imageRef = storageRef.child("\(reference)_\(index).jpg")
            
            //uploading the image data to firebase
            _ = try await imageRef.putDataAsync(imageData)
            
            //retrieving the download URL for the uploaded image
            let imageURL = try await imageRef.downloadURL()
            imageURLs.append(imageURL.absoluteString)
        }
        
        return imageURLs
    }
    
    func addImage(_ image: UIImage) {
        appendImages.append(image)
    }

    func removeImage(at index: Int) {
        appendImages.remove(at: index)
    }
    
    func validateFields() -> Bool {
        return !reference.isEmpty && !description.isEmpty
    }
}
