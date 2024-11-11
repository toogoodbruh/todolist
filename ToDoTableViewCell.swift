//
//  ToDoTableViewCell.swift
//  ToDoList
//
//  Created by Gabe Nydick on 4/30/21.
//

import UIKit

protocol ToDoTableViewCellDelegate {
    func checkmarkTapped(sender: ToDoTableViewCell)
}

class ToDoTableViewCell: UITableViewCell {

    @IBOutlet var completionButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dueDateLabel: UILabel!
    var delegate: ToDoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        completionButton.setTitle("", for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func update(with todo: ToDo) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        titleLabel.text = todo.title
        //dueDateLabel.text = dateFormatter.string(from: todo.dueDate)
        dueDateLabel.text = ToDo.dueDateFormatter.string(from: todo.dueDate)
        //print("\(dateFormatter.string(from: todo.dueDate)) \(todo.dueDate)")
        if todo.dueDate < Date() || todo.markedLate == true {
            titleLabel.textColor = .systemRed
            dueDateLabel.textColor = .systemRed
        } else {
            titleLabel.textColor = .label
            dueDateLabel.textColor = .label
        }
        if todo.isComplete == true {
            completionButton.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        } else {
            completionButton.setImage(UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        }
    }
    
    @IBAction func isCompleteButtonPressed(_ sender: UIButton) {
        delegate?.checkmarkTapped(sender: self)
    }
}
