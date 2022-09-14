//
//  LoginViewModel.swift
//  QRScanner
//

import Foundation
import AATools
import FirebaseAuth
import FirebaseFirestoreSwift


typealias FIRESTORE_COMPLETION = (Error?) -> ()

class LoginViewModel {
    
    var bindableIsSigningIn = Bindable<Bool>()
    var bindableIsFormValid = Bindable<Bool>()
    
    @Trimmed var id: String? { didSet { checkForValidity() } }
    
    private func checkForValidity() {
        let isFormValid = id?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
    
    func performLogin(completion: @escaping FIRESTORE_COMPLETION) {
        guard let id = id else { return }
        
        bindableIsSigningIn.value = true
        Auth.auth().signIn(withEmail: id + "@gmail.com", password: "VizPriv") { _, error in
            if let error = error {
                completion(error)
                return
            }
            
            self.fetchAndSaveUser(completion: completion)
        }
    }
    
    func fetchAndSaveUser(completion: @escaping FIRESTORE_COMPLETION) {
        guard let docRef = K.FS.CURRENT_USER else {
            completion(AppError.firebaseUserDataNotFound)
            return
        }
        
        FetchData.shared.fetchData(source: .default, withDocumentRef: docRef) { (user: User?, error) in
            
            if let error = error {
                Debug.log(message: "error", variable: error.localizedDescription)
                completion(error)
                return
            }
            
            guard let user = user else {
                completion(AppError.firebaseUserDataNotFound)
                return
            }

            do {
                try Preferences.shared.user.save(object: user)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
}
