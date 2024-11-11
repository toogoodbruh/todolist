//
//  ToDoDetailTableViewController.swift
//  ToDoList
//
//  Created by Gabe Nydick on 4/30/21.
//

import UIKit
import MessageUI

class ToDoDetailTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dateLeftLabel: UILabel!
    @IBOutlet var dateRightLabel: UILabel!
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet var completionButton: UIButton!
    @IBOutlet var completionSwitch: UISwitch!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var textViewDoneButton: UIButton!
    @IBOutlet var notesDoneButtonCell: UITableViewCell!
    
    
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var datePickerTableCell: UITableViewCell!
    var isPickerHidden = true
    var isTextBeingEdited = false
    
    let dateLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndexPath = IndexPath(row: 1, section: 1)
    let notesDoneButtonCellPath = IndexPath(row: 0, section: 3)
    let noteTextIndexPath = IndexPath(row: 1, section: 3)
    
    let normalCellHeight: CGFloat = 44
    let largeCellHeight: CGFloat = 200
    
    var todo: ToDo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let todo = todo {
            navigationItem.title = "To-Do" //nav bar title
            titleTextField.text = todo.title
            dueDatePicker.date = todo.dueDate
            completionSwitch.isOn = todo.isComplete
            notesTextView.text = todo.notes
        } else {
            dueDatePicker.date = Date().addingTimeInterval(24*60*60)
            completionSwitch.isOn = false
        }
        dateLeftLabel.text = "Date"
        completionButton.setTitle("", for: .normal)
        completionButton.setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        updateDueDateLabel(date: dueDatePicker.date)
        updateSaveButtonState()
        isCompletedSwitchOn()
        //textViewDoneButton.isEnabled = false
        print("frame height \(dueDatePicker.frame.height)")

    }
    
    func updateSaveButtonState() {
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
        emailButton.isEnabled = !text.isEmpty
    }
    
    func updateDueDateLabel(date: Date) {
        dateRightLabel.text = ToDo.dueDateFormatter.string(from: date)
    }
    
    func isCompletedSwitchOn() {
        if completionSwitch.isOn {
            completionButton.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        } else {
            completionButton.setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        }
    }

    @IBAction func editingTextChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        titleTextField.resignFirstResponder()
    }
    
    /*@IBAction func notedReturnPressed(_ sender: UITextView) {
        notesTextView.resignFirstResponder()
    }*/
    
    @IBAction func notesTextViewDoneButtonPressed(_ sender: UIButton) {
        notesTextView.resignFirstResponder()
        isTextBeingEdited = false
    }
    
    @IBAction func isCompleted(_ sender: UISwitch) {
        isCompletedSwitchOn()
    }
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: dueDatePicker.date)
        todo?.markedLate = false
        print("todo? markedLate \(String(describing: todo?.markedLate))")
    }
    
    @IBAction func sendToDoEmail(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Cannot Send Email", message: "Your device is unable to send this note as an email.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)

            present(alert, animated: true, completion: nil)
            print("Cannot send mail.")
            return
        }
        
        var notes: String {
            if notesTextView.text == "" {
                return "No additional notes"
            } else {
                let str = "Additional notes: " + notesTextView.text!
                return str
            }
        }
        
        var completed: String {
            if completionSwitch.isOn{
                return "yes"
            } else {
                return "no"
            }
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        mailComposer.setToRecipients(nil)
        mailComposer.setSubject(titleTextField.text ?? "")
        mailComposer.setMessageBody("\(titleTextField.text ?? "") is due: \(dateFormatter.string(from: dueDatePicker.date) ) \n Is completed: \(completed) \n \(notes)", isHTML: false)
        
        
        print("email from swipe")
        present(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //tableView.reloadRows(at: [notesDoneButtonCellPath], with: .none)
        textViewDoneButton.isEnabled = true
        isTextBeingEdited = true
        print("textview is being edited")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //tableView.reloadRows(at: [notesDoneButtonCellPath], with: .none)
        textViewDoneButton.isEnabled = false
        isTextBeingEdited = false
        print("done editing textview")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "SaveToDo" else {
            return
        }
        
        let title = titleTextField.text!
        let dueDate = dueDatePicker.date
        let isComplete = completionSwitch.isOn
        let notes = notesTextView.text
        
        todo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes)
        todo?.markedLate = false
        
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            switch indexPath {
            case datePickerIndexPath:
                return isPickerHidden ? normalCellHeight :
                    dueDatePicker.frame.height
            case noteTextIndexPath:
                return largeCellHeight
            default:
                return normalCellHeight
            }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if #available(iOS 14, *) {
            /*if indexPath == dateLabelIndexPath {
                isPickerHidden = !isPickerHidden
                dateRightLabel.textColor = isPickerHidden ? .black :
                    tableView.tintColor
                tableView.beginUpdates()
                tableView.endUpdates()
             */
            print("On iOS 14.*")
            } else {
                if indexPath == dateLabelIndexPath {
                    isPickerHidden = !isPickerHidden
                    dateRightLabel.textColor = isPickerHidden ? .black :
                        tableView.tintColor
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
        }
        
        if indexPath == noteTextIndexPath {
            print("notesTextIndexPath")
        }
        todo?.markedLate = false
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        
    }*/

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
