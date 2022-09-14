//
//  User.swift
//  QRScanner
//

import Foundation
import FirebaseFirestoreSwift

class User: InitializableGeneric, Codable {
    let name: String
    let email: String
    let isAgreeConsent: Bool
    
    required init(dict: [String : Any]) {
        self.name = dict["name"] as? String ?? ""
        self.isAgreeConsent = dict["isAgreeConsent"] as? Bool ?? false
        self.email = dict["email"] as? String ?? ""
    }
}

class UserModel {
    static func retrieveUser() -> User? {
        guard let userData = Preferences.shared.user.value else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(User.self, from: userData)
    }
}
