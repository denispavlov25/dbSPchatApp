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

class NewTicketViewModel: ObservableObject {
    @Published var shouldNavigate = false
    @Published var description = ""
    @Published var reference = ""
    @Published var appendItems: [PhotosPickerItem] = []
    @Published var appendImages: [UIImage] = []
    
    private let ref = Database.database().reference().child("tickets")

    func saveTicket() -> Ticket {
        // saving the image array
        let imageDataArray = appendImages.compactMap { $0.pngData() }
        let newTicket = Ticket(reference: reference, description: description, appendedPhotos: imageDataArray)
        // Convert the ticket to a dictionary
        let ticketDict: [String: Any] = [
            "reference": newTicket.reference,
            "description": newTicket.description,
            // handle the image data separately
        ]
        
        ref.child(reference).setValue(ticketDict)
        return newTicket
    }
    
    func addImage(_ image: UIImage) {
        appendImages.append(image)
    }

    func removeImage(at index: Int) {
        appendImages.remove(at: index)
    }
}
