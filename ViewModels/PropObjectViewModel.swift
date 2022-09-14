//
//  PropViewModel.swift
//  QRScanner
//

import Foundation
import CoreData
import AATools
import UIKit

class PropObjectsViewModel {
    
    func getAllProps() -> [PropViewModel] {
        var props = Prop.getProps().map(PropViewModel.init)
        props.sort(by: { $0.publishedAt.timeIntervalSince1970 > $1.publishedAt.timeIntervalSince1970})
        return props
    }
    
    func deleteProp(prop: PropViewModel) {
        
        if let foregroundVideoUrl = prop.foregroundVideo {
            try? FileManager.default.removeItem(at: foregroundVideoUrl)
        }
        
        if let backgroundVideoUrl = prop.backgroundVideo {
            try? FileManager.default.removeItem(at: backgroundVideoUrl)
        }
        
        let manager = CoreDataManager.shared
        manager.delete(prop.prop)
    }
}

struct PropViewModel {
    
    let prop: Prop
    
    var id: NSManagedObjectID {
        prop.objectID
    }
    
    var title: String {
        prop.title ?? ""
    }
    
    var isCompleted: Bool {
        prop.isCompleted
    }
    
    var publishedAt: Date {
        prop.publishedAt ?? Date()
    }
    
    var foregroundImage: UIImage? {
        prop.foregroundImage
    }
    
    var backgroundImage: UIImage? {
        prop.backgroundImage
    }
    
    var foregroundVideo: URL? {
        prop.foregroundVideo
    }
    
    var backgroundVideo: URL? {
        prop.backgroundVideo
    }
}
