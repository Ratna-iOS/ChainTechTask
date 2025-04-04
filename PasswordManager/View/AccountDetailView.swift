//
//  AccountDetailView.swift
//  PasswordManager
//
//  Created by chetu on 02/04/25.
//

import SwiftUI

struct AccountDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var onEyeClick = false
    @State private var showDeleteAlert = false
    @State private var showChangesAlert = false
    @State private var accountType: String
    @State private var username: String
    @State private var password: String
    
    var account: Account
    
    init(account: Account) {
        self.account = account
        _accountType = State(initialValue: account.accountType ?? "")
        _username = State(initialValue: account.username ?? "")
        _password = State(initialValue: account.password ?? "")
    }
    
    var body: some View {
        VStack{
            HStack{
                Text("Account Details")
                    .font(.system(size: 19))
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                Spacer()
            }
            HStack{
                Text("Account Type")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                Spacer()
            }
            
            TextField("", text: $accountType)
                .fontWeight(.bold)
                .font(.system(size: 16))
                .frame(height: 40)
            
            HStack{
                Text("Username/ Email")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                Spacer()
            }
            
            TextField("", text: $username)
                .fontWeight(.bold)
                .font(.system(size: 16))
                .frame(height: 40)
            
            HStack{
                Text("Password")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                Spacer()
            }
            
            HStack {
                if onEyeClick {
                    if let decryptedPassword = EncryptionManager.decrypt(encryptedPassword: password) {
                        TextField("", text: .constant(decryptedPassword))
                    } else {
                        Text("Decryption Failed")
                    }
                } else {
                    if let decryptedPassword = EncryptionManager.decrypt(encryptedPassword: password) {
                        SecureField("", text: .constant(decryptedPassword))
                    } else {
                        Text("Decryption Failed")
                    }
                }
                Button(action: {
                    onEyeClick.toggle()
                }) {
                    Image(systemName: onEyeClick ? "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
                .fontWeight(.bold)
                .font(.system(size: 16))
                .frame(height: 40)
            }
                HStack {
                    Button {
                        showChangesAlert = true
                    } label: {
                        Text("Edit")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(.black)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding(.top, 20)
                    }.alert(isPresented: $showChangesAlert) {
                        Alert(
                            title: Text("Save Changes"),
                            message: Text("Are you sure you want to change this detail?"),
                            primaryButton: .destructive(Text("Edit")) {
                                saveChanges()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
                    Spacer()
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("Delete")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(.red)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding(.top, 20)
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Delete"),
                            message: Text("Are you sure you want to delete this account?"),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteAccount()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }.padding()

                Spacer()
            }.padding()
                .onAppear{
                    print("\(account.accountType ?? "")")
                    print("\(account.username ?? "")")
                    print("\(account.password ?? "")")
                }
        }
        private func saveChanges() {
            account.accountType = accountType
            account.username = username
            account.password = password
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Failed to save changes: \(error.localizedDescription)")
            }
        }
        
        private func deleteAccount() {
            viewContext.delete(account)
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Failed to delete account: \(error.localizedDescription)")
            }
        }
    }
