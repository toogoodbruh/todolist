//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by Gabe Nydick on 4/30/21.
//

import UIKit
import MessageUI

class ToDoTableViewController: UITableViewController, ToDoTableViewCellDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    //@IBOutlet var editButton: UIBarButtonItem!
    let searchController = UISearchController()

    var todos = [ToDo]()
    var filteredToDos = [ToDo]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        if let savedToDos = ToDo.loadToDos() {
            todos = savedToDos
        } else {
            todos = ToDo.loadSampleToDos()
        }
        navigationItem.title = "To-Dos (\(todos.count))"
        
        initSearchController()
        
        /*while true {
            checkDateInToDo()
        }*/
        let timer = Timer(timeInterval: 2.5, target: self, selector: #selector(checkDateInToDo), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.scopeButtonTitles = ["All", "Completed", "Incomplete", "Overdue", "Not Due"]
        searchController.automaticallyShowsScopeBar = true
        searchController.searchBar.delegate = self
        searchController.reloadInputViews()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let selectedScopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        
        filterForSearchTextAndScopeButton(searchText: searchText, scopeButton: selectedScopeButton)
        searchBar.reloadInputViews()
        tableView.reloadData()
    }
    
    func filterForSearchTextAndScopeButton(searchText: String, scopeButton: String = "All") {
        var complete: String!
        var due: String!
        filteredToDos = todos.filter {
            todo in
            if todo.isComplete == true {
                complete = "Completed"
            } else {
                complete = "Incomplete"
            }
            
            if todo.dueDate < Date() {
                due = "Overdue"
            } else {
                due = "Not Due"
            }
            
            let scopeMatch = (scopeButton == "All" || complete.lowercased().contains(scopeButton.lowercased()) || due.lowercased().contains(scopeButton.lowercased()))
            if (searchController.searchBar.text != "" ) {
                let searchTextMatch = (todo.title.lowercased().contains(searchText.lowercased()))
                return scopeMatch && searchTextMatch
            } else {
                return scopeMatch
            }
        }
        tableView.reloadData()
        searchController.searchBar.reloadInputViews()
        searchController.reloadInputViews()
    }
    
    @objc func checkDateInToDo() {

        // MARK: Add custom cell controller here
        //cell.update(with: todo)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        var counter = 0
        var indexPath = IndexPath(row: 0, section: 0)
        var paths: [IndexPath] = []
        //print("todos count \(todos.count) \n")
        for todo in todos {
            //let date = dateFormatter.string(from: todo.dueDate)
            //if date < dateFormatter.string(from: Date()) {
            if todo.dueDate < Date() && todo.markedLate == false {
                indexPath.row = counter
                //print("true count: \(counter)")
                paths.append(indexPath)
                tableView.reloadRows(at: [indexPath], with: .right)
                todos[counter].markedLate = true
                //print("todo markedLate \(todos[counter].markedLate) indexPath.row \(indexPath.row)")
                
            }
            counter += 1
        }
        //print("finish count: \(counter) paths: \(paths.count)")
        
    }
    
    
    func updateIsCompleteInCell(sender: ToDo) {
        var counter = 0
        var indexPath = IndexPath(index: counter)
        for todo in todos {
            if todo == sender {
                indexPath.row = counter
                
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            counter += 1
        }
    }
    
    func checkmarkTapped(sender: ToDoTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            //var todo = todos[indexPath.row]
            //todo.isComplete = !todo.isComplete
            //todos[indexPath.row] = todo*/
            if searchController.isActive {
                var todo = filteredToDos[indexPath.row]
                //print("\(todo) before !isComplete")
                //print("\(todo.isComplete)")
                todo.isComplete = !todo.isComplete
                //print("\(todo.isComplete)")
                filteredToDos[indexPath.row] = todo
                print("\(filteredToDos) filteredToDos after assignment")
                tableView.reloadRows(at: [indexPath], with: .automatic)
                updateSearchResults(for: searchController) //added 9/8
                updateSearchResults(for: searchController)
                ToDo.saveToDos(todos)
                //findSameToDoFromFilteredList(todo)
                print("\n\(todo) \(indexPath.row) ...active \n")
                printFilteredList()
                print("")
                
                
            } else {
                var todo = todos[indexPath.row]
                todo.isComplete = !todo.isComplete
                todos[indexPath.row] = todo
                tableView.reloadRows(at: [indexPath], with: .automatic)
                ToDo.saveToDos(todos)
                print("\(todo) \(indexPath.row) ...not active")
            }
            
            
        }
    }
    
    func printFilteredList() {
        for todo in filteredToDos {
            print("\(todo) ...function printFilteredToDos")
        }
    }
    
    func findSameToDoFromFilteredList(_ filteredToDo: ToDo) {
        for i in 0..<todos.count {
            /*if todos[i].uuid == filteredToDo.uuid {
                print("\(todos[i])")
                todos[i] = filteredToDo
                print("\(todos[i])")
            }*/
            if todos[i].hashValue == filteredToDo.hashValue {
                print("\(todos[i])")
                todos[i] = filteredToDo
                print("\(todos[i])")
                print("hash values: \(todos[i].hashValue) - \(filteredToDo.hashValue)")
            }
        }
        ToDo.saveToDos(todos)
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive {
            return filteredToDos.count
        } else {
            return todos.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoReuse", for: indexPath) as? ToDoTableViewCell else {
            fatalError("Could not dequeue cell")
        }
        let todo: ToDo!
        if searchController.isActive {
            todo = filteredToDos[indexPath.row]
        } else {
            todo = todos[indexPath.row]
        }
        //let todo = todos[indexPath.row]

        // MARK: Add custom cell controller here
        cell.update(with: todo)
        cell.delegate = self

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            ToDo.saveToDos(todos)
            navigationItem.title = "To-Dos (\(todos.count))"
        }
    }
    // MARK: TABLE VIEW SWIPE ACTIONS
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let emailAction = UIContextualAction(style: .normal, title: "Email", handler: {
            (action, view, completionHandler) in
            self.handleEmail(indexPath: indexPath)
            completionHandler(true)
        })
        emailAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [emailAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    private func handleEmail(indexPath: IndexPath) {
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
            if todos[indexPath.row].notes == nil || todos[indexPath.row].notes == "" {
                return "No additional notes"
            } else {
                let str = "Additional notes: " + todos[indexPath.row].notes!
                return str
            }
        }
        
        var completed: String {
            if todos[indexPath.row].isComplete{
                return "yes"
            } else {
                return "no"
            }
        }
        
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        mailComposer.setToRecipients(nil)
        mailComposer.setSubject(todos[indexPath.row].title)
        mailComposer.setMessageBody("\(todos[indexPath.row].title) is due: \(dateFormatter.string(from: todos[indexPath.row].dueDate)) \n Is completed: \(completed) \n \(notes)", isHTML: false)
        
        print("email from swipe")
        present(mailComposer, animated: true, completion: nil)
    }
    
    //MARK: SETUP FOR MAIL VIEW CONTROLLER
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true)
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedToDo = todos.remove(at: fromIndexPath.row)
        todos.insert(movedToDo, at: to.row)
        ToDo.saveToDos(todos)
        tableView.reloadData()
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        if !searchController.isActive {
            return true
        } else {
            return false
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditToDo",
           let navController = segue.destination as? UINavigationController,
           
           let toDoDetailTableViewController = navController.topViewController as? ToDoDetailTableViewController {
                let indexPath = tableView.indexPathForSelectedRow!
           
            
            
            //added
            let todo: ToDo!
            if searchController.isActive {
                todo = filteredToDos[indexPath.row]
            } else {
                todo = todos[indexPath.row]
            }
            let selectedToDo = todo
            //end added
                //let selectedToDo = todos[indexPath.row]
                toDoDetailTableViewController.todo = selectedToDo
            
        }
        //timer.invalidate()
    }
    
    @IBAction func isCompletedButtonPressed(_ sender: UIButton) {
        let indexPath = tableView.indexPathForSelectedRow!
        
        var tempTodos: Array<ToDo> = Array()
        if searchController.isActive {
            tempTodos = filteredToDos
        } else {
            tempTodos = todos
        }
        
        //if todos[indexPath.row].isComplete {
        if tempTodos[indexPath.row].isComplete {
            sender.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
            
        } else {
            sender.setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        }
    
    }
    @IBAction func unwindToToDoList(segue: UIStoryboardSegue){
        guard segue.identifier == "SaveToDo" else {
            return
        }
        let sourceViewController = segue.source as! ToDoDetailTableViewController
        
        if !searchController.isActive {
            if let todo = sourceViewController.todo {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    todos[selectedIndexPath.row] = todo
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    print("segue \(todo)")
                } else {
                    let newIndexPath = IndexPath(row: todos.count, section: 0)
                    
                    todos.append(todo)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
            }
        } else {
            guard let todo = sourceViewController.todo else {return}
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    filteredToDos[selectedIndexPath.row] = todo
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                }
            print("segue2 \(todo)")
            findSameToDoFromFilteredList(todo)
            searchController.reloadInputViews()
        }
        ToDo.saveToDos(todos)
        navigationItem.title = "To-Dos (\(todos.count))"
        tableView.reloadData()
    }

}
