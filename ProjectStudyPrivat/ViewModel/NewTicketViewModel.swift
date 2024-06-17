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

class NewTicketViewModel: ObservableObject {
    @Published var shouldNavigate = false
    @Published var description = ""
    @Published var reference = ""
    @Published var appendItems: [PhotosPickerItem] = []
    @Published var appendImages: [UIImage] = []

    private let ref = Database.database().reference().child("tickets")
    private let storageRef = Storage.storage().reference().child("ticket_images")

    func saveTicket() async -> Ticket? {
        do {
            let imageURLs = try await uploadImages()
            
            // Check if image URLs are successfully uploaded
            guard !imageURLs.isEmpty || appendImages.isEmpty else {
                print("Failed to upload images")
                return nil
            }
            
            // Create the ticket
            let newTicket = Ticket(reference: reference, description: description, appendedPhotos: imageURLs)
            
            // Convert the ticket to a dictionary
            let ticketDict: [String: Any] = [
                "reference": newTicket.reference,
                "description": newTicket.description,
                "appendedPhotos": imageURLs
            ]
            
            // Save the ticket dictionary to Firebase
            try await ref.child(reference).setValue(ticketDict)
            
            return newTicket
        } catch {
            print("Error saving ticket: \(error.localizedDescription)")
            return nil
        }
    }
    
    //saving the chosen images to the firebase storage
    private func uploadImages() async throws -> [String] {
        var imageURLs: [String] = []
        
        for (index, image) in appendImages.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            let imageRef = storageRef.child("\(reference)_\(index).jpg")
            
            _ = try await imageRef.putDataAsync(imageData)
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
}