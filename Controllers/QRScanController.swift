//
//  QRScanControll.swift
//  QRScanner
//

import UIKit
import AVFoundation
import AATools

class QRScanController: UIViewController {
    
    weak var delegate: QRCodeDelegate?
    var captureSession = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.setupVideo()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = view.bounds
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //MARK: - Helpers
    private func setupVideo() {
        
        guard let videoCaptureDevice  = AVCaptureDevice.default(for: .video) else {
            print("Your device is not capable for video processing")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            fatalError("Failed to get device with erorr: \(error.localizedDescription)")
        }
        
        if self.captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("DEBUG: Video input cannot be added to captureSession")
            return
        }
        
        let metaDataOuput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDataOuput) {
            captureSession.addOutput(metaDataOuput)
            
            metaDataOuput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDataOuput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
        } else {
            print("DEBUG: Failed to add video output to capture session...")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resize
        view.layer.addSublayer(self.previewLayer)
        self.captureSession.startRunning()
    }
}

extension QRScanController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let first = metadataObjects.first {
            guard let readableObject = first as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            delegate?.found(string: stringValue)
            self.captureSession.stopRunning()
        } else {
            print("Not able to read the code please try again or keep your device on QRCode")
        }
    }
}
