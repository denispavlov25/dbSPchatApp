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
    @State private var isSheetPresented = false
    
    var ticket: Ticket
    var isSupportAccount: Bool
    
    init(ticket: Ticket, isSupportAccount: Bool) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(ticket: ticket, isSupportAccount: isSupportAccount))
        self.ticket = ticket
        self.isSupportAccount = isSupportAccount
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 10) {
                            ForEach(viewModel.messages) { message in
                                if let imageURLs = message.appendedImages, !imageURLs.isEmpty {
                                    ForEach(imageURLs, id: \.self) { url in
                                        Button(action: {
                                            viewModel.openImage(url)
                                            isSheetPresented = true
                                        }) {
                                            Text("Open Image")
                                                .foregroundColor(.blue)
                                                .padding()
                                                .background(Color.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                                if !message.text.isEmpty {
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
                        if viewModel.isUploadingImages {
                            ProgressView()
                        } else {
                            Text("Send")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
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
        .sheet(isPresented: $isSheetPresented, onDismiss: {
            viewModel.closeImageFullScreen()
        }, content: {
            NavigationStack {
                VStack {
                    if let imageURL = URL(string: viewModel.selectedImageURL) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isSheetPresented = false
                        }) {
                            Text("Close")
                        }
                    }
                }
            }
        })
    }
}

#Preview {
    ChatView(ticket: Ticket(id: UUID(), reference: "Example Ticket", description: "Example Description"), isSupportAccount: true)
}
