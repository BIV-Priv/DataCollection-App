//
//  HomeController.swift
//  QRScanner


import UIKit
import AATools
import CoreData
import FirebaseAuth

class HomeController: UIViewController {
    let qrCodeController = QRScanController()
    let propObjectController = PropObjectsController()
    
    lazy var initialOptionType: InitialOptionType = .scanQr {
        didSet {
            segmentedControl.selectedSegmentIndex = initialOptionType.rawValue
        }
    }
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["QR Code", "Prop Object"])
        sc.backgroundColor = .white
        sc.selectedSegmentIndex = 0
        sc.tintColor = .link
        sc.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)], for: .normal)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.link], for: .selected)
        sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleSegmentChange() {
        qrCodeController.view.removeFromSuperview()
        qrCodeController.removeFromParent()
        propObjectController.view.removeFromSuperview()
        propObjectController.removeFromParent()
        
        
        let bottom = (self.navigationController?.navigationBar.bottom)!
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            addChild(qrCodeController)
            view.addSubview(qrCodeController.view)
            qrCodeController.didMove(toParent: self)
            qrCodeController.view.frame = CGRect(x: view.left, y: bottom, width: view.width, height: view.height - 50 - bottom)
            
        } else {
            addChild(propObjectController)
            view.addSubview(propObjectController.view)
            propObjectController.didMove(toParent: self)
            propObjectController.view.frame = CGRect(x: view.left, y: bottom, width: view.width, height: view.height - 50 - bottom)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupControllers()
        setupBarButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    //MARK: - Helpers
    private func setupBarButtonItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Contact Us", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    @objc
    private func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func handleLogout() {
        let sms = "sms:+12176938503"
        let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        UIApplication.shared.open(URL(string: strURL)!, options: [:], completionHandler: nil)
        
        
//        do {
//            try Auth.auth().signOut()
//            Preferences.shared.isLoggedIn.destroyself()
//            Preferences.shared.user.destroyself()
//            let loginController = LoginController()
//            let nav = UINavigationController(rootViewController: loginController)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true, completion: nil)
//        } catch {
//            self.showHUD(true, withTitle: "Error", error: error)
//        }
    }
    
    private func setupUI() {
        title = "Home"
        navigationController?.navigationBar.backgroundColor = .white
        view.backgroundColor = .white
        view.addSubview(segmentedControl)
        segmentedControl.anchor(leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, height: 50)
    }
    
    private func setupControllers() {
        
        qrCodeController.view.removeFromSuperview()
        qrCodeController.removeFromParent()
        propObjectController.view.removeFromSuperview()
        propObjectController.removeFromParent()
        
        let bottom = (self.navigationController?.navigationBar.bottom)!
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            addChild(qrCodeController)
            view.addSubview(qrCodeController.view)
            qrCodeController.didMove(toParent: self)
            qrCodeController.view.frame = CGRect(x: view.left, y: bottom, width: view.width, height: view.height - 50 - bottom)
            
        } else {
            addChild(propObjectController)
            view.addSubview(propObjectController.view)
            propObjectController.didMove(toParent: self)
            propObjectController.view.frame = CGRect(x: view.left, y: bottom, width: view.width, height: view.height - 50 - bottom)
        }
    }
}

extension HomeController: QRCodeDelegate {
    func found(string: String) {
        segmentedControl.selectedSegmentIndex = 1
        handleSegmentChange()
        
        UIAccessibility.post(notification: .announcement, argument: "Scanned text is " + string)
        
        let manager = CoreDataManager.shared
        let prop = Prop(context: manager.viewContext)
        prop.title = string
        prop.publishedAt = Date()
        let uuid = UUID().uuidString
        prop.uuid = uuid
        manager.save()
        saveToFirestore(string: string, uuid: uuid)
    }
    
    private func saveToFirestore(string: String, uuid: String) {
        K.FS.COLLECTION_PROP?.document(uuid).setData(["id" : uuid,
                                                      "propTitle": string], completion: { error in
            
        })
    }
}
