//
//  MasterViewController.swift
//  Profile editor
//
//  Created by Warwick McNaughton on 8/02/19.
//  Copyright © 2019 Warwick McNaughton. All rights reserved.
//

import UIKit


struct WebID: Codable {
    var name: String?
}


protocol ShowProfileDisplayLogic: class {
    func displaySections(viewModel: ShowProfile.Profile.ViewModel)
}


class ShowProfileViewController: UITableViewController, UITextFieldDelegate, ShowProfileDisplayLogic, UIPopoverPresentationControllerDelegate, DisplayRecentsPopupViewControllerDelegate {

    var interactor: ShowProfileBusinessLogic?
    var router: (NSObjectProtocol & ShowProfileRoutingLogic & ShowProfileDataPassing)?
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var activityIndicator: UIActivityIndicatorView?
    var indicatorContainerView: UIView?
    var tableSections = [Section]()
    var allUnFolded = true
    
    @IBOutlet weak var foldAllButton: UIBarButtonItem!
    
    
    // MARK: - Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    private func setup() {
        let viewController = self
        let interactor = ShowProfileInteractor()
        let presenter = ShowProfilePresenter()
        let router = ShowProfileRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        tableView.register(ShowProfileSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "ShowProfileSectionHeaderView")
        
        tableView.tableHeaderView = ShowProfileHeaderView(frame: CGRect.zero)
        tableView.tableHeaderView!.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView!.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        tableView.tableHeaderView!.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
        tableView.tableHeaderView!.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.tableHeaderView!.heightAnchor.constraint(equalToConstant: 50 ).isActive = true
        tableView.tableHeaderView!.widthAnchor.constraint(equalToConstant: tableView.frame.size.width).isActive = true
        (tableView.tableHeaderView as! ShowProfileHeaderView).webIDTextField?.delegate = self
        tableView.reloadData()
        
        var savedWebid: WebID?
        if let data = UserDefaults.standard.object(forKey: "WebID") as? Data  {
            savedWebid = try? JSONDecoder().decode(WebID.self, from: data)
        }
        if savedWebid != nil {
            (tableView.tableHeaderView as! ShowProfileHeaderView).webIDTextField?.text = savedWebid!.name
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    
    func itemWasEdited() {
        startActivityIndicator()
        var savedWebid: WebID?
        if let data = UserDefaults.standard.object(forKey: "WebID") as? Data  {
            savedWebid = try? JSONDecoder().decode(WebID.self, from: data)
        }
        if savedWebid != nil {
            (tableView.tableHeaderView as! ShowProfileHeaderView).webIDTextField?.text = savedWebid!.name
        }
        fetchProfile(webid: savedWebid!.name!)
    }
    
    
    func linkWasSelected() {
        startActivityIndicator()
        let selectedWebid = getWebid()
        let webid = WebID(name: selectedWebid)
        let encodedWebid = try? JSONEncoder().encode(webid)
        UserDefaults.standard.set(encodedWebid, forKey: "WebID")
        (tableView.tableHeaderView as! ShowProfileHeaderView).webIDTextField?.text = selectedWebid
        fetchProfile(webid: selectedWebid)
    }

    
    // MARK: - VIP
    
    func fetchProfile(webid: String) {
        guard let components = URLComponents(string: webid) else { return}
         if components.scheme != "https" {
            displayAlertWithMessage(title: "Error", message: "Must be https")
            return
        }
        let request = ShowProfile.Profile.Request(webid: webid)
        interactor?.fetchProfile(request: request, callback: { errorString in
            if errorString != nil {
                self.displayAlertWithMessage(title: "Error", message: errorString!)
            }
        })
    }
    
    func displaySections(viewModel: ShowProfile.Profile.ViewModel) {
        stopActivityIndicator()
        tableSections = viewModel.sections!
        tableView.reloadData()
        if tableSections.count > 1 {
            foldAllButton.isEnabled = true
        }
    }
    
    
    func saveWebIDToRecents(webID: String) {
        interactor!.saveWebIDToRecents(webID: webID)
    }
    
    
    // MARK: - Datastore
    
    func addSelectedItemToDataStore(item: (String, String, Int)) {
        interactor!.addSelectedItemToDataStore(item: item)
    }
    
    func getWebid()-> String {
        return interactor!.getWebid()
    }
    
    // MARK: - User actions
    
    @objc func displayRecentsInPopup(_ sender: UIButton) {
        let recentsPopUpController = DisplayRecentsPopupViewController(nibName: nil, bundle: nil)
        recentsPopUpController.modalPresentationStyle = .popover
        present(recentsPopUpController, animated: true, completion: nil)
        
        let popoverController = recentsPopUpController.popoverPresentationController
        popoverController!.delegate = self
        popoverController!.sourceView = sender.superview!
        popoverController!.sourceRect = sender.frame
        popoverController!.permittedArrowDirections = .up
        recentsPopUpController.delegate = self
        recentsPopUpController.reloadData()
    }
    
    
    @objc func sectionCollapseButtonPressed(_ sender: UIButton) {
        let sectionIndex = (sender.superview!.superview as! ShowProfileSectionHeaderView).sectionIndex
        if tableSections[sectionIndex!].isUnfolded == true {
            tableSections[sectionIndex!].isUnfolded = false
            sender.titleLabel!.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        }
        else {
            tableSections[sectionIndex!].isUnfolded = true
            sender.titleLabel!.transform = CGAffineTransform(rotationAngle: 0)
        }
        tableView.reloadData()
    }

    
    @IBAction func foldAllButtonPressed(_ sender: UIBarButtonItem) {
        for sectionIndex in 0..<tableSections.count {
            if allUnFolded == true {
                tableSections[sectionIndex].isUnfolded = false
            }
            else {
                tableSections[sectionIndex].isUnfolded = true
            }
        }
        allUnFolded = allUnFolded ? false : true
        sender.title = allUnFolded ? "Fold all" : "Unfold all"
        tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDatasource methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableSections.count > 0 && tableSections[section].isUnfolded == false {
            return 0
        }
        if tableSections.count > 0  {
            return tableSections[section].sectionData.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let (pred, obj, idx) = tableSections[indexPath.section].sectionData[indexPath.row]
        cell.tag = idx
        cell.textLabel?.text = pred
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.textColor = UIColor.red
        cell.detailTextLabel!.text = obj
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.textColor = UIColor.black
        return cell
    }
    
    
    // MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ShowProfileSectionHeaderView") as? ShowProfileSectionHeaderView
        if header == nil {
            header = ShowProfileSectionHeaderView(reuseIdentifier: "ShowProfileSectionHeaderView")
        }
        header?.sectionLabel?.text = tableSections[section].sectionName
        header?.sectionLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        header?.sectionLabel?.numberOfLines = 0
        header?.sectionLabel?.lineBreakMode = .byCharWrapping
        header?.sectionIndex = section
        header?.isUnfolded = tableSections[section].isUnfolded
        if tableSections[section].isUnfolded == true {
            header?.sectionCollapseButton?.titleLabel!.transform = CGAffineTransform(rotationAngle: 0)
        }
        else {
            header?.sectionCollapseButton?.titleLabel!.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        }
        return header
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath {
        let item = tableSections[indexPath.section].sectionData[indexPath.row]
        addSelectedItemToDataStore(item: item)
        return indexPath
    }
    
    
    // MARK: - UIActivityIndicatorView
    
    func startActivityIndicator() {
        if activityIndicator == nil {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { timer in
                print("Timer fired")
                if self.activityIndicator?.isAnimating == true {
                    self.displayAlertWithMessage(title: "Error", message: "Timed out")
                }
            })
            indicatorContainerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            indicatorContainerView!.backgroundColor = UIColor.clear
            activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator?.center = CGPoint(x: indicatorContainerView!.frame.size.width/2, y: indicatorContainerView!.frame.size.height/4)
            activityIndicator?.hidesWhenStopped = true
            indicatorContainerView!.addSubview(activityIndicator!)
            tableView.addSubview(indicatorContainerView!)
        }
        indicatorContainerView?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    
    func stopActivityIndicator() {
        activityIndicator?.stopAnimating()
        indicatorContainerView?.isHidden = true
    }

    // MARK: - UITextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != nil {
            let webid = WebID(name: textField.text!)
            let encodedProvider = try? JSONEncoder().encode(webid)
            UserDefaults.standard.set(encodedProvider, forKey: "WebID")
        }
        saveWebIDToRecents(webID: textField.text!)
        startActivityIndicator()
        fetchProfile(webid: textField.text!)
        return true
    }
    
    // MARK: - DisplayRecentsPopupViewController delegate methods
    
    func didSelectWebIDInPopUpViewController(_ viewController: DisplayRecentsPopupViewController, webID: String) {
        let header = tableView.tableHeaderView as! ShowProfileHeaderView
        header.webIDTextField!.text = webID
        tableSections = [Section]()
        tableView.reloadData()
        header.webIDTextField?.becomeFirstResponder()
        let _ = header.webIDTextField?.delegate?.textFieldShouldReturn!(header.webIDTextField!)
        dismiss(animated: true, completion: nil)
    }

    
    func didCancelPopupViewController() {
         dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Alerts
    
    func displayAlertWithMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            self.stopActivityIndicator()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

