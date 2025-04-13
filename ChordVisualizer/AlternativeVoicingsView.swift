//
//  AlternativeVoicingsView.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//


//
//  AlternativeVoicingsView.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//

import SwiftUI

struct AlternativeVoicingsView: View {
    @StateObject private var viewModel: AlternativeVoicingsViewModel
    let isLeftHanded: Bool
    
    init(rootNote: String, chordType: String, isLeftHanded: Bool = false) {
        self._viewModel = StateObject(wrappedValue: AlternativeVoicingsViewModel(
            rootNote: rootNote,
            chordType: chordType
        ))
        self.isLeftHanded = isLeftHanded
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title
            HStack {
                Text("Alternative Voicings")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.rootNote) \(viewModel.chordType)")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .padding(.horizontal)
            
            // Filter options
            HStack {
                Text("Filter:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: { viewModel.showAllVoicings() }) {
                    Text("All")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.filter == .all ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Button(action: { viewModel.filterByPosition(.open) }) {
                    Text("Open")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.filter == .open ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Button(action: { viewModel.filterByPosition(.barred) }) {
                    Text("Barred")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.filter == .barred ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Button(action: { viewModel.filterByPosition(.higher) }) {
                    Text("Higher")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.filter == .higher ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            if viewModel.filteredShapes.isEmpty {
                Text("No alternative voicings found")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Voicings grid
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.fixed(190))], spacing: 15) {
                        ForEach(0..<viewModel.filteredShapes.count, id: \.self) { index in
                            let shape = viewModel.filteredShapes[index]
                            let fingerPositions = viewModel.fingerPositions[index]
                            
                            VStack(spacing: 8) {
                                // Voicing name
                                Text(viewModel.getVoicingTitle(for: shape))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Diagram
                                FretboardView(
                                    shapeString: shape,
                                    isLeftHanded: isLeftHanded,
                                    fingerPositions: fingerPositions
                                )
                                .frame(width: 100, height: 160)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                
                                // Play button
                                Button(action: {
                                    viewModel.selectVoicing(at: index)
                                }) {
                                    Text(viewModel.selectedVoicingIndex == index ? "Selected" : "Select")
                                        .font(.caption)
                                        .foregroundColor(viewModel.selectedVoicingIndex == index ? .white : .blue)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            viewModel.selectedVoicingIndex == index ?
                                                Color.blue : Color.blue.opacity(0.1)
                                        )
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.bottom, 8)
                            .frame(width: 110)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        viewModel.selectedVoicingIndex == index ?
                                            Color.blue.opacity(0.7) : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .frame(height: 210)
            }
        }
    }
}

// MARK: - View Model for Alternative Voicings
class AlternativeVoicingsViewModel: ObservableObject {
    @Published var rootNote: String
    @Published var chordType: String
    @Published var filter: VoicingFilter = .all
    @Published var selectedVoicingIndex: Int = 0
    
    private var allShapes: [String] = []
    @Published var filteredShapes: [String] = []
    @Published var fingerPositions: [[Int?]] = [] // Finger positions for each shape
    
    enum VoicingFilter {
        case all
        case open
        case barred
        case higher
    }
    
    init(rootNote: String, chordType: String) {
        self.rootNote = rootNote
        self.chordType = chordType
        loadShapes()
    }
    
    func loadShapes() {
        // Load all shapes for this chord from database
        if let shapes = chordDatabase[rootNote]?[chordType] {
            allShapes = shapes
            filteredShapes = shapes
            
            // Generate finger positions for each shape
            fingerPositions = shapes.map { generateFingerPositions(for: $0) }
        } else {
            allShapes = []
            filteredShapes = []
            fingerPositions = []
        }
    }
    
    func showAllVoicings() {
        filter = .all
        filteredShapes = allShapes
        fingerPositions = allShapes.map { generateFingerPositions(for: $0) }
    }
    
    func filterByPosition(_ position: VoicingFilter) {
        filter = position
        
        switch position {
        case .open:
            // Filter for shapes that contain open strings (0)
            filteredShapes = allShapes.filter { shape in
                let frets = shape.split(separator: " ")
                return frets.contains { $0 == "0" }
            }
            
        case .barred:
            // Filter for shapes that likely use a barre (same fret on multiple strings)
            filteredShapes = allShapes.filter { shape in
                let frets = shape.split(separator: " ").compactMap { Int($0) }
                let fretCounts = Dictionary(grouping: frets, by: { $0 }).mapValues { $0.count }
                return fretCounts.values.contains { $0 >= 3 } // Consider it a barre if same fret on 3+ strings
            }
            
        case .higher:
            // Filter for shapes played higher up the neck
            filteredShapes = allShapes.filter { shape in
                let frets = shape.split(separator: " ").compactMap { Int($0) }
                return frets.contains { $0 > 4 } // At least one fret higher than 4
            }
            
        case .all:
            filteredShapes = allShapes
        }
        
        // Update finger positions for filtered shapes
        fingerPositions = filteredShapes.map { generateFingerPositions(for: $0) }
        
        // Reset selection if it's out of bounds
        if selectedVoicingIndex >= filteredShapes.count {
            selectedVoicingIndex = filteredShapes.isEmpty ? -1 : 0
        }
    }
    
    func selectVoicing(at index: Int) {
        guard index < filteredShapes.count else { return }
        selectedVoicingIndex = index
        // You could send this selection to parent view if needed
    }
    
    func getVoicingTitle(for shape: String) -> String {
        let inversionInfo = MusicTheory.getInversionInfo(
            rootNoteName: rootNote, 
            shapeString: shape,
            chordType: chordType
        )
        
        // Determine position description
        let frets = shape.split(separator: " ").compactMap { Int($0) }
        let lowestFret = frets.filter { $0 > 0 }.min() ?? 0
        let highestFret = frets.max() ?? 0
        
        let positionDesc: String
        if highestFret <= 3 {
            positionDesc = "Open"
        } else if lowestFret >= 8 {
            positionDesc = "High"
        } else if lowestFret >= 5 {
            positionDesc = "Mid"
        } else {
            positionDesc = "Low"
        }
        
        return "\(positionDesc) \(inversionInfo)"
    }
    
    // Basic algorithm to generate logical finger positions
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
        
        // First pass: assign fingers to the fretted notes from highest to lowest
        var usedFingers = Set<Int>()
        
        // For a barre chord, assign finger 1 to all matching lowest fret positions
        if isLikelyBarre {
            for i in 0..<6 {
                if frets[i] == lowestFret {
                    fingerPos[i] = 1
                    usedFingers.insert(1)
                }
            }
        }
        
        // Assign remaining fingers (2, 3, 4) to higher frets
        // Start with highest frets to ensure they get fingers
        let stringIndices = Array(0..<6)
        let sortedIndices = stringIndices.sorted { i1, i2 in
            guard let f1 = frets[i1], let f2 = frets[i2] else {
                return false // Put nil values at the end
            }
            return f1 > f2 // Sort by descending fret number
        }
        
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