//
//  ImageViewModel.swift
//  QRScanner
//

import Foundation
import UIKit
import AATools
import FirebaseStorage

class ImageViewModel {
    
    enum ImageTypeUrl: String {
        case forgroundImageUrl = "forgroundImageUrl"
        case backgroundImageUrl = "backgroundImageUrl"
    }
    var bindableIsBothImagesCaptured = Bindable<Bool>()
    var bindableShouldBackgroundTextAsLabel = Bindable<Bool>()
    var bindableUploadingFileWithPercentage = Bindable<Double>()
    var bindableIsUploadingFile = Bindable<Bool>()
    var bindableIsSavingLinks = Bindable<Bool>()
    
    var prop: PropViewModel?
    private var progress = 0.0
    var images = [UIImage]() {
        didSet {
            if images.count == 1 {
                bindableShouldBackgroundTextAsLabel.value = true
            } else if images.count == 2 {
                bindableIsBothImagesCaptured.value = true
            }
        }
    }
    
    func saveImages() {
        guard let propModel = prop else { return }
        
        let prop = propModel.prop
        prop.foregroundImage = images[0]
        prop.backgroundImage = images[1]
        
        CoreDataManager.shared.save()
    }
    
    func uploadImage(completion: @escaping FIRESTORE_COMPLETION) {
        guard let user = UserModel.retrieveUser() else { return }
        guard let uid = K.FS.uid else { return }
        guard let propModel = prop else { return }
        
        let foreground = propModel.title + "-foreground" + "-" + UUID().uuidString + ".jpeg"
        let background = propModel.title + "-background" + "-" + UUID().uuidString + ".jpeg"
        let refString = user.name + "-" + uid
        
        let group = DispatchGroup()
        
        let uploadForegroundImageOperation = BlockOperation()
        uploadForegroundImageOperation.addExecutionBlock {
            group.enter()
            let ref = Storage.storage().reference().child(refString + "/images/\(foreground)")
            let imageData = self.images[0].jpegData(compressionQuality: 1) ?? Data()
            self.bindableIsUploadingFile.value = true
            let uploadTask = ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    uploadForegroundImageOperation.cancel()
                    group.leave()
                    completion(error)
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        uploadForegroundImageOperation.cancel()
                        group.leave()
                        completion(error)
                        return
                    }
                    
                    self.saveUrlOfProp(imageType: .forgroundImageUrl, url: url) { error in
                        if let error = error {
                            uploadForegroundImageOperation.cancel()
                            group.leave()
                            completion(error)
                            return
                        }
                        group.leave()
                    }
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                if let fraction = snapshot.progress?.fractionCompleted {
                    self.bindableUploadingFileWithPercentage.value = fraction / 2.0
                    self.progress = fraction / 2.0
                }
            }
            
            group.wait()
        }
        
        
        let uploadBackgroundImageOperation = BlockOperation()
        uploadBackgroundImageOperation.addExecutionBlock {
            if !uploadForegroundImageOperation.isCancelled {
                group.enter()
                let ref = Storage.storage().reference().child(refString + "/images/\(background)")
                let imageData = self.images[1].jpegData(compressionQuality: 1) ?? Data()
                let uploadTask = ref.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        group.leave()
                        completion(error)
                        return
                    }
                    
                    ref.downloadURL { url, error in
                        if let error = error {
                            group.leave()
                            completion(error)
                            return
                        }
                        
                        self.bindableIsSavingLinks.value = true
                        self.saveUrlOfProp(imageType: .backgroundImageUrl, url: url) { error in
                            if let error = error {
                                group.leave()
                                completion(error)
                                return
                            }
                            self.bindableIsSavingLinks.value = false
                            self.bindableIsUploadingFile.value = false
                            self.saveImages()
                            completion(nil)
                            group.leave()
                        }
                    }
                }
                
                uploadTask.observe(.progress) { snapshot in
                    if let fraction = snapshot.progress?.fractionCompleted {
                        self.bindableUploadingFileWithPercentage.value = (fraction / 2) + self.progress
                    }
                }
                group.wait()
            }
        }
        
        uploadBackgroundImageOperation.addDependency(uploadForegroundImageOperation)
        
        let operationQueue = OperationQueue()
        operationQueue.addOperations([uploadForegroundImageOperation, uploadBackgroundImageOperation], waitUntilFinished: false)
        operationQueue.qualityOfService = .userInitiated
    }
    
    
    func saveUrlOfProp(imageType: ImageTypeUrl, url: URL?, completion: @escaping FIRESTORE_COMPLETION) {
        guard let collectionProp = K.FS.COLLECTION_PROP else { return }
        guard let propId = prop?.prop.uuid else { return }
        guard let url = url else { return }
        
        let data: [String: Any] = [imageType.rawValue: url.absoluteString]
        collectionProp.document(propId).setData(data, merge: true, completion: completion)
    }
}
