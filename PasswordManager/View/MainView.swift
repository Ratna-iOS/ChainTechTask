//
//  ContentView.swift
//  PasswordManager
//
//  Created by chetu on 02/04/25.
//

import SwiftUI

struct MainView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.accountType, ascending: true)]
    ) private var userDetail: FetchedResults<Account>
    
    @State private var isShowingDetailView = false
    @State private var isShowingAccountDetailView = false
    @State private var selectedAccount: Account? 
    
    var body: some View {
        ZStack{
            VStack {
                HStack{
                    Text("Password Manager")
                        .font(.system(size: 21))
                        .fontWeight(.bold)
                    Spacer()
                }
                
                List{
                    ForEach(userDetail, id: \.self) { entry in
                        
                        HStack {
                            Text("\(entry.accountType ?? "Unknown")")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                            Text(String(repeating: "•", count: entry.password?.count ?? 0))
                                .foregroundColor(.gray)
                            Spacer()
                          
                                
                            Image(systemName: "chevron.forward")
                                .foregroundColor(.black)
                                .onTapGesture {
                                    selectedAccount = entry
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isShowingAccountDetailView = true
                                    }
                                }
                        }
                    }
                    .padding() 
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(radius: 3)
                           
                }
                .listRowSeparator(.hidden)
                .listStyle(.plain)
                
                .sheet(isPresented: Binding(
                        get: { isShowingAccountDetailView && selectedAccount != nil },
                        set: { isShowingAccountDetailView = $0 }
                    )) {
                        if let account = selectedAccount {
                            AccountDetailView(account: account)
                                .presentationDetents([.height(480), .large])
                                .onAppear {
                                    print("Sheet opened with account: \(account)")
                                }
                        }
                    }
                HStack{
                    Spacer()
                    Button {
                        isShowingDetailView = true
                    } label: {
                        Image(systemName: "plus.app.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .sheet(isPresented: $isShowingDetailView) {
                        DetailView()
                            .presentationDetents([.height(420), .medium, .large])
                            .presentationDragIndicator(.automatic)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    MainView()
}
