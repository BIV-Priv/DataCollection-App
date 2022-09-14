//
//  Preferences.swift
//  QRScanner
//

import Foundation
class Preference<T: Decodable> {
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    var value: T? {
        get {
            UserDefaults.standard.value(forKey: key) as? T
        } set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

extension Preference {
    func save<U>(object: U) throws where U: Codable {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(object)
            self.value = encoded as? T
        } catch {
            throw error
        }
    }
    
    func destroyself() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

class Preferences {
    
    static let shared = Preferences()
    private init() { }
    
    let isLoggedIn = Preference<Bool>(key: "isLoggedIn")
    let user = Preference<Data>(key: "user")
    let isChoosedPropEver = Preference<Bool>(key: "isChoosedPropEver")
    let isUsingAppFirstTime = Preference<Bool>(key: "isUsingAppFirstTime")
}
