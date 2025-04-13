//
//  ChordViewModel.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//


import SwiftUI
import Combine // Needed for ObservableObject

// MARK: - ViewModel

class ChordViewModel: ObservableObject {
    // --- Selections ---
    @Published var selectedRootNote: String = "C" {
        didSet { updateAvailableTypes() }
    }
    @Published var selectedChordType: String = "Major" {
        didSet { updateAvailableShapes() }
    }
    @Published var selectedShapeIndex: Int = 0 {
        didSet { updateCurrentInfo() }
    }
    @Published var selectedSuggestionStyle: String = suggestionStyles.first ?? "Pop - Happy"
    @Published var isLeftHanded: Bool = false {
         didSet { updateCurrentInfo() } // Redraw needed
    }

    // --- Data Sources ---
    let rootNotes: [String] = chordDatabase.keys.sorted()
    let styles: [String] = suggestionStyles

    // --- Dependent State ---
    @Published var availableChordTypes: [String] = []
    @Published var availableShapes: [String] = [] // Store the string representations
    @Published var currentShapeString: String = ""
    @Published var chordNotesString: String = "-"
    @Published var chordFormulaString: String = "-"
    @Published var inversionString: String = "-"
    @Published var suggestedChords: [String] = []

    init() {
        updateAvailableTypes() // Initial population
    }

    // MARK: - Update Logic
    private func updateAvailableTypes() {
        guard let types = chordDatabase[selectedRootNote]?.keys else {
            availableChordTypes = []
            selectedChordType = "" // Reset
            updateAvailableShapes() // Trigger update down the chain
            return
        }
        availableChordTypes = types.sorted()
        // Try to keep selection or default to Major/first
        if !availableChordTypes.contains(selectedChordType) {
            selectedChordType = availableChordTypes.first(where: { $0 == "Major" }) ?? availableChordTypes.first ?? ""
        } else {
             // Trigger shape update even if type name didn't change, in case root change affected it
             updateAvailableShapes()
        }
    }

    private func updateAvailableShapes() {
        guard !selectedRootNote.isEmpty, !selectedChordType.isEmpty,
              let shapes = chordDatabase[selectedRootNote]?[selectedChordType] else {
            availableShapes = []
            selectedShapeIndex = 0
            updateCurrentInfo() // Update info even if shapes are empty
            return
        }
        availableShapes = shapes
        // Reset index if out of bounds, otherwise keep it
        if selectedShapeIndex >= availableShapes.count {
             selectedShapeIndex = 0
        }
        // Ensure info updates ONLY if the index actually changed OR shapes became available
        // This prevents infinite loops if updateCurrentInfo itself modifies state that calls this back
        // A better approach might use Combine pipelines or more careful state checks
        updateCurrentInfo()
    }

     private func updateCurrentInfo() {
        guard availableShapes.indices.contains(selectedShapeIndex) else {
            currentShapeString = ""
            chordNotesString = "-"
            chordFormulaString = "-"
            inversionString = "-"
            // Don't clear suggestions here automatically, only on selection change or button press
            return
        }
        let newShapeString = availableShapes[selectedShapeIndex]
        // Only update if shape string actually changed to prevent redraw loops if index reset didn't change the string
        if newShapeString != currentShapeString {
             currentShapeString = newShapeString
        }


        let (notes, formula) = MusicTheory.getChordNotes(rootNoteName: selectedRootNote, chordType: selectedChordType)
        chordNotesString = notes.isEmpty ? "-" : notes.joined(separator: " - ")
        chordFormulaString = formula

        inversionString = MusicTheory.getInversionInfo(rootNoteName: selectedRootNote, shapeString: currentShapeString, chordType: selectedChordType)

        // Clear suggestions when the main chord/shape changes
        // Do this here to ensure it clears even if only shape index changes
        if suggestedChords.count > 0 { // Only clear if there were suggestions
             suggestedChords = []
        }
    }

    // MARK: - Suggestion Logic
    func calculateSuggestions() {
        suggestedChords = [] // Clear previous
        let currentQuality: String
        if selectedChordType.contains("Major") { currentQuality = "Major" }
        else if selectedChordType.contains("Minor") { currentQuality = "Minor" }
        else if selectedChordType.contains("Dominant 7th") { currentQuality = "Dominant 7th" }
        else { currentQuality = "Other" } // Can add Diminished, Augmented etc. if rules exist

        guard let rules = suggestionRulesDatabase[selectedSuggestionStyle]?[currentQuality] else {
            suggestedChords = ["No rules for this type/style"]
            return
        }

        var suggestions: [String] = []
        for rule in rules {
            if let chordName = MusicTheory.calculateRelativeChord(rootName: selectedRootNote, intervalRoman: rule.intervalRoman, qualityRule: rule.qualityRule) {
                if !suggestions.contains(chordName) { // Avoid duplicates
                     suggestions.append(chordName)
                }
            }
        }

        // Update the published property
        suggestedChords = suggestions.isEmpty ? ["No suggestions found"] : suggestions
    }
}
