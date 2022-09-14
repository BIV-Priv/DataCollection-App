//
//  ImageController.swift
//  QRScanner


import UIKit
import AVFoundation
import AATools
import JGProgressHUD

class ImageController: UIViewController {
    
    //MARK: - Properties
    var isEditingProp = false
    let viewModel = ImageViewModel()
    var session: AVCaptureSession?
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    var prop: PropViewModel? {
        didSet {
            guard let prop = prop else {
                return
            }
            viewModel.prop = prop
            title = prop.title
        }
    }
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let imageSideLabel: UILabel = {
        let label = UILabel()
        label.text = "Foreground"
        label.textColor = .white
        label.setDimensions(height: 40, width: 300)
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        label.accessibilityLabel = "Take foreground image"
        return label
    }()
    
    private let shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 50
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(handleImage), for: .touchUpInside)
        button.setDimensions(height: 100, width: 100)
        button.accessibilityLabel = "Shutter Button"
        return button
    }()
    
    @objc
    private func handleImage() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkCameraPermission()
        setupViewModelObserver()
    }
    
    private func setupViewModelObserver() {
        viewModel.bindableShouldBackgroundTextAsLabel.bind { [weak self] shouldBackground in
            guard let shouldBackground = shouldBackground, let self = self else {
                return
            }

            if shouldBackground {
                UNotification.post(announcment: "Foreground image captured, now take Background image")
                self.imageSideLabel.text = "Background"
            } else {
                self.imageSideLabel.text = "Foreground"
                self.session?.startRunning()
                self.viewModel.images.removeAll()
            }
        }
        
        viewModel.bindableIsBothImagesCaptured.bind { [weak self] isCaptured in
            guard let isCaptured = isCaptured, let self = self else {
                return
            }
            
            if isCaptured {
                self.session?.stopRunning()
                self.showActionSheet()
            }
        }
        
        viewModel.bindableIsUploadingFile.bind {[weak self] isUploading in
            guard let isUploading = isUploading, let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                UNotification.post(announcment: "Uploading")
                self.showProgressHud(isUploading)
            }
        }
        
        viewModel.bindableUploadingFileWithPercentage.bind {[weak self] fractionCompleted in
            guard let fractionCompleted = fractionCompleted, let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.incrementHUD(progress: fractionCompleted)
                if fractionCompleted == 1.0 {
                    self.viewModel.bindableIsSavingLinks.value = true
                }
            }
        }
        
        viewModel.bindableIsSavingLinks.bind { [weak self] isSavingLinks in
            guard let self = self, let isSavingLinks = isSavingLinks else {
                return
            }
            
            if isSavingLinks {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(950)) {
                    self.showHUD(true, withTitle: "Please wait...", error: nil)
                }
            } else {
                UNotification.post(announcment: "Uploading finished")
                self.showHUD(false)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navBar = navigationController?.navigationBar
        
        topView.frame = CGRect(x: view.left, y: view.top, width: view.width, height: navBar!.height)
        previewLayer.frame = CGRect(x: view.left, y: navBar!.bottom, width: view.width, height: view.height - 190 - navBar!.bottom)
        shutterButton.center = CGPoint(x: view.width / 2, y: view.height - 70)
        imageSideLabel.center = CGPoint(x: view.width / 2, y: view.height - 160)
        
    }
    
    //MARK: - Helpers
    private func setupUI() {
        self.view.backgroundColor = .black
        view.addSubview(topView)
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        view.addSubview(imageSideLabel)
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.setupCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera()
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.session = session
                previewLayer.videoGravity = .resizeAspectFill
                session.startRunning()
                self.session = session
            } catch {
                
            }
        }
    }
}

extension ImageController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        viewModel.images.append(UIImage(data: data)!)
    }
    
    private func showActionSheet() {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let uploadAction = UIAlertAction(title: "Upload", style: .default) { [weak self] action in
            action.accessibilityLabel = "Upload"
            guard let self = self else {
                return
            }
            
            self.viewModel.uploadImage { error in
                if let error = error {
                    self.showHUD(true, withTitle: "Error", error: error)
                    return
                }
                self.presentNextControllerOrDissmiss()
            }
        }
        
        let retakeAction = UIAlertAction(title: "Retake", style: .default) { [weak self] action in
            action.accessibilityLabel = "Retake"
            guard let self = self else {
                return
            }
            self.viewModel.bindableShouldBackgroundTextAsLabel.value = false
        }
        
        actionSheet.addAction(uploadAction)
        actionSheet.addAction(retakeAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentNextControllerOrDissmiss() {
        if isEditingProp {
            self.showMessage(withTitle: "Success", action1Title: "Okay", action2Title: nil, message: "Images Edited Successfully") {[weak self] action in
                action.accessibilityLabel = "Okay"
                
                guard let self = self else {
                    return
                }
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            let videoController = VideoController()
            videoController.prop = self.prop
            self.navigationController?.pushViewController(videoController, animated: true)
        }
        
    }
}
