//
//  LoginViewModel.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 02.05.24.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

class LoginViewModel: ObservableObject {
    @Published var isLoginMode = false
    @Published var email = ""
    @Published var password = ""
    @Published var avatarImageData: Data?
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var shouldNavigate = false
    
    func handleActionLogin() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.getAlertMessage(withTitle: "Error", message: "Login failed: \(error.localizedDescription)", showAlert: true)
            } else if let user = result?.user {
                self.shouldNavigate = true
                print("Successfully logged in as user: \(user.uid)")
            }
        }
    }

    func createNewAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to create user: \(error)")
                self.getAlertMessage(withTitle: "Error", message: "Account creation failed: \(error.localizedDescription)", showAlert: true)
                return
            }
            guard let user = result?.user else { return }
            print("Successfully created user: \(user.uid)")
            
            self.getAlertMessage(withTitle: "Account created successfully", message: "Now you can log into your account!", showAlert: true)
            
            if let imageData = self.avatarImageData {
                self.uploadImageToStorage(uid: user.uid, imageData: imageData)
            }
        }
    }

    //saving the chosen image to the firebase storage
    private func uploadImageToStorage(uid: String, imageData: Data) {
        let storageRef = Storage.storage().reference(withPath: "/avatars/\(uid)")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading avatar image: \(error)")
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting avatar image URL: \(error)")
                    return
                }
                if let url = url {
                    print("Successfully uploaded avatar image to URL: \(url)")
                }
            }
        }
    }
    
    private func getAlertMessage(withTitle title: String, message: String, showAlert: Bool) {
        DispatchQueue.main.async {
            self.alertTitle = title
            self.alertMessage = message
            self.showAlert = showAlert
        }
    }
}
