//
//  Ticket.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 17.05.24.
//

import Foundation

struct Ticket: Identifiable {
    var id: UUID
    var reference: String
    var description: String
    var appendedPhotos: [String]?
    
    init(id: UUID, reference: String, description: String, appendedPhotos: [String]? = nil) {
        self.id = id
        self.reference = reference
        self.description = description
        self.appendedPhotos = appendedPhotos
    }
}
