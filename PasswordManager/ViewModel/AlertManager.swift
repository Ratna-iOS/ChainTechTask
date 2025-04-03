import SwiftUI

class AlertManager: ObservableObject {
    @Published var isPresented: Bool = false
    var title: String = "Alert!"
    var message: String = ""
    var completion: (() -> Void)?

    static let shared = AlertManager()

    private init() {}
    func showAlert(title: String = "Alert!", message: String, completion: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.completion = completion
        self.isPresented = true
    }
}
