//
//  InfoViewController.swift
//  QRScanner
//

import Foundation
import UIKit


class InfoController: UIViewController {
    //MARK: - Properties
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.attributedText = GlobalData.initialInfoText
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private let yesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Yes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.setDimensions(height: 50, width: 200)
        button.addTarget(self, action: #selector(handleYes), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleYes() {
        let selectInitOption = SelectInitialOptionController()
        navigationController?.pushViewController(selectInitOption, animated: true)
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - Helpers
    private func setupUI() {
        self.view.backgroundColor = .white
        
        view.addSubview(infoLabel)
        infoLabel.center(inView: view, yConstant: -100)
        infoLabel.anchor(leading: view.leadingAnchor, trailing: view.trailingAnchor, paddingLeft: 20, paddingRight: 20)
        
        view.addSubview(yesButton)
        yesButton.centerX(inView: view)
        yesButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 200)
    }
}
