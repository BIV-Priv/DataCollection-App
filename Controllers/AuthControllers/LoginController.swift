//
//  LoginController.swift
//  QRScanner
//

import UIKit
import AATools

class LoginController: UIViewController {

    //MARK: - Properties
    weak var delegate: NavigationDelegate?
    private let viewModel = LoginViewModel()
    
    private lazy var contentSize = CGSize(width: view.width, height: 1500)
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentSize = contentSize
        sv.showsVerticalScrollIndicator = false
        sv.frame = self.view.frame
        return sv
    }()
    
    private lazy var uiView: UIView = {
        let view = UIView()
        view.frame.size = contentSize
        return view
    }()
    
    private let headingLabel: UILabel = {
        let label = UILabel()
        label.text = "VizPriv"
        label.font = .systemFont(ofSize: 25, weight: .medium)
        label.textColor = .black
        label.backgroundColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "logo")
        iv.backgroundColor = .gray
        return iv
    }()
    
    private let emailTextField: UITextField = {
        let tf = LeftIndentTextField(leftSpacing: 12, color: .white)
        tf.attributedPlaceholder = .attributedString(fString: "Enter Id", fSColor: .gray, fSFont: .systemFont(ofSize: 14))
        tf.font = .systemFont(ofSize: 14)
        tf.setHeight(50)
        tf.layer.cornerRadius = 25
        tf.layer.borderWidth = 1
        tf.keyboardType = .emailAddress
        tf.textColor = .black
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setHeight(50)
        button.layer.cornerRadius = 25
        button.backgroundColor = .black.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleLogin() {
        viewModel.performLogin { error in
            self.viewModel.bindableIsSigningIn.value = false
            if let error = error {
                self.showHUD(true, withTitle: "Login Failed", error: error)
                return
            }
            Preferences.shared.isLoggedIn.value = true
            self.dismiss(animated: true) {
                self.delegate?.showSelectInitialOption()
            }
        }
    }
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        button.tag = 0
        button.setHeight(20)
        button.attributedTitle(firstRegularString: "Did not submit consent?", secondBoldString: " Submit", firstStringColor: .black, secondStringColor: .link, firstStringFont: UIFont.systemFont(ofSize: 18, weight: .bold), secondStringFont: UIFont.systemFont(ofSize: 18, weight: .bold))
        return button
    }()
    
    @objc
    private func handleRegister() {
        navigationController?.pushViewController(RegisterController(), animated: true)
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        dismissKeyboard()
        setupNotificationObservers()
        setupLoginViewModelObserver()
        setupTextFieldObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let height = logoImageView.top + logoImageView.height + 190 + 50
        scrollView.contentSize = CGSize(width: view.width, height: height)
        uiView.frame.size = CGSize(width: view.width,
                                   height: height)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        emailTextField.setWidth(view.width - 40)
        loginButton.setWidth(view.width - 40)
    }
    
    //MARK: - Helpers
    private func setupLoginViewModelObserver() {
        viewModel.bindableIsFormValid.bind { [weak self] isFormValid in
            guard let isFormValid = isFormValid, let self = self else { return }
            
            self.loginButton.backgroundColor = isFormValid ? UIColor.black : UIColor.black.withAlphaComponent(0.5)
            self.loginButton.isEnabled = isFormValid
        }
        
        viewModel.bindableIsSigningIn.bind { [weak self] isSigningIn in
            guard let isSigningIn = isSigningIn, let self = self else { return }
            
            if isSigningIn {
                self.showHUD(true, withTitle: "Signing in...", error: nil)
            } else {
                self.showHUD(false)
            }
        }
    }
    
    private func setupTextFieldObservers() {
        emailTextField.addTarget(self, action: #selector(handleTextDidChange), for: .editingChanged)

    }
    
    @objc func handleTextDidChange(textField: UITextField) {
        viewModel.id = textField.text
    }
    
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
      
        view.addSubview(scrollView)
        scrollView.addSubview(uiView)
        uiView.frame = scrollView.frame
        
        uiView.addSubview(headingLabel)
        headingLabel.centerX(inView: uiView, topAnchor: uiView.topAnchor, paddingTop: 48)
        
        uiView.addSubview(logoImageView)
        logoImageView.setDimensions(height: 100, width: 100)
        logoImageView.centerX(inView: uiView, topAnchor: headingLabel.bottomAnchor, paddingTop: 20)
        
        let tfStackView = UIView().stack(emailTextField, loginButton, dontHaveAccountButton, spacing: 20, alignment: .center, distribution: .fillEqually)
        
        uiView.addSubview(tfStackView)
        tfStackView.anchor(top: logoImageView.bottomAnchor, leading: uiView.leadingAnchor, trailing: uiView.trailingAnchor, paddingTop: 48, paddingLeft: 20, paddingRight: 20, height: 190)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDismiss), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
        
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            
            let frame = CGRect(x: self.dontHaveAccountButton.frame.origin.x, y: self.dontHaveAccountButton.frame.origin.y + 10, width: self.dontHaveAccountButton.frame.width, height: self.dontHaveAccountButton.frame.height)
            DispatchQueue.main.async {
                self.scrollView.scrollRectToVisible(frame, animated: false)
            }
        }
    }
    
    @objc func handleKeyboardDismiss() {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}
