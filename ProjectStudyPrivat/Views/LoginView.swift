//
//  ContentView.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 29.04.24.
//

import SwiftUI
import PhotosUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var avatarImage: UIImage?
    @State private var avatarItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (spacing: 15) {
                    //picker for choosing sign up or log in
                    Picker(selection: $viewModel.isLoginMode, label: Text("")) {
                        Text("Log In")
                            .tag(true)
                        Text("Sign Up")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    //choosing an image for a profile
                    if !viewModel.isLoginMode {
                        PhotosPicker(selection: $avatarItem, matching: .images) {
                            Image(uiImage: (avatarImage ?? UIImage(systemName: "person.circle.fill"))!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 128, height: 128)
                                .clipShape(.circle)
                        }
                    }
                    
                    //email and passwort fields
                    Group {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            
                        SecureField("Password", text: $viewModel.password)
                    }
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button {
                        //handling the action after pressing the log in button
                        viewModel.handleActionLogin()
                    } label: {
                        HStack {
                            Spacer()
                            Text(viewModel.isLoginMode ? "Log In" : "Sign Up")
                                .foregroundStyle(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                }
                .padding()
                //handling alert messages
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage),
                          dismissButton: .default(Text("OK")))
                }
                //handling PhotosPicker
                .onChange(of: avatarItem) { _, _ in
                    Task {
                        if let avatarItem,
                           //loading data asynchronously from avatarItem
                           let data = try? await avatarItem.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                //if data successfully loaded, assigning it to avatarImage
                                avatarImage = image
                                //converting the image to JPEG data
                                viewModel.avatarImageData = image.jpegData(compressionQuality: 0.4)
                            }
                        }
                        //clear avatarItem
                        avatarItem = nil
                    }
                }
            }
            .navigationTitle(viewModel.isLoginMode ? "Log In" : "Sign Up")
            .background(Color(.init(white: 0, alpha: 0.05)))
            //navigating to the OpenTicketsView
            .navigationDestination(isPresented: $viewModel.shouldNavigate) {
                OpenTicketsView()
            }
            
        }
    }
}

#Preview {
    LoginView()
}
