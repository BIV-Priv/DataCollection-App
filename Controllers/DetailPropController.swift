//
//  DetailPropViewController.swift
//  QRScanner


import AATools
import UIKit

fileprivate let imageCellIdentifier = "detailPropImageCell"
fileprivate let videoCellIdentifier = "detailPropVideoCell"
fileprivate let headerIdentifier = "detailPropHeader"
fileprivate let footerIdentifier = "detailPropFooter"

enum MediaType: Int {
    case image
    case video
}

class DetailPropController: UIViewController {
    
    //MARK: - Properties
    var selectedImage = 0
    weak var delegate: DetailPropDelegate?
    
    enum MetaDataType: Int, CaseIterable {
        case image
        case video
    }
    
    var prop: PropViewModel? {
        didSet {
            
        }
    }
    
    private lazy var editImageButton: UIButton = {
        let button = button(with: "Edit Image")
        button.tag = 0
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()
    
    private lazy var editVideoButton: UIButton = {
        let button = button(with: "Edit Video")
        button.tag = 0
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func handleEdit(button: UIButton) {
        dismiss(animated: true) {
            self.delegate?.edit(prop: self.prop!, for: .init(rawValue: button.tag) ?? .image)
        }
    }
    
    private func button(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        button.setHeight(50)
        button.setWidth(200)
        return button
    }

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    //MARK: - Helpers
    private func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIView().stack(editImageButton, editVideoButton, spacing: 50, alignment: .center, distribution: .equalSpacing)
        view.addSubview(stackView)
        stackView.center(inView: view)
    }
    
    
}
