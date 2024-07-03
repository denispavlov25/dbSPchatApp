//
//  ChatView.swift
//  ProjectStudyPrivat
//
//  Created by Denis Pavlov on 26.06.24.
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    var ticket: Ticket
    
    init(ticket: Ticket) {
        self.ticket = ticket
        _viewModel = StateObject(wrappedValue: ChatViewModel(ticket: ticket))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 10) {
                            ForEach(viewModel.messages) { message in
                                if let imageURLs = message.appendedImages {
                                    ForEach(imageURLs, id: \.self) { url in
                                        if let imageURL = URL(string: url) {
                                            AsyncImage(url: imageURL) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 80, height: 80)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        }
                                    }
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.init(white: 0, alpha: 0.05)))
                .navigationTitle("Chat with Support")
                .navigationBarTitleDisplayMode(.inline)
                
                HStack {
                    PhotosPicker(selection: $viewModel.appendItems) {
                        Image(systemName: "paperclip")
                            .padding(.leading, 10)
                    }
                    ZStack(alignment: .leading) {
                        Text("Message")
                            .padding(.leading, 5)
                        TextEditor(text: $viewModel.chatText)
                            .opacity(viewModel.chatText.isEmpty ? 0.5 : 1)
                    }
                    .frame(height: 40)
                    Button(action: {
                        viewModel.handleSend()
                    }) {
                        Text("Send")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding()
                }
                
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.appendImages.indices, id: \.self) { index in
                            Button(action: {
                                viewModel.removeImage(at: index)
                            }) {
                                Image(uiImage: viewModel.appendImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchMessages()
            }
        }
        .onChange(of: viewModel.appendItems) { newItems, _ in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            viewModel.addImage(image)
                        }
                    }
                }
                viewModel.appendItems.removeAll()
            }
        }
    }
}

#Preview {
    ChatView(ticket: Ticket(id: UUID(), reference: "Example Ticket", description: "Example Description"))
}
