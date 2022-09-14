//
//  SplashController.swift
//  QRScanner
//

import UIKit
import AATools

class SplashController: UIViewController {
    //MARK: - Properties
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startUpCheck()
    }
    
    //MARK: - Helpers
    private func startUpCheck() {
        let preference = Preferences.shared
        if preference.isLoggedIn.value == nil || !preference.isLoggedIn.value! {
           showLogin()
        } else {
            showSelectInitialOption()
        }
    }
    
    private func showLogin() {
        DispatchQueue.main.async {
            let loginController = LoginController()
            loginController.delegate = self
            let nav = UINavigationController(rootViewController: loginController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
}

extension SplashController: NavigationDelegate {
    func showSelectInitialOption() {
//        let preference = Preferences.shared

        DispatchQueue.main.async {
            let infoController = InfoController()
            let nav = UINavigationController(rootViewController: infoController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
}

