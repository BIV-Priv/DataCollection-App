//
//  PropObjectsController.swift
//  QRScanner
//

import UIKit
import AATools

fileprivate let cellIdentifier = "propCellIdentifier"

class PropObjectsController: UITableViewController {
    
    //MARK: - Properties
    weak var navigationDelegate: NavigationDelegate?
    var isComingFromVideoController = false
    
    enum PropStatus: Int, CaseIterable {
        case notCompleted
        case completed
    }
    
    var viewModel = PropObjectsViewModel()
    var props: [PropViewModel] {
        viewModel.getAllProps()
    }
    
    var propsDict = [Bool : [PropViewModel]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupTableView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Go Back", style: .plain, target: self, action: #selector(handleBack))
        groupProps()
    }
    
    @objc
    private func handleBack() {
        dismiss(animated: true) {
            self.navigationDelegate?.popViewController()
        }
    }
    
    private func groupProps() {
        let props = viewModel.getAllProps()
        self.propsDict = Dictionary(grouping: props) { prop in
            return prop.isCompleted
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        groupProps()
        tableView.reloadData()
        if propsDict[false]?.count ?? 0 > 0 {
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        }
    }
    
    //MARK: - Helpers
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    private func getCorrectSection(section: Int) -> Int {
        if propsDict.keys.count != 2 {
            return propsDict.keys.first! ? 1 : 0
        }
        return section
    }
}

//MARK: - UITableViewDatasource
extension PropObjectsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return propsDict.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch PropStatus(rawValue: getCorrectSection(section: section)) {
        case .notCompleted:
            return propsDict[false]?.count ?? 0
        case .completed:
            return propsDict[true]?.count ?? 0
        case .none:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        
        switch PropStatus(rawValue: getCorrectSection(section: indexPath.section)) {
        case .notCompleted:
            cell.textLabel?.text = propsDict[false]?[indexPath.row].title
        case .completed:
            cell.textLabel?.text = propsDict[true]?[indexPath.row].title
        case .none:
            break
        }
        
        return cell
    }
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = HeaderLabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        label.backgroundColor = .white
        
        switch PropStatus(rawValue: getCorrectSection(section: section)) {
        case .notCompleted:
            label.text = "List of incomplete props"
        case .completed:
            label.text = "List of complete props"
        case .none:
            break
        }
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}

//MARK: - UITableViewDelegate
extension PropObjectsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch PropStatus(rawValue: getCorrectSection(section: indexPath.section)) {
        case .notCompleted:
            let imageController = ImageController()
            imageController.prop = propsDict[false]?[indexPath.row]
            navigationController?.pushViewController(imageController, animated: true)
        case .completed:
            let detailPropControler = DetailPropController()
            detailPropControler.prop = propsDict[true]?[indexPath.row]
            detailPropControler.delegate = self
            present(detailPropControler, animated: true, completion: nil)
        case .none:
            break
        }
    }
}

//MARK: - SwipeActions
extension PropObjectsController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        switch PropStatus(rawValue: getCorrectSection(section: indexPath.section)) {
        case .notCompleted:
            
            if let props = propsDict[false], props.count < 0 {
                return nil
            } else {
                let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, _: (Bool) -> Void) in
                    
                    guard let props = self.propsDict[false] else { return }
                    let prop = props[indexPath.row]
                    self.viewModel.deleteProp(prop: prop)
                    if let index = props.firstIndex(where: { $0.prop.objectID == prop.prop.objectID}) {
                        self.propsDict[false]?.remove(at: index)
                    }
                    self.tableView.reloadData()
                }
                
                deleteAction.backgroundColor = .red
                
                let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
                swipeActionConfiguration.performsFirstActionWithFullSwipe = true
                
                return swipeActionConfiguration
            }
        case .completed:
            if let props = propsDict[true], props.count < 0 {
                return nil
            } else {
                let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, _: (Bool) -> Void) in
                    
                    guard let props = self.propsDict[true] else { return }
                    let prop = props[indexPath.row]
                    self.viewModel.deleteProp(prop: prop)
                    if let index = props.firstIndex(where: { $0.prop.objectID == prop.prop.objectID}) {
                        self.propsDict[true]?.remove(at: index)
                    }
                    self.tableView.reloadData()
                }
                
                deleteAction.backgroundColor = .red
                
                let swipeActionConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
                swipeActionConfiguration.performsFirstActionWithFullSwipe = true
                
                return swipeActionConfiguration
            }
        case .none:
            return nil
        }
    }
}

//MARK: - DetailPropDelegate
extension PropObjectsController: DetailPropDelegate {
    func edit(prop: PropViewModel, for media: MediaType) {
        if media == .image {
            let imageController = ImageController()
            imageController.isEditingProp = true
            imageController.prop = prop
            navigationController?.pushViewController(imageController, animated: true)
        } else {
            let videoController = VideoController()
            videoController.isEditingProp = true
            videoController.prop = prop
            navigationController?.pushViewController(videoController, animated: true)
        }
    }
}
