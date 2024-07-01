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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    DetailField(title: "Reference", content: ticket.reference)
                    DetailField(title: "Description", content: ticket.description)
                    
                    //showing append photos
                    if let photos = ticket.appendedPhotos {
                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(photos, id: \.self) { photoURL in
                                    if let url = URL(string: photoURL) {
                                        //using AsyncImage to load images asynchronously
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            //when image loading has not started
                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 110, height: 110)
                                                    .background(Color.gray.opacity(0.1))
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            
                                            //when image loading succeeds
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 110, height: 110)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.black, lineWidth: 0.3)
                                                    )
                                            
                                            //when image loading fails
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 110, height: 110)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(Color.black, lineWidth: 0.3)
                                                    )
                                            
                                            //default case for any unknown phase
                                            default:
                                                EmptyView()
                                            }
                                        }
                                    }
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

//reference and description fields
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
    TicketDetailsView(ticket: Ticket(id: UUID(), reference: "Example Ticket", description: "Example Description"))
}
