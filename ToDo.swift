//
//  ToDo.swift
//  ToDoList
//
//  Created by Gabe Nydick on 4/30/21.
//

//import Foundation
import UIKit

struct ToDo: Codable, Equatable, CustomStringConvertible, Hashable {
    var title: String
    var isComplete: Bool
    //var dueDate: String
    var dueDate: Date
    var markedLate: Bool = false
    var notes: String?
    var uuid = UUID().uuidString
    
    static func == (lhs: ToDo, rhs: ToDo) -> Bool {
        if lhs.title == rhs.title {
            if lhs.isComplete && rhs.isComplete {
                if lhs.notes == rhs.notes {
                    if lhs.dueDate == rhs.dueDate {
                        if lhs.markedLate == rhs.markedLate {
                            if lhs.uuid == rhs.uuid {
                        return true
                            } else {
                                return false
                            }
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK: - attempt as Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(isComplete)
        hasher.combine(dueDate)
        hasher.combine(markedLate)
        hasher.combine(notes)
        
    }
    
    var description: String {
        let desc: String = "title: " + title + ", due date: " + dueDate.description + ", isComplete: " + String(isComplete) + ", notes? " + (notes ?? "")
        return desc
    }
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("todods").appendingPathExtension("plist")
    
    static func loadToDos() -> [ToDo]? {
        guard let codedToDos = try? Data(contentsOf: ArchiveURL)
        else{
            return nil
        }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<ToDo>.self, from: codedToDos)
    }
    
    static func saveToDos(_ todos: [ToDo]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedToDos = try? propertyListEncoder.encode(todos)
        try? codedToDos?.write(to: ArchiveURL, options: .noFileProtection)
    }
    
    static func loadSampleToDos() -> [ToDo] {
        let todo1 = ToDo(title: "Title1", isComplete: true, dueDate: Date(), notes: "notes test")
        let todo2 = ToDo(title: "Title2", isComplete: false, dueDate: Date(), notes: nil)
        
        return [todo1,todo2]
    }
    
    static let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
