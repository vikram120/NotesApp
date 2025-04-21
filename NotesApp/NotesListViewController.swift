//
//  NotesListViewController.swift
//  NotesApp
//
//  Created by Vikram Kunwar on 17/04/25.
//

import UIKit

class NotesListViewController: UIViewController {
    
    @IBOutlet weak var tableV : UITableView!
    
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    
    @IBOutlet weak var searchNotexTxtField : UITextField!
    

    
    
    
    
    let viewModel = NotesViewModel()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchNotes()
        tableV.estimatedRowHeight = 60
        //tableV.rowHeight = UITableView.automaticDimension
        searchNotexTxtField.addTarget(self, action: #selector(searchNotes(_:)), for: .editingChanged)
    }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            viewModel.fetchNotes()
            tableV.reloadData()
            updateEmptyState()
        }
    
    func updateEmptyState() {
        emptyStateLabel.isHidden = !viewModel.notes.isEmpty
    }
    
    @objc func searchNotes(_ textField: UITextField) {
        guard let query = textField.text else { return }
        
        if query.isEmpty {
            viewModel.fetchNotes()
        } else {
            viewModel.filterNotes(with: query)  
        }
        
        tableV.reloadData()
    }


    
    
    
   
    @IBAction func AddNotes(_ sender: UIButton) {
        
        let newNote = Note(context: viewModel.context)
            newNote.title = "" // Empty title to start
            newNote.timestamp = Date()
            newNote.isPinned = false
            
            // Add the note to the array at index 0 (top of the list)
            viewModel.notes.insert(newNote, at: 0)
            
            // Navigate to detail screen
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController {
                // Pass the note and its index
                detailVC.note = newNote
                detailVC.viewModel = viewModel
                detailVC.noteIndex = 0
                detailVC.isNewNote = true // Flag to indicate this is a new note
                
                navigationController?.pushViewController(detailVC, animated: true)
            }
        
        
    }
    
    
    @IBAction func deleteAllNotes(_ sender: UIButton){
        
        // Only show the alert if there are notes to delete
            guard !viewModel.notes.isEmpty else {
                // Optional: Show a message that there are no notes to delete
                let emptyAlert = UIAlertController(title: "No Notes",
                                                 message: "There are no notes to delete.",
                                                 preferredStyle: .alert)
                emptyAlert.addAction(UIAlertAction(title: "OK", style: .default))
                present(emptyAlert, animated: true)
                return
            }
            
            // Create confirmation alert
            let alert = UIAlertController(title: "Delete All Notes",
                                         message: "Are you sure you want to delete all notes? This action cannot be undone.",
                                         preferredStyle: .alert)
            
            // Add Delete All action
            let deleteAction = UIAlertAction(title: "Delete All", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                // Delete all notes through the view model
                self.viewModel.deleteAllNotes()
                
                // Reload the table view
                self.tableV.reloadData()
                
                // Update empty state
                self.updateEmptyState()
            }
            
            // Add Cancel action
            alert.addAction(deleteAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // Present the alert
            present(alert, animated: true)
        
    }
    
    
    // Function to edit the note
        func editNoteAt(_ indexPath: IndexPath) {
            let note = viewModel.notes[indexPath.row]
            let alert = UIAlertController(title: "Edit Note", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = note.title
                textField.placeholder = "Update note title"
            }
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
                if let newText = alert.textFields?.first?.text, !newText.isEmpty {
                    self.viewModel.updateNote(at: indexPath.row, newTitle: newText)
                    self.tableV.reloadData()
                }
            }
            
            alert.addAction(updateAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }

        // Function to delete the note
    func deleteNoteAt(_ indexPath: IndexPath) {
        let note = viewModel.notes[indexPath.row]
        let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.viewModel.deleteNote(at: indexPath.row)
            self.tableV.deleteRows(at: [indexPath], with: .automatic)
            self.updateEmptyState() // <-- Update the empty state after deletion
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
 
}
extension NotesListViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.notes.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NotesTableCell else {
                return UITableViewCell()
            }

            let note = viewModel.notes[indexPath.row]
            cell.title.text = note.title
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            if let date = note.timestamp {
                cell.date.text = formatter.string(from: date)
            } else {
                cell.date.text = "No Date"
            }
            
            cell.pinned.isHidden = !note.isPinned

            return cell
        }

    // Swipe to delete (Right to Left)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteNote(at: indexPath.row)
            viewModel.fetchNotes() // <-- Make sure the notes array is refreshed
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateEmptyState()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Note tapped at index: \(indexPath.row)")
        let selectedNote = viewModel.notes[indexPath.row]
            
            // Instantiate the detail view controller
            if let detailVC = storyboard?.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController {
                // Pass the necessary data
                detailVC.note = selectedNote
                detailVC.viewModel = viewModel
                detailVC.noteIndex = indexPath.row
                
                // Navigate to the detail view
                navigationController?.pushViewController(detailVC, animated: true)
            }
        
    }


    // Swipe actions (Edit and Delete on right swipe)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.deleteNoteAt(indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        let pinTitle = viewModel.notes[indexPath.row].isPinned ? "Unpin" : "Pin"
        let pinAction = UIContextualAction(style: .normal, title: pinTitle) { (action, view, completionHandler) in
            self.viewModel.togglePin(at: indexPath.row)
            self.tableV.reloadData()
            completionHandler(true)
        }
        pinAction.backgroundColor = .systemCyan
        
        return UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
    }

}
