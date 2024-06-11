//
//  TicketDetailsView.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 16.05.24.
//

import SwiftUI

struct TicketDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var ticket: Ticket

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    DetailField(title: "Reference", content: ticket.reference)
                    DetailField(title: "Description", content: ticket.description)
                    
                    // showing append photos
                    if let photos = ticket.appendedPhotos {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(photos.indices, id: \.self) { index in
                                    Image(uiImage: UIImage(data: photos[index]) ?? UIImage())
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 110, height: 110)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 0.3)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Ticket Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .background(Color(.init(white: 0, alpha: 0.05)))
        }
    }
}

// reference and description
struct DetailField: View {
    var title: String
    var content: String

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
            VStack(alignment: .leading) {
                Text(title)
                    .underline(true, color: .black)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding([.top, .leading], 10)
                    .padding(.bottom, 5)
                Text(content)
                    .font(.body)
                    .padding([.leading, .bottom], 10)
            }
            .padding(8)
        }
        .frame(minHeight: 80, alignment: .leading)
    }
}

#Preview {
    TicketDetailsView(ticket: Ticket(reference: "Example Ticket", description: "Example Description"))
}
