//
//  VideoViewModel.swift
//  QRScanner
//

import Foundation
import UIKit
import AATools
import FirebaseStorage

class VideoViewModel {
    
    enum VideoTypeForUrl: String {
        case foregroundVideoUrl = "foregroundVideoUrl"
        case backgroundVideoUrl = "backgroundVideoUrl"
    }
    var bindableIsBothVideoCaptured = Bindable<Bool>()
    var bindableShouldShowBackgroundAsTextLabel = Bindable<Bool>()
    var bindableIsUploadingVideo = Bindable<Bool>()
    var bindalbeUploadingFileWithPercentage = Bindable<Double>()
    var bindableIsSavingLinks = Bindable<Bool>()
    
    var prop: PropViewModel?
    private var progress = 0.0
    var videoUrls = [URL]() {
        didSet {
            if videoUrls.count == 1 {
                bindableShouldShowBackgroundAsTextLabel.value = true
            } else if videoUrls.count == 2 {
                bindableIsBothVideoCaptured.value = true
            }
        }
    }
    
    func uploadVideos(completion: @escaping FIRESTORE_COMPLETION) {
        guard let user = UserModel.retrieveUser() else { return }
        guard let uid = K.FS.uid else { return }
        guard let propModel = prop else { return }
        
        let foreground = propModel.title + "-foreground" + "-" + UUID().uuidString + ".mov"
        let background = propModel.title + "-background" + "-" + UUID().uuidString + ".mov"
        let refString = user.name + "-" + uid
        
        let group = DispatchGroup()
        
        let uploadForegroundVideoOperation = BlockOperation()
        uploadForegroundVideoOperation.addExecutionBlock {
            group.enter()
            let ref = Storage.storage().reference().child(refString + "/videos/\(foreground)")
            let videoFile = self.videoUrls[0]
            
            self.bindableIsUploadingVideo.value = true
            let uploadTask = ref.putFile(from: videoFile, metadata: nil) { _, error in
                if let error = error {
                    uploadForegroundVideoOperation.cancel()
                    group.leave()
                    completion(error)
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        uploadForegroundVideoOperation.cancel()
                        group.leave()
                        completion(error)
                        return
                    }
                    
                    self.saveUrlToFirestoreProp(videoType: .foregroundVideoUrl, url: url) { error in
                        if let error = error {
                            uploadForegroundVideoOperation.cancel()
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
                    self.bindalbeUploadingFileWithPercentage.value = fraction / 2.0
                    self.progress = fraction / 2.0
                }
            }
            group.wait()
        }
        
        let uploadBackgroundVideoOperation = BlockOperation()
        uploadBackgroundVideoOperation.addExecutionBlock {
            if !uploadForegroundVideoOperation.isCancelled {
                group.enter()
                let ref = Storage.storage().reference().child(refString + "/videos/\(background)")
                let videoFile = self.videoUrls[1]
                let uploadTask = ref.putFile(from: videoFile, metadata: nil) { _, error in
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
                        self.saveUrlToFirestoreProp(videoType: .backgroundVideoUrl, url: url) { error in
                            if let error = error {
                                group.leave()
                                completion(error)
                                return
                            }
                            self.bindableIsSavingLinks.value = false
                            self.bindableIsUploadingVideo.value = false
                            self.saveVideosToCoreData()
                            completion(nil)
                            group.leave()
                        }
                    }
                }
                
                uploadTask.observe(.progress) { snapshot in
                    if let fraction = snapshot.progress?.fractionCompleted {
                        self.bindalbeUploadingFileWithPercentage.value = (fraction / 2.0) + self.progress
                    }
                }
                group.wait()
            }
        }
        
        uploadBackgroundVideoOperation.addDependency(uploadForegroundVideoOperation)
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        operationQueue.addOperations([uploadForegroundVideoOperation, uploadBackgroundVideoOperation], waitUntilFinished: false)
    }
    
    
    func saveUrlToFirestoreProp(videoType: VideoTypeForUrl, url: URL?, completion: @escaping FIRESTORE_COMPLETION) {
        guard let collectionProp = K.FS.COLLECTION_PROP else { return }
        guard let propId = prop?.prop.uuid else { return }
        guard let url = url else { return }
        
        let data: [String: Any] = [videoType.rawValue: url.absoluteString]
        collectionProp.document(propId).setData(data, merge: true, completion: completion)
    }

    
    private func saveVideosToCoreData() {
            
        guard let prop = prop?.prop else {
            return
        }
        prop.foregroundVideo = videoUrls[0]
        prop.backgroundVideo = videoUrls[1]
        prop.isCompleted = true
        
        CoreDataManager.shared.save()
    }
}
