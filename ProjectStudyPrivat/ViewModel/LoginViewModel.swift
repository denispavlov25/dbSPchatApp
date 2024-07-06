//
//  LoginViewModel.swift
//  dbSupportChatApp
//
//  Created by Denis Pavlov on 02.05.24.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LoginViewModel: ObservableObject {
    @Published var isLoginMode = false
    @Published var email = ""
    @Published var password = ""
    @Published var avatarImageData: Data?
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var shouldNavigate = false
    @Published var isSupportAccount = false
    
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
                return
            }
            
            guard let user = result?.user else {
                self.getAlertMessage(withTitle: "Error", message: "User data is missing", showAlert: true)
                return
            }
            
            let userID = user.uid
            let database = Database.database().reference().child("users")
            
            database.child("supportAccount").child(userID).observeSingleEvent(of: .value) { supportSnapshot in
                if supportSnapshot.exists() {
                    self.shouldNavigate = true
                    self.isSupportAccount = true
                } else {
                    database.child("regularAccounts").child(userID).observeSingleEvent(of: .value) { regularSnapshot in
                        if regularSnapshot.exists() {
                            self.shouldNavigate = true
                            self.isSupportAccount = false
                        } else {
                            self.getAlertMessage(withTitle: "Error", message: "Account type cannot be determined", showAlert: true)
                        }
                    }
                }
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
            
            var userRef: DatabaseReference
            
            if self.isSupportAccount {
                userRef = Database.database().reference().child("users").child("supportAccount").child(user.uid)
            } else {
                userRef = Database.database().reference().child("users").child("regularAccounts").child(user.uid)
            }
            userRef.setValue(self.isSupportAccount)
            
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
