//
//  Prop+CoreDataProperties.swift.swift


import Foundation
import CoreData
import UIKit


extension Prop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prop> {
        return NSFetchRequest<Prop>(entityName: "Prop")
    }

    @NSManaged public var isCompleted: Bool
    @NSManaged public var title: String?
    @NSManaged public var uuid: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var foregroundImage: UIImage?
    @NSManaged public var backgroundImage: UIImage?
    @NSManaged public var foregroundVideo: URL?
    @NSManaged public var backgroundVideo: URL?

}

extension Prop : Identifiable {
    static func getProps() -> [Prop] {
        let fetchRequest: NSFetchRequest = Prop.fetchRequest()
        
        do {
            return try CoreDataManager.shared.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
}
