//
//  NotesViewModel.swift
//  NotesApp
//
//  Created by Vikram Kunwar on 17/04/25.
//

import Foundation
import CoreData
import UIKit

class NotesViewModel {
    
    var notes: [Note] = []
    private var allNotes: [Note] = []  // Store the original list of notes
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchNotes() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        
        // Make sure the sort is very explicit
        let pinnedSort = NSSortDescriptor(key: "isPinned", ascending: false)
        let dateSort = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [pinnedSort, dateSort]

        do {
            notes = try context.fetch(request)
            allNotes = notes
        } catch {
            print("❌ Fetch failed: \(error)")
        }
    }



    func togglePin(at index: Int) {
        let note = notes[index]
        note.isPinned.toggle()
        
        if note.isPinned == false {
            note.timestamp = Date() // Update timestamp only when unpinning
        }
        
        saveContext()
    }

    
    func filterNotes(with query: String) {
            notes = allNotes.filter { note in
                note.title?.lowercased().contains(query.lowercased()) ?? false
            }
        }
    
    func addNote(title: String) {
        let newNote = Note(context: context)
        newNote.title = title
        newNote.timestamp = Date()
        saveContext() // This should call fetchNotes() internally
    }

    
    func updateNote(at index: Int, newTitle: String) {
        let note = notes[index]
        note.title = newTitle
        note.timestamp = Date() // Optionally update the timestamp
        saveContext()
    }
    
    func deleteNote(at index: Int) {
        let note = notes[index]
        context.delete(note)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
            fetchNotes() // This should refresh your notes with proper sorting
        } catch {
            print("❌ Save failed: \(error)")
        }
    }
    
    func deleteAllNotes() {
        // Create a fetch request for all notes
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Note.fetchRequest()
        
        // Create a batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
            // Reset the arrays
            notes = []
            allNotes = []
            
            // Save context (this will ensure proper cleanup)
            try context.save()
        } catch {
            print("❌ Delete all failed: \(error)")
        }
    }
}
