//
//  NoteDetailViewController.swift
//  NotesApp
//
//  Created by Vikram Kunwar on 21/04/25.
//

import UIKit

class NoteDetailViewController: UIViewController {
    
    @IBOutlet weak var notesTextView : UITextView!
    
    var note: Note? // To store the selected note
    var viewModel: NotesViewModel? // Reference to the ViewModel
    var noteIndex: Int = 0 // To track which note we're editing
    
    var isNewNote = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the text view
        notesTextView.isEditable = true
        notesTextView.font = UIFont.systemFont(ofSize: 16)
        
        // Setup based on whether this is a new or existing note
        if isNewNote {
            // For new notes
            title = "New Note"
            notesTextView.text = ""
            notesTextView.becomeFirstResponder() // Automatically show keyboard
        } else {
            // For existing notes
            title = "Edit Note"
            if let note = note {
                notesTextView.text = note.title
            }
        }
        
        navigationItem.hidesBackButton = true
        
        
        
    }
    
    @IBAction func backNavigate(_ sender : UIButton){
        
        
        if isNewNote && (notesTextView.text.isEmpty || notesTextView.text == "") {
            // If it's a new note and empty, just delete it and go back
            if let note = note, let viewModel = viewModel {
                viewModel.context.delete(note)
                try? viewModel.context.save()
            }
            navigateBack()
            return
        }
        
        // Standard unsaved changes check
        if let originalText = note?.title, originalText != notesTextView.text {
            // Show confirmation alert if there are unsaved changes
            let alert = UIAlertController(
                title: "Unsaved Changes",
                message: "Do you want to save your changes before going back?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
                self.saveChanges()
                self.navigateBack()
            })
            
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
                // If it's a new note, delete it
                if self.isNewNote, let note = self.note, let viewModel = self.viewModel {
                    viewModel.context.delete(note)
                    try? viewModel.context.save()
                }
                self.navigateBack()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        } else {
            // No changes, just go back
            // But if it's a new empty note, delete it
            if isNewNote && (notesTextView.text.isEmpty || notesTextView.text == ""),
               let note = note, let viewModel = viewModel {
                viewModel.context.delete(note)
                try? viewModel.context.save()
            }
            navigateBack()
        }
        
    }
    
    func navigateBack() {
        // If using navigation controller
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            // If using modal presentation
            dismiss(animated: true)
        }
        
        
        
    }
    
    
    @IBAction func saveNote(_ sender: UIButton){
        
        saveChanges()
        
        // Show success message
        let alert = UIAlertController(
            title: "Saved",
            message: "Your note has been updated successfully.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        
    }
    
    // Private method to handle saving the note
    private func saveChanges() {
        guard let text = notesTextView.text, !text.isEmpty,
              let note = note, let viewModel = viewModel else {
            return
        }
        
        // Update the note
        note.title = text
        note.timestamp = Date() // Update timestamp
        
        // Save to Core Data
        try? viewModel.context.save()
        viewModel.fetchNotes() // Refresh the notes list
        
        // If this was a new note, it's not anymore
        isNewNote = false
        
        
        
        
    }
}
