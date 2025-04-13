//
//  MusicTheory.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//


import Foundation

// MARK: - Music Theory Logic

struct MusicTheory {
    // MARK: - Constants
    static let intervals: [String: Int] = [
        "1": 0, "b2": 1, "2": 2, "#2": 3, "b3": 3, "3": 4, "4": 5, "#4": 6, "b5": 6,
        "5": 7, "#5": 8, "b6": 8, "6": 9, "#6": 10, "bb7": 9, "b7": 10, "7": 11
    ]
    static let romanIntervals: [String: Int] = [
        "I": 0, "bII": 1, "ii": 2, "#ii": 3, "bIII": 3, "iii": 4, "IV": 5, "#IV": 6,
        "V": 7, "#V": 8, "bVI": 8, "vi": 9, "#vi": 10, "bVII": 10, "vii": 11, "vii°": 11,
        "i": 0 // Allow lowercase for minor resolution target
    ]
    static let noteNamesSharp = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
    static let noteNamesFlat = ["A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"]
    // EADGBe low E (idx 0) to high e (idx 5) -> Note indices (C=0)
    static let openStringIndices = [4, 9, 2, 7, 11, 4]

    // MARK: - Helper Functions
    static func getNoteIndex(noteName: String) -> Int? {
        if let index = noteNamesSharp.firstIndex(of: noteName) { return index }
        if let index = noteNamesFlat.firstIndex(of: noteName) { return index }
        let parts = noteName.split(separator: "/")
        let cleanName = String(parts[0]).trimmingCharacters(in: .whitespaces)
        if let index = noteNamesSharp.firstIndex(of: cleanName) { return index }
        if let index = noteNamesFlat.firstIndex(of: cleanName) { return index }
        return nil
    }

    static func getNoteName(noteIndex: Int, preferSharp: Bool = true) -> String {
        let index = (noteIndex % 12 + 12) % 12 // Ensure positive index
        if preferSharp { return noteNamesSharp[index] }
        else {
            if noteNamesFlat[index].hasSuffix("b") { return noteNamesFlat[index] }
            let sharpEquiv = noteNamesSharp[index]
            // Prefer flats unless it's a common sharp
            if sharpEquiv.contains("#") && !["F#", "C#", "G#", "D#", "A#"].contains(sharpEquiv) {
                return noteNamesFlat[index]
            }
            return sharpEquiv
        }
    }

    static func getChordNotes(rootNoteName: String, chordType: String) -> (notes: [String], formula: String) {
        guard let rootIndex = getNoteIndex(noteName: rootNoteName),
              let formula = chordFormulas[chordType] else {
            return ([], "N/A")
        }

        let intervalNames = formula.split(separator: "-").map(String.init)
        var notes: [String] = []
        var noteIndices = Set<Int>()
        let preferSharpCalc = rootNoteName.contains("#") || ["G","D","A","E","B","F#"].contains(rootNoteName)

        for intervalName in intervalNames {
            if let intervalSemitones = intervals[intervalName] {
                let noteIndex = (rootIndex + intervalSemitones) % 12
                if !noteIndices.contains(noteIndex) {
                    notes.append(getNoteName(noteIndex: noteIndex, preferSharp: preferSharpCalc))
                    noteIndices.insert(noteIndex)
                }
            }
        }

        // Ensure root is first
        let rootNameClean = getNoteName(noteIndex: rootIndex, preferSharp: preferSharpCalc)
        let altRootName = getNoteName(noteIndex: rootIndex, preferSharp: !preferSharpCalc)

        if !notes.contains(rootNameClean) && !notes.contains(altRootName) {
            notes.insert(rootNameClean, at: 0)
        } else if let firstNote = notes.first, firstNote != rootNameClean && firstNote != altRootName {
            if let idx = notes.firstIndex(of: rootNameClean) {
                notes.remove(at: idx)
                notes.insert(rootNameClean, at: 0)
            } else if let idx = notes.firstIndex(of: altRootName) {
                 notes.remove(at: idx)
                 notes.insert(altRootName, at: 0)
            }
        }
        return (notes, formula)
    }

    static func getInversionInfo(rootNoteName: String, shapeString: String, chordType: String) -> String {
        guard let rootIndex = getNoteIndex(noteName: rootNoteName),
              chordFormulas[chordType] != nil else { return "N/A" }

        let frets = shapeString.split(separator: " ").map(String.init)
        guard frets.count == 6 else { return "Invalid Shape" }

        var lowestNoteIndex: Int? = nil
        var minAbsPitch = 999

        for (i, fretVal) in frets.enumerated() { // i = 0 (low E) to 5 (high e)
            if let fretNum = Int(fretVal) {
                let openNote = openStringIndices[i]
                let absPitch = openNote + fretNum
                if absPitch < minAbsPitch {
                    minAbsPitch = absPitch
                    lowestNoteIndex = absPitch % 12
                }
            }
        }

        guard let lowNoteIdx = lowestNoteIndex else { return "No notes played?" }
        if lowNoteIdx == rootIndex { return "Root Position" }

        // We don't need to use the returned values directly, but we need to call this function
        // to get the note indices for the chord
        let _ = getChordNotes(rootNoteName: rootNoteName, chordType: chordType)
        
        guard let formulaStr = chordFormulas[chordType] else { return "N/A" }
        let noteIndices = formulaStr.split(separator: "-").compactMap { intervals[String($0)] }.map { (rootIndex + $0) % 12 }

        // Check 3rd, 5th, 7th based on formula presence
        let third = noteIndices.first { idx in
            idx == (rootIndex + intervals["3"]!) % 12 || idx == (rootIndex + intervals["b3"]!) % 12
        }
        let fifth = noteIndices.first { idx in
            idx == (rootIndex + intervals["5"]!) % 12 || idx == (rootIndex + intervals["b5"]!) % 12 || idx == (rootIndex + intervals["#5"]!) % 12
        }
        let seventh = noteIndices.first { idx in
            idx == (rootIndex + intervals["7"]!) % 12 || idx == (rootIndex + intervals["b7"]!) % 12 || idx == (rootIndex + intervals["bb7"]!) % 12
        }

        if let third = third, lowNoteIdx == third { return "1st Inversion" }
        if let fifth = fifth, lowNoteIdx == fifth { return "2nd Inversion" }
        if let seventh = seventh, lowNoteIdx == seventh, formulaStr.contains("7") { return "3rd Inversion" } // Check if 7th is in formula

        if noteIndices.contains(lowNoteIdx) {
             if chordType.contains("sus") {
                 if formulaStr.contains("2") && lowNoteIdx == (rootIndex + intervals["2"]!) % 12 { return "Voicing (2 in bass)" }
                 if formulaStr.contains("4") && lowNoteIdx == (rootIndex + intervals["4"]!) % 12 { return "Voicing (4 in bass)" }
             }
            return "Other Voicing"
        }

        return "Unknown Inversion"
    }

     static func calculateRelativeChord(rootName: String, intervalRoman: String, qualityRule: String) -> String? {
        guard let rootIndex = getNoteIndex(noteName: rootName),
              let intervalSemitones = romanIntervals[intervalRoman] else {
            return nil
        }

        let suggestedRootIndex = (rootIndex + intervalSemitones) % 12

        // Determine suggested quality string
        var suggestedQuality = "Major" // Default
        switch qualityRule {
            case "Minor": suggestedQuality = "Minor"
            case "Dominant 7th": suggestedQuality = "Dominant 7th"
            case "Major 7th": suggestedQuality = "Major 7th"
            case "Minor 7th": suggestedQuality = "Minor 7th"
            case "Diminished": suggestedQuality = "Diminished"
            case "Half-Dim 7th": suggestedQuality = "Half-Dim 7th"
            case "Augmented": suggestedQuality = "Augmented"
            case "Same": // Try to determine quality from current type if possible
                 if ["ii", "iii", "vi"].contains(intervalRoman) { suggestedQuality = "Minor"}
                 else if intervalRoman == "vii°" { suggestedQuality = "Diminished" }
                 else { suggestedQuality = "Major" } // Default for I, IV, V etc.
            default: suggestedQuality = "Major" // Fallback
        }
        // Override quality if interval implies it (like vii°)
        if intervalRoman == "vii°" { suggestedQuality = "Diminished" }
        if intervalRoman == "i" { suggestedQuality = "Minor" } // Handle targetting minor tonic


        let preferSharp = ![1, 3, 6, 8, 10].contains(suggestedRootIndex) // Indices for Bb, Eb, Ab, Db, Gb
        let suggestedRootName = getNoteName(noteIndex: suggestedRootIndex, preferSharp: preferSharp)

        // Optional: Check if the suggested chord actually exists in our database
        // guard chordDatabase[suggestedRootName]?[suggestedQuality] != nil else { return nil }

        return "\(suggestedRootName) \(suggestedQuality)"
    }
}
