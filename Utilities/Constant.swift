//
//  Constant.swift
//  QRScanner
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class K {
    struct FS {
        static var uid: String? {
            Auth.auth().currentUser?.uid
        }
        static let COLLECTION_USERS = Firestore.firestore().collection("user")
        static var COLLECTION_PROP:  CollectionReference? {
            guard let uid = uid else { return nil}
            
            return Firestore.firestore().collection("user").document(uid).collection("props")
        }
        static var CURRENT_USER: DocumentReference? {
            guard let uid = uid else {
                return nil
            }
            
            return Firestore.firestore().collection("user").document(uid)
        }
        
    }
}


