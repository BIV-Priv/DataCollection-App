//
//  FetchData.swift
//  QRScanner


import Foundation

import FirebaseFirestore
import FirebaseAuth
import AATools

import UIKit

protocol InitializableGeneric {
    init(dict: [String: Any])
}

class CustomErrors: NSObject, LocalizedError {
    var desc = ""
    init(desc: String) {
        self.desc = desc
    }
    
    override var description: String {
        get {
            return "Database error: \(desc)"
        }
    }
    
     var errorDescription: String? {
        get {
            return self.description
        }
    }
}

enum FirebaseErrors: Error {
    case dataDoesNotExists
}

extension FirebaseErrors: LocalizedError {
    
    public var localizedDescription: String? {
        switch self {
        case .dataDoesNotExists:
            return NSLocalizedString("The requested data is not available.", comment: "Data not found")
        }
        
    }
}

class FetchData {
    static let shared = FetchData()
    
    func fetchData<T: Codable>(fromSource source: FirestoreSource = .default,
                               withDocument document: DocumentReference?=nil,
                               query: Query?=nil,
                               completion: @escaping (T?, Error?) -> ()
    ) {
        if query == nil {
            document?.getDocument(source: source, completion: { document, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let doc = document else {
                    completion(nil, AppError.firebaseCollectionsDocumentNotFound)
                    return
                }
                
                do {
                    let fetchedDoc = try doc.data(as: T.self)
                    completion(fetchedDoc, nil)
                } catch {
                    completion(nil, error)
                }
                
            })
        }
    }
    
    func fetchData<T: Codable>(fromSource source: FirestoreSource = .default,
                               withCollection collection: CollectionReference?=nil,
                               query: Query?=nil,
                               completion: @escaping ([T]?, Error?) -> ()
    ) {
        if query == nil {
            collection?.getDocuments(source: source, completion: { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion(nil, AppError.firebaseCollectionsDocumentNotFound)
                    return
                }
                
                
                do {
                    let fetchedData = try docs.map({
                        try $0.data(as: T.self)
                    })
                    completion(fetchedData, nil)
                } catch {
                    completion(nil, error)
                    return
                }
            })
        }
    }
    
    func fetchData<T: InitializableGeneric>(source: FirestoreSource = .default, withDocumentRef documentRef: DocumentReference?=nil, completion: @escaping (T?, Error?) -> ()) {
        
        documentRef?.getDocument(source: source, completion: { (snapshot, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = snapshot?.data() else {
                completion(nil, nil)
                return
            }
            
            let fetchedData = T(dict: data)
            completion(fetchedData ,nil)
        })
    }
    
    func fetchData<T: InitializableGeneric>(source: FirestoreSource = .default, withCollectionRef collectionRef: CollectionReference?=nil, query: Query?=nil, completion: @escaping ([T]?, Error?) -> ()) {
        
        if query == nil {
            collectionRef?.getDocuments(source: source, completion: { (snapshot, error) in
                
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    return
                }
                
                let fetchedData = docs.map({ T(dict: $0.data())})
                completion(fetchedData ,nil)
            })
        } else {
            Debug.log(message: "get query", variable: nil)
            query?.getDocuments(source: source, completion: { (snapshot, error) in
                
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    return
                }
                
                let fetchedData = docs.map({T(dict: $0.data())})
                completion(fetchedData ,nil)
            })
        }
    }
}
