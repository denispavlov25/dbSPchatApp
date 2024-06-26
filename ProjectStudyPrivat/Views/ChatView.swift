//
//  ChatView.swift
//  ProjectStudyPrivat
//
//  Created by Denis Pavlov on 26.06.24.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    var ticket: Ticket
    var messages = ["Message 1", "Message 2", "Message 3", "Message 4", "Message 5", "Message 6", "Message 7", "Message 8"]
    
    init(ticket: Ticket) {
        self.ticket = ticket
        _viewModel = StateObject(wrappedValue: ChatViewModel(ticket: ticket))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            ForEach(messages, id: \.self) { message in
                                Text(message)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.init(white: 0, alpha: 0.05)))
                .navigationTitle("Chat with Support")
                .navigationBarTitleDisplayMode(.inline)
                
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .padding(.leading, 10)
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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ChatView(ticket: Ticket(reference: "Example Ticket", description: "Example Description"))
}
