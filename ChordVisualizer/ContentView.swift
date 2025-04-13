
//
//  EnhancedContentView.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//

import SwiftUI

// MARK: - Enhanced Main Content View

struct ContentView: View {
    // Create and manage the ViewModel instance
    @StateObject private var viewModel = ChordViewModel()
    @State private var selectedTab = 0
    @State private var showingChordProgressionBuilder = false
    @State private var chordProgression: [(rootNote: String, chordType: String, shape: String)] = []
    @State private var fingerPositions: [[Int?]] = []
    
    var body: some View {
        // Use NavigationView for title bar, especially useful on iPad
        NavigationView {
            // Main vertical stack for layout sections
            VStack(spacing: 0) { // No spacing between major sections
                
                // Tab selector for different views
                Picker("View Mode", selection: $selectedTab) {
                    Text("Single Chord").tag(0)
                    Text("Alternatives").tag(1)
                    Text("Progression").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Show different content based on selected tab
                TabView(selection: $selectedTab) {
                    // TAB 1: Single Chord View
                    SingleChordView(viewModel: viewModel)
                        .tag(0)
                    
                    // TAB 2: Alternative Voicings View
                    AlternativeVoicingsView(
                        rootNote: viewModel.selectedRootNote,
                        chordType: viewModel.selectedChordType,
                        isLeftHanded: viewModel.isLeftHanded
                    )
                    .tag(1)
                    
                    // TAB 3: Chord Progression View
                    VStack {
                        if chordProgression.isEmpty {
                            // Show empty state with instructions
                            VStack(spacing: 20) {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("No chord progression yet")
                                    .font(.headline)
                                
                                Text("Add chords to create a progression")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    // Add current chord to progression
                                    addCurrentChordToProgression()
                                }) {
                                    Label("Add Current Chord", systemImage: "plus")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                        } else {
                            // Show chord progression
                            ScrollView {
                                ChordProgressionView(
                                    chords: chordProgression,
                                    fingerPositions: fingerPositions,
                                    isLeftHanded: viewModel.isLeftHanded
                                )
                                
                                // Progression Controls
                                HStack {
                                    Button(action: {
                                        addCurrentChordToProgression()
                                    }) {
                                        Label("Add", systemImage: "plus")
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                    }
                                    
                                    Button(action: {
                                        if !chordProgression.isEmpty {
                                            chordProgression.removeLast()
                                            if !fingerPositions.isEmpty {
                                                fingerPositions.removeLast()
                                            }
                                        }
                                    }) {
                                        Label("Remove Last", systemImage: "minus")
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                    }
                                    
                                    Button(action: {
                                        chordProgression = []
                                        fingerPositions = []
                                    }) {
                                        Label("Clear All", systemImage: "trash")
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.gray)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer() // Push everything towards the top
            }
            .navigationTitle("Chord Visualizer")
            .navigationBarTitleDisplayMode(.inline) // Compact title style
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Toggle lefty mode
                        viewModel.isLeftHanded.toggle()
                    }) {
                        Image(systemName: "hand.raised")
                            .foregroundColor(viewModel.isLeftHanded ? .blue : .gray)
                    }
                }
            }
        }
        // Use stack navigation style for better iPad sidebar/detail behavior if nested
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Add current chord to progression
    private func addCurrentChordToProgression() {
        guard !viewModel.currentShapeString.isEmpty else { return }
        
        // Create a tuple with the chord information
        let chordInfo = (
            rootNote: viewModel.selectedRootNote,
            chordType: viewModel.selectedChordType,
            shape: viewModel.currentShapeString
        )
        
        // Generate finger positions
        let fingerPos = generateFingerPositions(for: viewModel.currentShapeString)
        
        // Add to the progression
        chordProgression.append(chordInfo)
        fingerPositions.append(fingerPos)
        
        // Switch to progression tab
        selectedTab = 2
    }
    
    // Generate finger positions for the current chord
    private func generateFingerPositions(for shape: String) -> [Int?] {
        let frets = shape.split(separator: " ").map { Int(String($0)) }
        var fingerPos: [Int?] = Array(repeating: nil, count: 6)
        
        // Skip if we don't have exactly 6 strings
        guard frets.count == 6 else { return fingerPos }
        
        // Find lowest non-zero fret to determine if it's a barre chord
        let nonZeroFrets = frets.compactMap { $0 }.filter { $0 > 0 }
        guard !nonZeroFrets.isEmpty else { return fingerPos } // All open or muted
        
        let lowestFret = nonZeroFrets.min()!
        
        // Count how many times the lowest fret appears - potential barre
        let lowestFretCount = nonZeroFrets.filter { $0 == lowestFret }.count
        let isLikelyBarre = lowestFretCount >= 3
        
        // For a barre chord, assign finger 1 to all matching lowest fret positions
        if isLikelyBarre {
            for i in 0..<6 {
                if frets[i] == lowestFret {
                    fingerPos[i] = 1
                }
            }
        }
        
        // Assign remaining fingers (2, 3, 4) to higher frets
        let stringIndices = Array(0..<6)
        let sortedIndices = stringIndices.sorted { i1, i2 in
            guard let f1 = frets[i1], let f2 = frets[i2] else {
                return false // Put nil values at the end
            }
            return f1 > f2 // Sort by descending fret number
        }
        
        var usedFingers = Set<Int>()
        if isLikelyBarre { usedFingers.insert(1) }
        
        for i in sortedIndices {
            // Skip strings that are already assigned, open, or muted
            if fingerPos[i] != nil || frets[i] == nil || frets[i] == 0 {
                continue
            }
            
            // Find the next available finger
            for finger in 1...4 {
                if !usedFingers.contains(finger) {
                    fingerPos[i] = finger
                    usedFingers.insert(finger)
                    break
                }
            }
        }
        
        return fingerPos
    }
}

// MARK: - Single Chord View (Extracted for organization)
struct SingleChordView: View {
    @ObservedObject var viewModel: ChordViewModel
    @StateObject private var audioPlayer = ChordAudioPlayer()
    
    var body: some View {
        VStack(spacing: 0) {
            // --- Top Controls Area ---
            HStack(alignment: .top) { // Align content within columns to the top
                // Chord Selection Column
                VStack(alignment: .leading) {
                    Text("Chord Selection").font(.headline).padding(.bottom, 2)

                    // Root Note Picker
                    Picker("Root", selection: $viewModel.selectedRootNote) {
                        ForEach(viewModel.rootNotes, id: \.self) { Text($0) }
                    }

                    // Chord Type Picker
                    Picker("Type", selection: $viewModel.selectedChordType) {
                        ForEach(viewModel.availableChordTypes, id: \.self) { Text($0) }
                    }
                    .disabled(viewModel.availableChordTypes.isEmpty) // Disable if no types

                    // Shape Picker (Conditional)
                    if viewModel.availableShapes.count > 1 {
                         Picker("Shape", selection: $viewModel.selectedShapeIndex) {
                             ForEach(0..<viewModel.availableShapes.count, id: \.self) { index in
                                 // Display shape string concisely
                                 Text("Shape \(index + 1): \(viewModel.availableShapes[index])")
                                     .font(.caption)
                                     .lineLimit(1)
                                     .truncationMode(.tail)
                             }
                         }
                    } else if !viewModel.availableShapes.isEmpty {
                        // Display single shape info if only one exists
                        Text("Shape 1: \(viewModel.availableShapes.first ?? "")")
                            .font(.caption).foregroundColor(.gray)
                            .padding(.leading, 5).padding(.top, 5) // Mimic picker alignment
                            .lineLimit(1)
                            .truncationMode(.tail)
                    } else {
                        // Placeholder if no shapes available
                         Text("Shape: -")
                            .font(.caption).foregroundColor(.gray)
                            .padding(.leading, 5).padding(.top, 5)
                    }
                }
                .pickerStyle(.menu) // Use compact menu pickers
                .frame(maxWidth: .infinity, alignment: .leading) // Allow this column to expand

                // Vertical divider between columns
                Divider().frame(maxHeight: 150) // Limit height

                // Options & Suggestions Column
                VStack(alignment: .leading) {
                     Text("Suggestions").font(.headline).padding(.bottom, 2)
                     // Suggestion Style Picker
                     Picker("Style", selection: $viewModel.selectedSuggestionStyle) {
                         ForEach(viewModel.styles, id: \.self) { Text($0) }
                     }
                     .pickerStyle(.menu)

                     // Suggest Button
                     Button("Suggest Next") {
                         viewModel.calculateSuggestions()
                     }
                     .buttonStyle(.bordered) // Use bordered style
                     .padding(.top, 2)

                     // Display Suggestions List
                     VStack(alignment: .leading) {
                          // Show placeholder or suggestions
                          if viewModel.suggestedChords.isEmpty {
                              Text("Press 'Suggest Next'")
                                   .font(.caption)
                                   .foregroundColor(.secondary)
                          } else {
                              ForEach(viewModel.suggestedChords, id: \.self) { suggestion in
                                   Text(suggestion)
                                       .font(.caption)
                                       .foregroundColor(.secondary)
                              }
                          }
                     }
                     .padding(.top, 5)
                     Spacer() // Push suggestions content up
                }
                .frame(width: 200) // Give this column a fixed width
            }
            .padding() // Padding around the entire top controls area
            .background(Color(.systemGray6)) // Background for the controls section

            // Audio Player
            Button(action: {
                if audioPlayer.isPlaying {
                    audioPlayer.stopAllSounds()
                } else {
                    audioPlayer.playChord(
                        rootNote: viewModel.selectedRootNote,
                        chordType: viewModel.selectedChordType,
                        voicing: viewModel.currentShapeString
                    )
                }
            }) {
                HStack {
                    Image(systemName: audioPlayer.isPlaying ? "stop.fill" : "play.fill")
                    Text(audioPlayer.isPlaying ? "Stop" : "Play Chord")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.vertical, 8)

            // --- Fretboard View ---
            FretboardView(
                shapeString: viewModel.currentShapeString,
                isLeftHanded: viewModel.isLeftHanded,
                fingerPositions: generateFingerPositions(for: viewModel.currentShapeString),
                highlightColor: Color(hex: "#3498db")
            )
            .frame(minHeight: 200, maxHeight: 300) // Allow flexible height
            .padding() // Padding around the fretboard view itself
            .cornerRadius(8)
            .shadow(color: .gray.opacity(0.4), radius: 3, x: 0, y: 2) // Subtle shadow
            .padding([.horizontal, .bottom]) // Padding outside the fretboard

            // --- Chord Info Panel ---
            VStack(alignment: .leading) {
                Text("Chord Info").font(.headline)
                // Use HStacks for label + value pairs
                HStack {
                    Text("Notes:").font(.caption).bold().frame(width: 70, alignment: .leading) // Align labels
                    Text(viewModel.chordNotesString).font(.caption)
                    Spacer() // Push content left
                }
                HStack {
                    Text("Formula:").font(.caption).bold().frame(width: 70, alignment: .leading)
                    Text(viewModel.chordFormulaString).font(.caption)
                    Spacer()
                }
                HStack {
                    Text("Inversion:").font(.caption).bold().frame(width: 70, alignment: .leading)
                    Text(viewModel.inversionString).font(.caption)
                    Spacer()
                }
            }
            .padding() // Padding inside the info box
            .frame(maxWidth: .infinity, alignment: .leading) // Take full width
            .background(Color(.systemGray6)) // Match controls background
            .cornerRadius(8)
            .padding([.horizontal, .bottom]) // Padding outside the info box
        }
    }
    
    // Generate finger positions based on the current shape
    private func generateFingerPositions(for shape: String) -> [Int?] {
        let frets = shape.split(separator: " ").map { Int(String($0)) }
        var fingerPos: [Int?] = Array(repeating: nil, count: 6)
        
        // Skip if we don't have exactly 6 strings
        guard frets.count == 6 else { return fingerPos }
        
        // Find lowest non-zero fret to determine if it's a barre chord
        let nonZeroFrets = frets.compactMap { $0 }.filter { $0 > 0 }
        guard !nonZeroFrets.isEmpty else { return fingerPos } // All open or muted
        
        let lowestFret = nonZeroFrets.min()!
        
        // Count how many times the lowest fret appears - potential barre
        let lowestFretCount = nonZeroFrets.filter { $0 == lowestFret }.count
        let isLikelyBarre = lowestFretCount >= 3
        
        // For a barre chord, assign finger 1 to all matching lowest fret positions
        if isLikelyBarre {
            for i in 0..<6 {
                if frets[i] == lowestFret {
                    fingerPos[i] = 1
                }
            }
        }
        
        // Assign remaining fingers (2, 3, 4) to higher frets
        let stringIndices = Array(0..<6)
        let sortedIndices = stringIndices.sorted { i1, i2 in
            guard let f1 = frets[i1], let f2 = frets[i2] else {
                return false // Put nil values at the end
            }
            return f1 > f2 // Sort by descending fret number
        }
        
        var usedFingers = Set<Int>()
        if isLikelyBarre { usedFingers.insert(1) }
        
        for i in sortedIndices {
            // Skip strings that are already assigned, open, or muted
            if fingerPos[i] != nil || frets[i] == nil || frets[i] == 0 {
                continue
            }
            
            // Find the next available finger
            for finger in 1...4 {
                if !usedFingers.contains(finger) {
                    fingerPos[i] = finger
                    usedFingers.insert(finger)
                    break
                }
            }
        }
        
        return fingerPos
    }
}

// MARK: - Preview
struct EnhancedContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
