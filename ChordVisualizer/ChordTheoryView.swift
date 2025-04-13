//
//  ChordTheoryView.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//

import SwiftUI

// MARK: - Chord Theory View
struct ChordTheoryView: View {
    @StateObject private var viewModel: ChordTheoryViewModel
    
    init(rootNote: String, chordType: String) {
        self._viewModel = StateObject(wrappedValue: ChordTheoryViewModel(
            rootNote: rootNote, 
            chordType: chordType
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Chord Name and Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(viewModel.rootNote) \(viewModel.chordType)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(viewModel.chordDescription)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Chord Symbol
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 70, height: 70)
                        
                        Text(viewModel.chordSymbol)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Chord Composition
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Chord Structure", systemImage: "music.note.list")
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes in this chord:")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            ForEach(viewModel.chordNotes, id: \.self) { note in
                                NoteCircle(note: note, isRoot: note == viewModel.rootNote)
                            }
                        }
                    }
                    
                    // Intervals
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Intervals:")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.intervalsDescription)
                            .font(.body)
                    }
                    
                    // Formula
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Formula:")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.chordFormula)
                            .font(.body)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Scale Compatibility
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Scale Compatibility", systemImage: "pianokeys")
                    
                    Text("This chord works well with these scales:")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    ForEach(viewModel.compatibleScales, id: \.name) { scale in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(scale.name)
                                    .font(.headline)
                                
                                Text(scale.notes.joined(separator: " - "))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(scale.compatibility)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    scale.compatibility == "Perfect" ? Color.green.opacity(0.2) :
                                    scale.compatibility == "Good" ? Color.blue.opacity(0.2) :
                                    Color.orange.opacity(0.2)
                                )
                                .cornerRadius(4)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Common Uses and Progressions
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Common Uses", systemImage: "music.quarternote.3")
                    
                    // Roles description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Typical roles in music:")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        ForEach(viewModel.chordRoles, id: \.self) { role in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                
                                Text(role)
                                    .font(.body)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Common progressions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Common progressions with this chord:")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        ForEach(viewModel.commonProgressions, id: \.self) { progression in
                            HStack {
                                ForEach(progression.split(separator: "-").map(String.init), id: \.self) { chord in
                                    Text(chord.trimmingCharacters(in: .whitespaces))
                                        .font(.callout)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            chord.trimmingCharacters(in: .whitespaces).contains(viewModel.rootNote) ?
                                                Color.blue.opacity(0.2) : Color.gray.opacity(0.1)
                                        )
                                        .cornerRadius(6)
                                }
                                .padding(.trailing, 4)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Related Chords
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Related Chords", systemImage: "arrow.triangle.swap")
                    
                    // Substitution chords
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Substitution options:")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                            ForEach(viewModel.substitutionChords, id: \.self) { chord in
                                Text(chord)
                                    .font(.callout)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Extensions and alterations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Extensions and alterations:")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                            ForEach(viewModel.extendedVersions, id: \.self) { chord in
                                Text(chord)
                                    .font(.callout)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Emotional characteristics
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Emotional Character", systemImage: "heart.fill")
                    
                    // Mood tags
                    HStack(spacing: 8) {
                        ForEach(viewModel.moodTags, id: \.self) { mood in
                            Text(mood)
                                .font(.callout)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.purple)
                                .cornerRadius(20)
                        }
                    }
                    
                    Text(viewModel.moodDescription)
                        .font(.body)
                        .padding(.top, 4)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

// MARK: - UI Components
struct SectionHeader: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
            
            Spacer()
        }
    }
}

struct NoteCircle: View {
    let note: String
    let isRoot: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isRoot ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(width: 40, height: 40)
            
            Text(note)
                .font(.system(size: 14, weight: isRoot ? .bold : .medium))
                .foregroundColor(isRoot ? .blue : .primary)
        }
    }
}

// MARK: - Scale Model
struct ScaleInfo {
    let name: String
    let notes: [String]
    let compatibility: String
}

// MARK: - ViewModel for Chord Theory
class ChordTheoryViewModel: ObservableObject {
    @Published var rootNote: String
    @Published var chordType: String
    @Published var chordNotes: [String] = []
    @Published var chordFormula: String = ""
    @Published var chordSymbol: String = ""
    @Published var chordDescription: String = ""
    @Published var intervalsDescription: String = ""
    
    @Published var compatibleScales: [ScaleInfo] = []
    @Published var chordRoles: [String] = []
    @Published var commonProgressions: [String] = []
    @Published var substitutionChords: [String] = []
    @Published var extendedVersions: [String] = []
    @Published var moodTags: [String] = []
    @Published var moodDescription: String = ""
    
    init(rootNote: String, chordType: String) {
        self.rootNote = rootNote
        self.chordType = chordType
        updateChordInfo()
    }
    
    func updateChordInfo() {
        // Get chord notes
        let (notes, formula) = MusicTheory.getChordNotes(rootNoteName: rootNote, chordType: chordType)
        chordNotes = notes
        chordFormula = formula
        
        // Generate chord symbol
        chordSymbol = generateChordSymbol()
        
        // Generate descriptions
        chordDescription = generateChordDescription()
        intervalsDescription = generateIntervalsDescription()
        
        // Generate compatible scales
        compatibleScales = generateCompatibleScales()
        
        // Generate chord roles
        chordRoles = generateChordRoles()
        
        // Generate common progressions
        commonProgressions = generateCommonProgressions()
        
        // Generate substitution chords
        substitutionChords = generateSubstitutionChords()
        
        // Generate extended versions
        extendedVersions = generateExtendedVersions()
        
        // Generate mood info
        (moodTags, moodDescription) = generateMoodInfo()
    }
    
    // Generate chord symbol notation
    private func generateChordSymbol() -> String {
        // Base root note
        var symbol = rootNote
        
        // Add appropriate modification based on chord type
        switch chordType {
        case "Major":
            // Major chords typically have no additional symbol
            return symbol
            
        case "Minor":
            return symbol + "m"
            
        case "Dominant 7th":
            return symbol + "7"
            
        case "Major 7th":
            return symbol + "maj7"
            
        case "Minor 7th":
            return symbol + "m7"
            
        case "Diminished":
            return symbol + "dim"
            
        case "Diminished 7th":
            return symbol + "dim7"
            
        case "Half-Dim 7th":
            return symbol + "m7b5"
            
        case "Augmented":
            return symbol + "aug"
            
        case "Suspended 2nd":
            return symbol + "sus2"
            
        case "Suspended 4th":
            return symbol + "sus4"
            
        case "Power Chord":
            return symbol + "5"
            
        default:
            return symbol
        }
    }
    
    // Generate chord description
    private func generateChordDescription() -> String {
        switch chordType {
        case "Major":
            return "A bright, happy-sounding chord with a stable and resolved quality"
            
        case "Minor":
            return "A darker, more melancholic sound compared to major chords"
            
        case "Dominant 7th":
            return "Creates tension and a strong pull toward resolution"
            
        case "Major 7th":
            return "Adds warmth and sophistication to the major chord"
            
        case "Minor 7th":
            return "A mellow, jazzy extension of the minor chord"
            
        case "Diminished":
            return "Creates tension with a dissonant, unstable sound"
            
        case "Diminished 7th":
            return "Highly dissonant chord used for dramatic tension"
            
        case "Half-Dim 7th":
            return "Less dissonant than diminished, often in minor progressions"
            
        case "Augmented":
            return "Tense and unresolved with a mysterious quality"
            
        case "Suspended 2nd":
            return "Creates an open, ambiguous sound without the third"
            
        case "Suspended 4th":
            return "Creates tension that wants to resolve to a major or minor chord"
            
        case "Power Chord":
            return "Strong and direct with no major/minor quality (root and fifth only)"
            
        default:
            return "A chord consisting of multiple notes played simultaneously"
        }
    }
    
    // Generate intervals description
    private func generateIntervalsDescription() -> String {
        guard let formula = chordFormulas[chordType] else {
            return "Standard intervals for this chord type"
        }
        
        let intervalNames = formula.split(separator: "-").map { String($0) }
        
        switch chordType {
        case "Major":
            return "Root (1), Major Third (3), Perfect Fifth (5)"
            
        case "Minor":
            return "Root (1), Minor Third (♭3), Perfect Fifth (5)"
            
        case "Dominant 7th":
            return "Root (1), Major Third (3), Perfect Fifth (5), Minor Seventh (♭7)"
            
        case "Major 7th":
            return "Root (1), Major Third (3), Perfect Fifth (5), Major Seventh (7)"
            
        case "Minor 7th":
            return "Root (1), Minor Third (♭3), Perfect Fifth (5), Minor Seventh (♭7)"
            
        case "Diminished":
            return "Root (1), Minor Third (♭3), Diminished Fifth (♭5)"
            
        case "Diminished 7th":
            return "Root (1), Minor Third (♭3), Diminished Fifth (♭5), Diminished Seventh (♭♭7)"
            
        case "Half-Dim 7th":
            return "Root (1), Minor Third (♭3), Diminished Fifth (♭5), Minor Seventh (♭7)"
            
        case "Augmented":
            return "Root (1), Major Third (3), Augmented Fifth (♯5)"
            
        case "Suspended 2nd":
            return "Root (1), Major Second (2), Perfect Fifth (5)"
            
        case "Suspended 4th":
            return "Root (1), Perfect Fourth (4), Perfect Fifth (5)"
            
        case "Power Chord":
            return "Root (1), Perfect Fifth (5)"
            
        default:
            return intervalNames.joined(separator: ", ")
        }
    }
    
    // Generate compatible scales
    private func generateCompatibleScales() -> [ScaleInfo] {
        var scales: [ScaleInfo] = []
        
        // Determine scales based on chord type and root
        switch chordType {
        case "Major":
            scales = [
                ScaleInfo(
                    name: "\(rootNote) Major (Ionian)",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 4, 5, 7, 9, 11]),
                    compatibility: "Perfect"
                ),
                ScaleInfo(
                    name: "\(rootNote) Lydian",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 4, 6, 7, 9, 11]),
                    compatibility: "Good"
                ),
                ScaleInfo(
                    name: "\(rootNote) Mixolydian",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 4, 5, 7, 9, 10]),
                    compatibility: "Good"
                )
            ]
            
        case "Minor":
            let relativeMinor = MusicTheory.getNoteName(
                noteIndex: (MusicTheory.getNoteIndex(noteName: rootNote) ?? 0 + 3) % 12,
                preferSharp: rootNote.contains("#")
            )
            
            scales = [
                ScaleInfo(
                    name: "\(rootNote) Natural Minor (Aeolian)",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 3, 5, 7, 8, 10]),
                    compatibility: "Perfect"
                ),
                ScaleInfo(
                    name: "\(rootNote) Dorian",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 3, 5, 7, 9, 10]),
                    compatibility: "Good"
                ),
                ScaleInfo(
                    name: "\(rootNote) Harmonic Minor",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 3, 5, 7, 8, 11]),
                    compatibility: "Good"
                )
            ]
            
        case "Dominant 7th":
            scales = [
                ScaleInfo(
                    name: "\(rootNote) Mixolydian",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 4, 5, 7, 9, 10]),
                    compatibility: "Perfect"
                ),
                ScaleInfo(
                    name: "\(rootNote) Blues Scale",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 3, 5, 6, 7, 10]),
                    compatibility: "Good"
                ),
                ScaleInfo(
                    name: "\(rootNote) Dominant Bebop",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 4, 5, 7, 9, 10, 11]),
                    compatibility: "Good"
                )
            ]
            
        case "Diminished", "Diminished 7th":
            scales = [
                ScaleInfo(
                    name: "\(rootNote) Diminished Scale",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 3, 5, 6, 8, 9, 11]),
                    compatibility: "Perfect"
                ),
                ScaleInfo(
                    name: "\(rootNote) Harmonic Minor",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 3, 5, 7, 8, 11]),
                    compatibility: "Good"
                )
            ]
            
        case "Augmented":
            scales = [
                ScaleInfo(
                    name: "\(rootNote) Whole Tone Scale",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 4, 6, 8, 10]),
                    compatibility: "Perfect"
                ),
                ScaleInfo(
                    name: "\(rootNote) Augmented Scale",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 3, 4, 7, 8, 11]),
                    compatibility: "Good"
                )
            ]
            
        default:
            scales = [
                ScaleInfo(
                    name: "\(rootNote) Major Scale",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 4, 5, 7, 9, 11]),
                    compatibility: "Good"
                ),
                ScaleInfo(
                    name: "\(rootNote) Natural Minor Scale",
                    notes: generateScaleNotes(root: rootNote, pattern: [0, 2, 3, 5, 7, 8, 10]),
                    compatibility: "Moderate"
                )
            ]
        }
        
        return scales
    }
    
    // Helper to generate scale notes from pattern
    private func generateScaleNotes(root: String, pattern: [Int]) -> [String] {
        guard let rootIndex = MusicTheory.getNoteIndex(noteName: root) else {
            return []
        }
        
        let preferSharp = root.contains("#") || ["G", "D", "A", "E", "B", "F#", "C#"].contains(root)
        
        return pattern.map { offset in
            let noteIndex = (rootIndex + offset) % 12
            return MusicTheory.getNoteName(noteIndex: noteIndex, preferSharp: preferSharp)
        }
    }
    
    // Generate chord roles
    private func generateChordRoles() -> [String] {
        switch chordType {
        case "Major":
            return [
                "Often functions as the tonic (I) chord in major keys, creating stability",
                "Can act as a IV or V chord in progressions, creating movement",
                "Common as a secondary dominant when not in the home key"
            ]
            
        case "Minor":
            return [
                "Typically functions as the tonic (i) in minor keys",
                "Often appears as the vi chord in major keys for contrast",
                "Creates emotional depth and contrast in progressions",
                "Frequently used in verses or more introspective sections"
            ]
            
        case "Dominant 7th":
            return [
                "Strong tendency to resolve to the tonic chord",
                "Creates tension that pulls toward resolution",
                "Often used as the V7 chord in major and minor keys",
                "Key component in jazz turnarounds and blues progressions"
            ]
            
        case "Major 7th":
            return [
                "Adds sophistication to the tonic function in major keys",
                "Common in jazz, bossa nova, and contemporary pop",
                "Often used for sustained, dreamy passages or endings",
                "Creates a more colorful tonic than a simple major triad"
            ]
            
        case "Minor 7th":
            return [
                "Adds color to the tonic function in minor keys",
                "Often used as the ii chord in major key jazz progressions",
                "Common in jazz, R&B, soul, and funk music",
                "Creates a more sophisticated minor sound"
            ]
            
        case "Diminished", "Diminished 7th":
            return [
                "Creates strong tension and instability",
                "Often used as a passing chord between more stable harmonies",
                "Common in classical cadences and as vii° in major keys",
                "Can function as a dramatic pivot chord for modulations"
            ]
            
        case "Augmented":
            return [
                "Creates tension with an unresolved quality",
                "Often functions as a passing chord or dominant substitute",
                "Used to create a mysterious or surreal atmosphere",
                "Can serve as a pivot chord for modulations"
            ]
            
        case "Suspended 2nd", "Suspended 4th":
            return [
                "Creates an unresolved sound that wants to move to a major or minor chord",
                "Often used for dramatic effect before resolution",
                "Common in rock, pop, and folk guitar playing",
                "Adds color and movement to progressions"
            ]
            
        default:
            return [
                "Serves as a building block in chord progressions",
                "Creates harmonic color and interest in music",
                "Used to establish tonality and harmonic movement"
            ]
        }
    }
    
    // Generate common progressions
    private func generateCommonProgressions() -> [String] {
        let rootIndex = MusicTheory.getNoteIndex(noteName: rootNote) ?? 0
        let preferSharp = rootNote.contains("#") || ["G", "D", "A", "E", "B", "F#", "C#"].contains(rootNote)
        
        // Helper to get a note by interval
        func getNote(interval: Int) -> String {
            let noteIndex = (rootIndex + interval) % 12
            return MusicTheory.getNoteName(noteIndex: noteIndex, preferSharp: preferSharp)
        }
        
        // Generate symbols based on chord type
        func getSymbol(for note: String, chordType: String) -> String {
            switch chordType {
            case "Major": return note
            case "Minor": return note + "m"
            case "Dominant 7th": return note + "7"
            case "Major 7th": return note + "maj7"
            case "Minor 7th": return note + "m7"
            case "Diminished": return note + "dim"
            case "Half-Dim 7th": return note + "m7b5"
            default: return note
            }
        }
        
        switch chordType {
        case "Major":
            let four = getNote(interval: 5)
            let five = getNote(interval: 7)
            let six = getNote(interval: 9)
            let two = getNote(interval: 2)
            
            return [
                "\(rootNote) - \(four) - \(five)",
                "\(rootNote) - \(five) - \(six + "m") - \(four)",
                "\(rootNote) - \(six + "m") - \(four) - \(five)",
                "\(rootNote) - \(two + "m") - \(five) - \(rootNote)"
            ]
            
        case "Minor":
            let threeFlat = getNote(interval: 3)
            let fourMinor = getNote(interval: 5)
            let five = getNote(interval: 7)
            let sixFlat = getNote(interval: 8)
            let sevenFlat = getNote(interval: 10)
            
            return [
                "\(rootNote)m - \(fourMinor)m - \(five)",
                "\(rootNote)m - \(sixFlat) - \(sevenFlat)",
                "\(rootNote)m - \(fourMinor)m - \(threeFlat) - \(sevenFlat)",
                "\(rootNote)m - \(five)7 - \(rootNote)m"
            ]
            
        case "Dominant 7th":
            let one = getNote(interval: 5) // The "I" chord if this is V7
            let two = getNote(interval: 7) // The "ii" if this is V7
            let four = getNote(interval: 0) // The "IV" if this is V7
            
            return [
                "\(rootNote)7 - \(one)",
                "\(two)m7 - \(rootNote)7 - \(one)",
                "\(rootNote)7 - \(four)7",
                "\(one) - \(four) - \(rootNote)7 - \(one)"
            ]
            
        case "Diminished", "Diminished 7th", "Half-Dim 7th":
            let resolveNote = getNote(interval: 1) // Often resolves up a half step
            let altResolve = getNote(interval: 11) // Or down a half step
            
            return [
                "\(rootNote)dim - \(resolveNote)",
                "\(rootNote)dim - \(altResolve)m",
                "\(rootNote)dim7 - \(rootNote)7 - \(getNote(interval: 5))",
                "\(getNote(interval: 7))7 - \(rootNote)dim7 - \(getNote(interval: 5))"
            ]
            
        default:
            // Generic progressions based on the root
            let four = getNote(interval: 5)
            let five = getNote(interval: 7)
            let six = getNote(interval: 9)
            
            return [
                "\(rootNote) - \(four) - \(five) - \(rootNote)",
                "\(rootNote) - \(six + "m") - \(four) - \(five)",
                "\(rootNote) - \(getNote(interval: 2) + "m") - \(getNote(interval: 7)) - \(rootNote)"
            ]
        }
    }
    
    // Generate substitution chords
    private func generateSubstitutionChords() -> [String] {
        let rootIndex = MusicTheory.getNoteIndex(noteName: rootNote) ?? 0
        let preferSharp = rootNote.contains("#") || ["G", "D", "A", "E", "B", "F#", "C#"].contains(rootNote)
        
        // Helper to get a note by interval
        func getNote(interval: Int) -> String {
            let noteIndex = (rootIndex + interval) % 12
            return MusicTheory.getNoteName(noteIndex: noteIndex, preferSharp: preferSharp)
        }
        
        switch chordType {
        case "Major":
            return [
                "\(rootNote)6",
                "\(rootNote)maj7",
                "\(rootNote)add9",
                "\(rootNote)sus4",
                "\(getNote(interval: 9))m" // Relative minor
            ]
            
        case "Minor":
            return [
                "\(rootNote)m6",
                "\(rootNote)m7",
                "\(rootNote)m9",
                "\(rootNote)m(add9)",
                "\(getNote(interval: 3))" // Relative major
            ]
            
        case "Dominant 7th":
            return [
                "\(rootNote)9",
                "\(rootNote)13",
                "\(rootNote)7sus4",
                "\(getNote(interval: 6))7", // Tritone substitution
                "\(getNote(interval: 9))m7"
            ]
            
        case "Major 7th":
            return [
                "\(rootNote)6",
                "\(rootNote)maj9",
                "\(rootNote)maj13",
                "\(rootNote)add9",
                "\(getNote(interval: 9))m7"
            ]
            
        case "Minor 7th":
            return [
                "\(rootNote)m6",
                "\(rootNote)m9",
                "\(rootNote)m11",
                "\(getNote(interval: 5))m7",
                "\(getNote(interval: 10))maj7"
            ]
            
        case "Diminished", "Diminished 7th":
            return [
                "\(getNote(interval: 3))dim", // Diminished chords repeat every minor third
                "\(getNote(interval: 6))dim",
                "\(getNote(interval: 9))dim",
                "\(rootNote)m7b5",
                "\(getNote(interval: 1))7b9" // Resolution target with b9
            ]
            
        case "Augmented":
            return [
                "\(getNote(interval: 4))aug", // Augmented chords repeat every major third
                "\(getNote(interval: 8))aug",
                "\(rootNote)7#5",
                "\(rootNote)maj7#5",
                "\(getNote(interval: 8))7" // Common progression substitute
            ]
            
        default:
            return [
                "\(rootNote) (other voicing)",
                "\(getNote(interval: 7))", // Fifth relationship
                "\(getNote(interval: 5))", // Fourth relationship
                "\(getNote(interval: 9))m" // Relative minor/third relationship
            ]
        }
    }
    
    // Generate extended versions
    private func generateExtendedVersions() -> [String] {
        switch chordType {
        case "Major":
            return [
                "\(rootNote)6",
                "\(rootNote)maj7",
                "\(rootNote)maj9",
                "\(rootNote)add9",
                "\(rootNote)6/9"
            ]
            
        case "Minor":
            return [
                "\(rootNote)m6",
                "\(rootNote)m7",
                "\(rootNote)m9",
                "\(rootNote)m11",
                "\(rootNote)m(add9)"
            ]
            
        case "Dominant 7th":
            return [
                "\(rootNote)9",
                "\(rootNote)11",
                "\(rootNote)13",
                "\(rootNote)7b9",
                "\(rootNote)7#9"
            ]
            
        case "Major 7th":
            return [
                "\(rootNote)maj9",
                "\(rootNote)maj13",
                "\(rootNote)maj7#11",
                "\(rootNote)maj7(add13)",
                "\(rootNote)maj7/6"
            ]
            
        case "Minor 7th":
            return [
                "\(rootNote)m9",
                "\(rootNote)m11",
                "\(rootNote)m13",
                "\(rootNote)m(maj7)",
                "\(rootNote)m6/9"
            ]
            
        case "Diminished":
            return [
                "\(rootNote)dim7",
                "\(rootNote)m7b5 (half-diminished)",
                "\(rootNote)dim(maj7)",
                "\(rootNote)dim9",
                "\(rootNote)dim11"
            ]
            
        case "Augmented":
            return [
                "\(rootNote)aug7",
                "\(rootNote)aug9",
                "\(rootNote)augmaj7",
                "\(rootNote)aug7b9",
                "\(rootNote)aug13"
            ]
            
        default:
            return [
                "\(rootNote) (extended)",
                "\(rootNote) (with added notes)",
                "\(rootNote) (with altered tones)",
                "\(rootNote) (with bass note)",
                "\(rootNote) (with tension notes)"
            ]
        }
    }
    
    // Generate mood info
    private func generateMoodInfo() -> ([String], String) {
        switch chordType {
        case "Major":
            return (
                ["Happy", "Bright", "Resolved", "Stable", "Hopeful"],
                "The \(rootNote) major chord has a bright, optimistic quality. It sounds complete and stable, often conveying feelings of happiness, hopefulness, or triumph. In music, major chords typically establish a positive emotional foundation."
            )
            
        case "Minor":
            return (
                ["Melancholic", "Sad", "Pensive", "Introspective", "Emotional"],
                "The \(rootNote) minor chord has a darker, more melancholic quality than its major counterpart. It often evokes feelings of sadness, introspection, or solemnity. Minor chords can create emotional depth and are commonly used to express more complex or somber emotions."
            )
            
        case "Dominant 7th":
            return (
                ["Tense", "Anticipatory", "Bluesy", "Unresolved", "Dynamic"],
                "The \(rootNote) dominant 7th chord creates a strong sense of tension and movement. It has a distinct bluesy, jazzy quality and creates anticipation, strongly wanting to resolve to another chord. This tension makes it dynamic and energetic in progressions."
            )
            
        case "Major 7th":
            return (
                ["Dreamy", "Romantic", "Sophisticated", "Warm", "Peaceful"],
                "The \(rootNote) major 7th chord has a lush, dreamy quality. It sounds sophisticated and warm, often used in jazz and bossa nova. The added major 7th creates a gentle tension that gives this chord its distinctive romantic, peaceful character."
            )
            
        case "Minor 7th":
            return (
                ["Mellow", "Sophisticated", "Thoughtful", "Jazzy", "Smooth"],
                "The \(rootNote) minor 7th chord has a mellow, sophisticated sound. It takes the melancholy of a minor chord and adds a layer of complexity and smoothness. Common in jazz, R&B, and soul music, it creates a thoughtful, introspective mood with a touch of sophistication."
            )
            
        case "Diminished", "Diminished 7th":
            return (
                ["Tense", "Mysterious", "Unstable", "Dramatic", "Anxious"],
                "The \(rootNote) diminished chord creates a strong sense of tension and instability. It has a mysterious, unsettled quality that often creates dramatic moments in music. This chord is frequently used to build suspense or convey anxiety and uncertainty."
            )
            
        case "Augmented":
            return (
                ["Mysterious", "Unsettled", "Dreamlike", "Exotic", "Tense"],
                "The \(rootNote) augmented chord has an exotic, somewhat otherworldly quality. Its raised fifth creates an unresolved, floating sensation that can sound mysterious or dreamlike. Often used to create moments of heightened tension or to evoke strange, surreal atmospheres."
            )
            
        case "Suspended 2nd":
            return (
                ["Open", "Bright", "Floating", "Ambiguous", "Anticipatory"],
                "The \(rootNote) suspended 2nd chord has an open, somewhat bright quality. Without the third to define it as major or minor, it creates a sense of ambiguity and anticipation. The sus2 has a lighter, more floating quality than sus4 chords."
            )
            
        case "Suspended 4th":
            return (
                ["Anticipatory", "Tense", "Open", "Ambiguous", "Transitional"],
                "The \(rootNote) suspended 4th chord creates a feeling of anticipation and gentle tension. It has an open quality due to the absence of a third, making it neither major nor minor. This creates a sense of expectation, as the listener anticipates its resolution to a more stable chord."
            )
            
        case "Power Chord":
            return (
                ["Strong", "Bold", "Direct", "Raw", "Powerful"],
                "The \(rootNote) power chord has a strong, direct quality. Consisting of just the root and fifth (no third), it has a raw, powerful sound that doesn't specify major or minor tonality. This ambiguity and simplicity make it versatile and particularly popular in rock, punk, and metal music."
            )
            
        default:
            return (
                ["Expressive", "Colorful", "Distinctive", "Evocative"],
                "This \(rootNote) \(chordType) chord has a distinctive emotional character that adds color and expression to music. Its unique sound quality can evoke specific moods and atmospheres depending on the musical context."
            )
        }
    }
}