//
//  NewTicketView.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 14.05.24.
//

import SwiftUI
import PhotosUI

struct NewTicketView: View {
    @StateObject private var viewModel = NewTicketViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false
    @State private var showEmptyFieldsAlert = false
    
    var openTicketsViewModel: OpenTicketsViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                TextField("Reference", text: $viewModel.reference)
                    .lineLimit(15)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 15)
                
                TextField("Description", text: $viewModel.description, axis: .vertical)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 30)
                
                //adding photos
                HStack {
                    Image(systemName: "paperclip")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15, height:15)
                    PhotosPicker("Append Photos", selection: $viewModel.appendItems, maxSelectionCount: 5, selectionBehavior: .ordered)
                }
                
                Spacer()
                
                //multiple choosing of photos
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.appendImages.indices, id: \.self) { index in
                            //removing photos by clicking on them
                            Button(action: {
                                viewModel.removeImage(at: index)
                            }) {
                                Image(uiImage: viewModel.appendImages[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 110, height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        //applying a stroke (border) to the rounded rectangle with a black color and a line as an overlay
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 0.3)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(20)
            .navigationTitle("Create a new ticket")
            .onChange(of: viewModel.appendItems) { _, _ in
                Task {
                    for item in viewModel.appendItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                viewModel.addImage(image)
                            }
                        }
                    }
                    viewModel.appendItems.removeAll()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    //showing a loading image if the photos are not yet saved in the database
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                if viewModel.validateFields() {
                                    isSaving = true
                                    if let newTicket = await viewModel.saveTicket() {
                                        openTicketsViewModel.addTicket(newTicket)
                                        dismiss()
                                    }
                                    isSaving = false
                                } else {
                                    showEmptyFieldsAlert = true
                                }
                            }
                        }
                        .alert(isPresented: $showEmptyFieldsAlert) {
                            Alert(title: Text("Empty Fields"), message: Text("Please fill out both 'Reference' and 'Description' fields."), dismissButton: .default(Text("OK")))
                        }
                    }
                }
            }
            .padding(.top, 20)
            .background(Color(.init(white: 0, alpha: 0.05)))
        }
    }
}

#Preview {
    NewTicketView(openTicketsViewModel: OpenTicketsViewModel())
}
