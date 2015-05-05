import UIKit

class ProfileTableViewController: UITableViewController, UIActionSheetDelegate {
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        title = "Profile"
        navigationItem.rightBarButtonItem = editButtonItem()
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))
        tableView.separatorInset.left = 12 + 60 + 12 + 22
        tableView.tableFooterView = UIView(frame: CGRectZero) // hides trailing separators

        let pictureButton = UIButton.buttonWithType(.Custom) as! UIButton
        pictureButton.addTarget(self, action: "editPictureAction", forControlEvents: .TouchUpInside)
        pictureButton.clipsToBounds = true
        pictureButton.frame = CGRect(x: 15, y: 12, width: 60, height: 60)
        pictureButton.layer.cornerRadius = 60/2
        pictureButton.setBackgroundImage(UIImage(named: account.user.pictureName()), forState: .Normal)
        pictureButton.tag = 5
        tableView.addSubview(pictureButton)

        addName()
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditingAction")
            tableView.setEditing(false, animated: false)
            tableView.tableHeaderView = nil
            tableView.viewWithTag(5)!.userInteractionEnabled = true

            let editPictureButton = UIButton.buttonWithType(.System) as! UIButton
            editPictureButton.frame = CGRect(x: 28, y: 12+60-0.5, width: 34, height: 21)
            editPictureButton.setTitle("edit", forState: .Normal)
            editPictureButton.setTitleColor(editPictureButton.titleColorForState(.Normal), forState: .Highlighted)
            editPictureButton.tag = 3
            editPictureButton.titleLabel?.font = UIFont.systemFontOfSize(13)
            editPictureButton.userInteractionEnabled = false
            tableView.addSubview(editPictureButton)
        } else {
            account.user.firstName = tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.text
            account.user.lastName = tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))?.text

            navigationItem.leftBarButtonItem = nil

            tableView.viewWithTag(3)!.removeFromSuperview()

            addName()
        }

        tableView.reloadData()
    }

    func addName() {
        tableView.viewWithTag(5)!.userInteractionEnabled = false

        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 12+60+12))
        tableHeaderView.autoresizingMask = .FlexibleWidth
        tableHeaderView.userInteractionEnabled = false
        tableView.tableHeaderView = tableHeaderView

        let nameLabel = UILabel(frame: CGRect(x: 91, y: 31, width: tableHeaderView.frame.width-91, height: 21))
        nameLabel.autoresizingMask = .FlexibleWidth
        nameLabel.font = UIFont.boldSystemFontOfSize(17)
        nameLabel.text = account.user.name
        tableHeaderView.addSubview(nameLabel)
    }

    // MARK: Actions

    func editPictureAction() {
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take Photo", "Choose Photo")
        actionSheet.showInView(tableView.window)
    }

    func cancelEditingAction() {
        setEditing(false, animated: true)
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editing ? 2 : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell), forIndexPath: indexPath) as! TextFieldTableViewCell
        cell.textFieldLeftLayoutConstraint.constant = tableView.separatorInset.left + 1
        let textField = cell.textField
        textField.clearButtonMode = .WhileEditing

        var placeholder: String!
        if indexPath.row == 0 {
            placeholder = "First"
            textField.text = account.user.firstName
        } else {
            placeholder = "Last"
            textField.text = account.user.lastName
        }
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor(white: 127/255.0, alpha: 1)])
        return cell
    }

    // MARK: UIActionSheetDelegate

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        println(buttonIndex)
        if buttonIndex != actionSheet.cancelButtonIndex {
            let imagePickerController = UIImagePickerController()
            let sourceType: UIImagePickerControllerSourceType = buttonIndex == 1 ? .Camera : .PhotoLibrary
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                imagePickerController.sourceType = sourceType
                presentViewController(imagePickerController, animated: true, completion: nil)
            } else {
                let sourceString = sourceType == .Camera ? "Camera" : "Photo Library"
                let alertView = UIAlertView(title: "\(sourceString) Unavailable", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
    }
}