//
//  RegistrationViewModel.swift
//  QRScanner
//

import Foundation
import AATools
import FirebaseAuth
import FirebaseFirestore

class RegistrationViewModel {
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsRegistring = Bindable<Bool>()
    var bindableIsAgreeConsent = Bindable<Bool>()
    
    @Trimmed var name: String? { didSet { checkForValidity() }}
    @Trimmed var id: String? { didSet { checkForValidity() }}
    
    var isAgreeConsent: Bool = false {
        didSet {
            checkForValidity()
            bindableIsAgreeConsent.value = isAgreeConsent
        }
    }
    
    private func checkForValidity() {
        let isFormValid = id?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
    
    func performRegister(completion: @escaping FIRESTORE_COMPLETION) {
        guard let id = id
        else {
                  return
        }
        
        bindableIsRegistring.value = true
        Auth.auth().createUser(withEmail: id + "@gmail.com", password: "VizPriv") { _, error in
            
            if let error = error {
                completion(error)
                return
            }
            
            self.saveUserToFirestore(completion: completion)
        }
    }
    
    private func saveUserToFirestore(completion: @escaping FIRESTORE_COMPLETION) {
        guard let uid = K.FS.uid else { return }
        
        let data: [String: Any] = [
            "email": id ?? "",
            "name": name ?? "",
            "isAgreeConsent": isAgreeConsent
        ]
        
        K.FS.COLLECTION_USERS.document(uid).setData(data, completion: completion)
    }
}
