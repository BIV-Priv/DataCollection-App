//
//  RegisterController.swift
//  QRScanner
//

import UIKit
import AATools

class RegisterController: UIViewController {

    //MARK: - Properties
    private let viewModel = RegistrationViewModel()
    
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
    
    private let consentTextLabel: UILabel = {
        let label = UILabel()
        label.attributedText = GlobalData.consentText
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = LeftIndentTextField(leftSpacing: 12, color: .white)
        textField.attributedPlaceholder = .attributedString(fString: "Enter Id", fSColor: .gray, fSFont: .systemFont(ofSize: 14))
        textField.font = .systemFont(ofSize: 14)
        textField.setHeight(50)
        textField.layer.cornerRadius = 25
        textField.layer.borderWidth = 1
        textField.keyboardType = .emailAddress
        textField.delegate = self
        textField.tag = 11
        textField.textColor = .black
        return textField
    }()
    
    private let agreeConsentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I understand and agree consent", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setImage(UIImage(systemName: "square")?.withTintColor(.black).withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleAgreement), for: .touchUpInside)
        button.tag = 0
        return button
    }()
    
    @objc func handleAgreement(sender: UIButton) {
        
        if sender.tag == 0 {
            viewModel.isAgreeConsent = true
        } else {
            viewModel.isAgreeConsent = false
        }
    }
    
    private let submitConsentAndRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Consent and Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setHeight(50)
        button.layer.cornerRadius = 25
        button.backgroundColor = .black.withAlphaComponent(0.5)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleRegister() {
        viewModel.performRegister { error in
            self.viewModel.bindableIsRegistring.value = false
            if let error = error {
                self.showHUD(true, withTitle: "Error", error: error)
                return
            }
            
            self.showMessage(withTitle: "Success!", action1Title: "Okay", action2Title: nil, message: "You are successfully registered, please login now.") { [weak self] action in
                action.accessibilityLabel = "Okay"
                guard let self = self else {
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNotificationObservers()
        dismissKeyboard()
        setupTextFieldObservers()
        setupViewModelObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let height = agreeConsentButton.top + agreeConsentButton.height + 120 + 50
        
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
        
//        nameTextField.setWidth(view.width - 40)
        emailTextField.setWidth(view.width - 40)
//        passwordTextField.setWidth(view.width - 40)
        submitConsentAndRegisterButton.setWidth(view.width - 40)
//        reEnterPasswordTextField.setWidth(view.width - 40)
    }
    
    //MARK: - Helpers
    private func setupViewModelObserver() {
        viewModel.bindableIsRegistring.bind { [weak self] isRegistering in
            guard let self = self, let isRegistering = isRegistering else {
                return
            }
            if isRegistering {
                self.showHUD(true, withTitle: "Registering...", error: nil)
            } else {
                self.showHUD(false)
            }
        }
        
        viewModel.bindableIsFormValid.bind { [weak self] isFormValid in
            guard let self = self, let isFormValid = isFormValid else {
                return
            }
            self.submitConsentAndRegisterButton.backgroundColor = isFormValid ? .black : .black.withAlphaComponent(0.5)
        }
        
        viewModel.bindableIsAgreeConsent.bind { [weak self] isAgreeConsent in
            guard let self = self, let isAgreeConsent = isAgreeConsent else {
                return
            }
            
            if isAgreeConsent {
                self.agreeConsentButton.setImage(UIImage(systemName: "checkmark.square.fill")?.withTintColor(.black).withRenderingMode(.alwaysOriginal), for: .normal)
                self.agreeConsentButton.tag = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UIAccessibility.post(notification: .announcement, argument: "You agreed")
                }
            } else {
                self.agreeConsentButton.setImage(UIImage(systemName: "square")?.withTintColor(.black).withRenderingMode(.alwaysOriginal), for: .normal)
                self.agreeConsentButton.tag = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UIAccessibility.post(notification: .announcement, argument: "You disagreed, please agree to continue")
                }
            }
        }
    }
    
    private func setupTextFieldObservers() {
        emailTextField.addTarget(self, action: #selector(handleTextDidChange), for: .editingChanged)
    }
    
    @objc
    private func handleTextDidChange(textField: UITextField) {
        viewModel.id = emailTextField.text
    }
    
    private func setupUI() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .white
      
        view.addSubview(scrollView)
        scrollView.addSubview(uiView)
        uiView.frame = scrollView.frame
        
        uiView.addSubview(headingLabel)
        headingLabel.centerX(inView: uiView, topAnchor: uiView.topAnchor, paddingTop: 20)
        
        uiView.addSubview(logoImageView)
        logoImageView.setDimensions(height: 100, width: 100)
        logoImageView.centerX(inView: uiView, topAnchor: headingLabel.bottomAnchor, paddingTop: 20)
        
        uiView.addSubview(consentTextLabel)
        consentTextLabel.anchor(top: logoImageView.bottomAnchor, leading: uiView.leadingAnchor, trailing: uiView.trailingAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        uiView.addSubview(agreeConsentButton)
        agreeConsentButton.anchor(top: consentTextLabel.bottomAnchor, leading: uiView.leadingAnchor, paddingTop: 20, paddingLeft: 20)
        
        let tfStackView = UIView().stack(emailTextField, submitConsentAndRegisterButton, spacing: 20, alignment: .center, distribution: .fillEqually)
        
        uiView.addSubview(tfStackView)
        tfStackView.anchor(top: agreeConsentButton.bottomAnchor, leading: uiView.leadingAnchor, trailing: uiView.trailingAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 120)
    }
    

    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDismiss), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    func handleKeyboardShow(notification: Notification) {
        
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            
            let frame = CGRect(x: self.submitConsentAndRegisterButton.frame.origin.x, y: self.submitConsentAndRegisterButton.frame.origin.y + 10, width: self.submitConsentAndRegisterButton.frame.width, height: self.submitConsentAndRegisterButton.frame.height)
            self.scrollView.scrollRectToVisible(frame, animated: false)
        }
    }
    
    @objc func handleKeyboardDismiss() {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

extension RegisterController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
