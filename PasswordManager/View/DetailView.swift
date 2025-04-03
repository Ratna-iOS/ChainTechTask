//
//  DetailView.swift
//  PasswordManager
//
//  Created by chetu on 02/04/25.
//

import SwiftUI

struct DetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var alertManager = AlertManager.shared
    @State private var accountName = ""
    @State private var userName = ""
    @State private var password = ""
    @State private var passwordStrength: PasswordStrength = .empty
    
    var body: some View {
        VStack(spacing: 20){
            TextField("Account Name", text: $accountName)
                .frame(height: 40)
                .padding(.leading, 5)
                .border(.gray, width: 1)
                .padding(.top, 50)

            TextField("UserName/Email", text: $userName)
                .frame(height: 40)
                .padding(.leading, 5)
                .border(.gray, width: 1)
                
            SecureField("Password", text: $password)
                .frame(height: 40)
                .padding(.leading, 5)
                .border(.gray, width: 1)
                
                .onChange(of: password) { _, newValue in
                    passwordStrength = evaluatePasswordStrength(newValue)
                }
            
            VStack(alignment: .leading) {
                Text("Password Strength: \(passwordStrength.rawValue)")
                    .font(.caption)
                    .foregroundColor(passwordStrength.color)
                
                ProgressView(value: Double(passwordStrength.level) / 3.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: passwordStrength.color))
                    .frame(height: 8)
                    .cornerRadius(4)
            }
            Button {
                handleAddAccount()
            } label: {
                Text("Add New Account")
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.top, 20)
            }.alert(alertManager.title, isPresented: $alertManager.isPresented) {
                Button("OK") {
                    alertManager.completion?()
                }
            } message: {
                Text(alertManager.message)
            }
            Spacer()
        }.padding()
        
    }
    private func handleAddAccount() {
        if accountName.isEmpty {
            alertManager.showAlert(title: "Warning", message: "Please enter an Account Name.")
        } else if userName.isEmpty {
            alertManager.showAlert(title: "Warning", message: "Please enter a Username.")
        } else if !isValidUsername(userName) {
            alertManager.showAlert(title: "Invalid Username", message: "Username must be 4-20 characters, can include letters, numbers, dots (.), and underscores (_), but cannot start or end with them.")
        } else if password.isEmpty {
            alertManager.showAlert(title: "Warning", message: "Please enter a password.")
        } else if passwordStrength == .weak {
            alertManager.showAlert(title: "Invalid Password", message: "Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character.")
        } else {
            addAccount()
        }
    }
    
    func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&#]).{8,}$"
        let strengthScore = NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password) ? 4 :
        [password.count >= 8,
         password.rangeOfCharacter(from: .decimalDigits) != nil,
         password.rangeOfCharacter(from: .uppercaseLetters) != nil,
         password.rangeOfCharacter(from: CharacterSet.punctuationCharacters) != nil]
            .filter { $0 }.count
        return strengthScore >= 4 ? .strong : strengthScore >= 2 ? .medium : .weak
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let usernameRegex = "^(?!.*[_.]{2})(?![_.])[A-Za-z0-9._]{4,20}(?<![_.])$"
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: username)
    }
    
    private func addAccount() {
        let newAccount = Account(context: viewContext)
        newAccount.accountType = accountName
        newAccount.username = userName
        newAccount.password = password
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save: \(error.localizedDescription)")
        }
    }
    enum PasswordStrength: String {
        case empty = "", weak = "Weak", medium = "Medium", strong = "Strong"
        
        var color: Color {
            switch self {
            case .empty: return .white
            case .weak: return .red
            case .medium: return .orange
            case .strong: return .green
            }
        }
        var level: Int {
            switch self {
            case .empty: return 0
            case .weak: return 1
            case .medium: return 2
            case .strong: return 3
            }
        }
    }
}
