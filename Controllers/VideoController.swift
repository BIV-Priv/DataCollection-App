//
//  VideoController.swift
//  QRScanner
//

import UIKit
import AVFoundation
import AATools

class VideoController: UIViewController {

    //MARK: - Properties
    var isEditingProp = false
    let viewModel = VideoViewModel()
    var prop: PropViewModel? {
        didSet {
            guard let prop = prop else {
                return
            }
            viewModel.prop = prop
            propName = prop.title
            title = prop.title
        }
    }
    
    var videoUrls = [URL]()
    var propName = ""
    
    var captureSession = AVCaptureSession()
    var videoDevice: AVCaptureDevice?
    var movieOutput = AVCaptureMovieFileOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    
    var timerCount = 0
    var timer = Timer()
    
    private let cameraView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .black
        return view
    }()
    
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
        label.accessibilityLabel = "Take foreground video"
        return label
    }()
    
    private lazy var shutterButton: RecordButton = {
        let button = RecordButton(frame: .zero)
        button.addTarget(self, action: #selector(handleRecord), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleRecord() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            timer.invalidate()
            timerCount = 0
            shutterButton.toggle(for: .notRecording)
        } else {
            shutterButton.toggle(for: .recording)
            guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let videoNumber = viewModel.videoUrls.count == 0 ? "-foreground" : "-background"
            url.appendPathComponent(propName + videoNumber + ".mov")

            try? FileManager.default.removeItem(at: url)
            movieOutput.startRecording(to: url, recordingDelegate: self)
            
            startAccessibilityAlert()
        }
    }
    
    private func startAccessibilityAlert() {
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(handleTime), userInfo: nil, repeats: true)
        
    }
    
    @objc
    func handleTime(timer: Timer) {
        if timerCount == 25 {
            UIAccessibility.post(notification: .announcement, argument: "25 seconds past")
        } else if timerCount >= 60 {
            UIAccessibility.post(notification: .announcement, argument: "60 seconds past")
            self.handleRecord()
        }
        timerCount += 1
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpCamera()
        setupViewModelObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UNotification.post(announcment: "Capture foreground video")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navBar = navigationController?.navigationBar
        
        topView.frame = CGRect(x: view.left, y: view.top, width: view.width, height: navBar!.height)
        previewLayer.frame = CGRect(x: view.left, y: navBar!.bottom, width: view.width, height: view.height - 190 - navBar!.bottom)
        shutterButton.center = CGPoint(x: view.width / 2, y: view.height - 70)
        shutterButton.setDimensions(height: 100, width: 100)
        imageSideLabel.center = CGPoint(x: view.width / 2, y: view.height - 160)
        
    }
    
    //MARK: - Helpers
    private func setupViewModelObserver() {
        viewModel.bindableShouldShowBackgroundAsTextLabel.bind { [weak self] shouldShowBackgroundText in
            guard let shouldShowBackgroundText = shouldShowBackgroundText, let self = self  else {
                return
            }
            
            if shouldShowBackgroundText {
                UNotification.post(announcment: "Foreground video captured, now capture Background Video")
                self.imageSideLabel.text = "Background"
            } else {
                self.imageSideLabel.text = "Foreground"
                self.captureSession.startRunning()
                self.viewModel.videoUrls.removeAll()
            }
        }
        
        viewModel.bindableIsBothVideoCaptured.bind { [weak self] isBothCaptured in
            guard let isBothCaptured = isBothCaptured, let self = self else {
                return
            }

            if isBothCaptured {
                self.captureSession.stopRunning()
                self.showActionSheet()
            }
        }
        
        viewModel.bindableIsUploadingVideo.bind { [weak self] isUploading in
            guard let isUploading = isUploading, let self = self else {
                return
            }
        
            
            DispatchQueue.main.async {
                UNotification.post(announcment: "Uploading")
                self.showProgressHud(isUploading)
            }
        }
        
        viewModel.bindalbeUploadingFileWithPercentage.bind { [weak self] fractionComplete in
            guard let fraction = fractionComplete, let self = self else {
                return
            }
            
            Debug.log(message: "progress", variable: fraction)
            
            DispatchQueue.main.async {
                self.incrementHUD(progress: fraction)
                if fraction == 1.0 {
                    self.viewModel.bindableIsSavingLinks.value = true
                }
            }
        }
        
        viewModel.bindableIsSavingLinks.bind { [weak self] isSavingLinks in
            guard let isSaving = isSavingLinks, let self = self else {
                return
            }
            
            if isSaving {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(950)) {
                    self.showHUD(true, withTitle: "Saving videos link", error: nil)
                }
            } else {
                UNotification.post(announcment: "Uploading finished")
                self.showHUD(false)
            }
        }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.backgroundColor = .white
        view.addSubview(topView)
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        view.addSubview(imageSideLabel)
        
    }
    
    private func setUpCamera() {
        
        if let videoDevice = AVCaptureDevice.default(for: .video ) {
            if let videoInput = try? AVCaptureDeviceInput(device: videoDevice) {
                if captureSession.canAddInput(videoInput) {
                    captureSession.addInput(videoInput)
                }
            }
        }
        
        // update sessin
        captureSession.sessionPreset = .high
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        // configure preview
        previewLayer.session = captureSession
        previewLayer.videoGravity = .resizeAspectFill
        
        
        // Enable camera start
        captureSession.startRunning()
    }
}

extension VideoController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        guard error == nil else {
            self.showHUD(true, withTitle: "Failed to record video with error: ", error: error)
            return
        }
        Debug.log(message: "did call", variable: #function)
        viewModel.videoUrls.append(outputFileURL)
    }
    
    private func showActionSheet() {
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let uploadAction = UIAlertAction(title: "Upload", style: .default) {[weak self] action in
            action.accessibilityLabel = "Upload"
            guard let self = self else {
                return
            }
            
            self.viewModel.uploadVideos { error in
                if let error = error {
                    Debug.log(message: "Failed to upload videos with error", variable: error.localizedDescription)
                    return
                }
                self.showFinalAlert()
            }
        }
        
        let retakeAction = UIAlertAction(title: "Retake", style: .default) {[weak self] action in
            action.accessibilityLabel = "Retake"
            guard let self = self else {
                return
            }
            self.viewModel.bindableShouldShowBackgroundAsTextLabel.value = false
        }
        
        actionSheet.addAction(uploadAction)
        actionSheet.addAction(retakeAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func showFinalAlert() {
        if isEditingProp {
            self.showMessage(withTitle: "Success", action1Title: "Okay", action2Title: nil, message: "Videos Edited Successfully") {[weak self] action in
                action.accessibilityLabel = "Okay"
                
                guard let self = self else {
                    return
                }
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            self.showMessage(withTitle: "", action1Title: "Okay", action2Title: nil, message: "You successfully completed this task. Go for the next task.") { action in
                action.accessibilityLabel = "Okay"
                
                let propObjectController = PropObjectsController()
                propObjectController.navigationDelegate = self
                let nav = UINavigationController(rootViewController: propObjectController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }

}

extension VideoController: NavigationDelegate {
    func popViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
}
