//
//  SelectInitialOptionController.swift
//  QRScanner
//

import UIKit
import AATools


enum InitialOptionType: Int {
    case scanQr
    case propObject
}

class SelectInitialOptionController: UIViewController {
    
    //MARK: - Properties
    var isErrorAppeared = false
    weak var delegate: NavigationDelegate?
    
    private let scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan Qr Code", for: .normal)
        button.accessibilityLabel = "Select QR Code scanning"
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.setHeight(70)
        button.tag = 0
        button.addTarget(self, action: #selector(handleHome), for: .touchUpInside)
        return button
    }()
    
    private let propButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Prop Object", for: .normal)
        button.accessibilityLabel = "Select Prop Object"
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.setHeight(70)
        button.tag = 1
        button.addTarget(self, action: #selector(handleHome), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleHome(button: UIButton) {
        if button.tag == 0 {
            showHome(option: .scanQr)
        } else {
            showHome(option: .propObject)
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - Helpers
    private func setupUI() {
        self.view.backgroundColor = .white
        
        let stackView = UIView().stack(scanButton, propButton, spacing: 100, alignment: .fill, distribution: .fillEqually)
        view.addSubview(stackView)
        stackView.center(inView: view)
        stackView.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingLeft: 20, paddingRight: 20)
    }
    
    func showHome(option: InitialOptionType) {
        let preference = Preferences.shared
        preference.isUsingAppFirstTime.value = true
        if option == .propObject {
            
            
            let group = DispatchGroup()
            
            let uploadAndSavePropsInitiallyOperation = BlockOperation()
            uploadAndSavePropsInitiallyOperation.addExecutionBlock {
                if preference.isChoosedPropEver.value == nil {
                    DispatchQueue.main.async {
                        self.showHUD(true, withTitle: "Saving Props", error: nil)
                    }
                    let manager = CoreDataManager.shared
                    GlobalData.initialProps.forEach { propTitle in
                        group.enter()
                        let prop = Prop(context: manager.viewContext)
                        prop.title = propTitle
                        prop.publishedAt = Date()
                        let uuid = UUID().uuidString
                        prop.uuid = uuid
                        manager.save()
                        self.saveToFirestore(string: propTitle, uuid: uuid) { error in
                            group.leave()
                            if let error = error, !self.isErrorAppeared {
                                self.isErrorAppeared.toggle()
                                uploadAndSavePropsInitiallyOperation.cancel()
                                self.showHUD(true, withTitle: "Error", error: error)
                            }
                        }
                    }
                }
                group.wait()
            }
            
            let showHomeControllerOperation = BlockOperation()
            showHomeControllerOperation.addExecutionBlock {
                
                if !uploadAndSavePropsInitiallyOperation.isCancelled {
                    DispatchQueue.main.async {
                        preference.isChoosedPropEver.value = true
                        self.showHUD(false)
                        let homeController = HomeController()
                        homeController.initialOptionType = option
                        let nav = UINavigationController(rootViewController: homeController)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showHUD(false)
                    }
                }
            }
            
            showHomeControllerOperation.addDependency(uploadAndSavePropsInitiallyOperation)
            
            let operationQueue = OperationQueue()
            operationQueue.qualityOfService = .userInteractive
            operationQueue.addOperations([uploadAndSavePropsInitiallyOperation, showHomeControllerOperation], waitUntilFinished: false)
            
        } else {
            DispatchQueue.main.async {
                let homeController = HomeController()
                homeController.initialOptionType = option
                let nav = UINavigationController(rootViewController: homeController)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        }
    }
    
    private func saveToFirestore(string: String, uuid: String, completion: @escaping FIRESTORE_COMPLETION) {
        K.FS.COLLECTION_PROP?.document(uuid).setData(["id" : uuid,
                                                      "propTitle": string],
                                                     completion: completion)
    }
}
