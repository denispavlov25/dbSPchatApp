//
//  Message.swift
//  ProjectStudyPrivat
//
//  Created by Denis Pavlov on 27.06.24.
//

import Foundation

struct Message: Identifiable {
    var id: UUID
    var text: String
    var timestamp: Double
    var appendedImages: [String]?
    var isSupportMessage: Bool
}
