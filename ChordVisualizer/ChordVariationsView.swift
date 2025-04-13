//
//  ChordVariationsView.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//

import SwiftUI

// MARK: - Chord Variations View
struct ChordVariationsView: View {
    @StateObject private var viewModel: ChordVariationsViewModel
    let isLeftHanded: Bool
    
    init(rootNote: String, chordType: String, isLeftHanded: Bool = false) {
        self._viewModel = StateObject(wrappedValue: ChordVariationsViewModel(
            rootNote: rootNote,
            chordType: chordType
        ))
        self.isLeftHanded = isLeftHanded
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and filter controls
            VStack(spacing: 8) {
                HStack {
                    Text("Chord Variations")
                        .font(.headline)
                    Spacer()
                    Text("\(viewModel.rootNote) \(viewModel.chordType)")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterButton(
                            title: "All",
                            isSelected: viewModel.filter == .all,
                            action: { viewModel.setFilter(.all) }
                        )
                        
                        FilterButton(
                            title: "Open",
                            isSelected: viewModel.filter == .open,
                            action: { viewModel.setFilter(.open) }
                        )
                        
                        FilterButton(
                            title: "Barre",
                            isSelected: viewModel.filter == .barre,
                            action: { viewModel.setFilter(.barre) }
                        )
                        
                        FilterButton(
                            title: "Root Position",
                            isSelected: viewModel.filter == .rootPosition,
                            action: { viewModel.setFilter(.rootPosition) }
                        )
                        
                        FilterButton(
                            title: "Inversions",
                            isSelected: viewModel.filter == .inversions,
                            action: { viewModel.setFilter(.inversions) }
                        )
                        
                        FilterButton(
                            title: "Low",
                            isSelected: viewModel.filter == .low,
                            action: { viewModel.setFilter(.low) }
                        )
                        
                        FilterButton(
                            title: "Mid",
                            isSelected: viewModel.filter == .mid,
                            action: { viewModel.setFilter(.mid) }
                        )
                        
                        FilterButton(
                            title: "High",
                            isSelected: viewModel.filter == .high,
                            action: { viewModel.setFilter(.high) }
                        )
                    }
                }
                
                // Sort options
                HStack {
                    Text("Sort by:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Sort", selection: $viewModel.sortOption) {
                        Text("Position").tag(ChordVariationsViewModel.SortOption.position)
                        Text("Difficulty").tag(ChordVariationsViewModel.SortOption.difficulty)
                        Text("String Count").tag(ChordVariationsViewModel.SortOption.stringCount)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 250)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Variations grid
            if viewModel.filteredShapes.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "guitars")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No variations found")
                        .font(.headline)
                    
                    Text("Try a different filter or chord type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
                    ], spacing: 16) {
                        ForEach(0..<viewModel.filteredShapes.count, id: \.self) { index in
                            ChordVariationCard(
                                rootNote: viewModel.rootNote,
                                chordType: viewModel.chordType,
                                shapeString: viewModel.filteredShapes[index],
                                fingerPositions: viewModel.fingerPositions[index],
                                isLeftHanded: isLeftHanded,
                                attributes: viewModel.shapeAttributes[index]
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Filter Button Component
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .blue : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
    }
}

// MARK: - Chord Variation Card Component
struct ChordVariationCard: View {
    let rootNote: String
    let chordType: String
    let shapeString: String
    let fingerPositions: [Int?]?
    let isLeftHanded: Bool
    let attributes: ChordShapeAttributes
    
    var body: some View {
        VStack(spacing: 8) {
            // Title
            Text("\(attributes.positionName)")
                .font(.headline)
                .lineLimit(1)
            
            // Diagram
            FretboardView(
                shapeString: shapeString,
                isLeftHanded: isLeftHanded,
                fingerPositions: fingerPositions,
                highlightColor: attributes.difficulty == "Beginner" ? .green : 
                               (attributes.difficulty == "Easy-Intermediate" ? .blue : 
                               (attributes.difficulty == "Intermediate" ? .orange : .red))
            )
            .frame(height: 180)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Tags
            if !attributes.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(attributes.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 9))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            // Details
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Difficulty:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(attributes.difficulty)
                        .font(.caption2)
                        .foregroundColor(
                            attributes.difficulty == "Beginner" ? .green :
                            attributes.difficulty == "Easy-Intermediate" ? .blue :
                            attributes.difficulty == "Intermediate" ? .orange : .red
                        )
                }
                
                HStack {
                    Text("Strings:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(attributes.stringPattern)
                        .font(.caption2)
                }
                
                HStack {
                    Text("Inversion:")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(attributes.inversion)
                        .font(.caption2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Chord Shape Attributes
struct ChordShapeAttributes {
    let positionName: String
    let difficulty: String
    let stringPattern: String
    let inversion: String
    let tags: [String]
    let fretPosition: Int
    let usedStringCount: Int
}

// MARK: - ViewModel for Chord Variations
class ChordVariationsViewModel: ObservableObject {
    @Published var rootNote: String
    @Published var chordType: String
    @Published var filter: FilterOption = .all
    @Published var sortOption: SortOption = .position
    
    @Published var allShapes: [String] = []
    @Published var filteredShapes: [String] = []
    @Published var fingerPositions: [[Int?]] = []
    @Published var shapeAttributes: [ChordShapeAttributes] = []
    
    enum FilterOption {
        case all, open, barre, rootPosition, inversions, low, mid, high
    }
    
    enum SortOption {
        case position, difficulty, stringCount
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
            
            // Analyze all shapes and store their attributes
            analyzeAllShapes()
            
            // Apply initial filtering and sorting
            applyFilterAndSort()
        } else {
            allShapes = []
            filteredShapes = []
            fingerPositions = []
            shapeAttributes = []
        }
    }
    
    func setFilter(_ filter: FilterOption) {
        self.filter = filter
        applyFilterAndSort()
    }
    
    // Apply filter and sort based on current settings
    private func applyFilterAndSort() {
        // First filter shapes
        switch filter {
        case .all:
            filteredShapes = allShapes
            
        case .open:
            filteredShapes = allShapes.enumerated().filter { index, shape in
                return shape.contains("0")
            }.map { $0.element }
            
        case .barre:
            filteredShapes = allShapes.enumerated().filter { index, shape in
                let attribute = shapeAttributes[index]
                return attribute.tags.contains("Barre Chord")
            }.map { $0.element }
            
        case .rootPosition:
            filteredShapes = allShapes.enumerated().filter { index, shape in
                let attribute = shapeAttributes[index]
                return attribute.inversion.contains("Root Position")
            }.map { $0.element }
            
        case .inversions:
            filteredShapes = allShapes.enumerated().filter { index, shape in
                let attribute = shapeAttributes[index]
                return attribute.inversion.contains("Inversion") || 
                       attribute.inversion.contains("Voicing")
            }.map { $0.element }
            
        case .low:
            filteredShapes = allShapes.enumerated().filter { index, shape in
                let attribute = shapeAttributes[index]
                return attribute.fretPosition <= 3 && attribute.fretPosition > 0
            }.map { $0.element }
            
        case .mid:
            filteredShapes = allShapes.enumerated().filter { index, shape in
                let attribute = shapeAttributes[index]
                return attribute.fretPosition >= 4 && attribute.fretPosition <= 7
            }.map { $0.element }
            
        case .high:
            filteredShapes = allShapes.enumerated().filter { index, shape in
                let attribute = shapeAttributes[index]
                return attribute.fretPosition >= 8
            }.map { $0.element }
        }
        
        // Then sort filtered shapes
        let indices = filteredShapes.compactMap { shape in 
            return allShapes.firstIndex(of: shape)
        }
        
        // Apply sorting
        let sortedIndices = sortShapeIndices(indices)
        
        // Use the sorted indices to reorder filtered shapes and update other arrays
        filteredShapes = sortedIndices.map { allShapes[$0] }
        fingerPositions = sortedIndices.map { generateFingerPositions(for: allShapes[$0]) }
        shapeAttributes = sortedIndices.map { shapeAttributes[$0] }
    }
    
    // Sort shapes based on the current sort option
    private func sortShapeIndices(_ indices: [Int]) -> [Int] {
        switch sortOption {
        case .position:
            return indices.sorted { i1, i2 in
                return shapeAttributes[i1].fretPosition < shapeAttributes[i2].fretPosition
            }
            
        case .difficulty:
            return indices.sorted { i1, i2 in
                let difficultyOrder = ["Beginner": 1, "Easy-Intermediate": 2, "Intermediate": 3, "Advanced": 4]
                return (difficultyOrder[shapeAttributes[i1].difficulty] ?? 5) < 
                       (difficultyOrder[shapeAttributes[i2].difficulty] ?? 5)
            }
            
        case .stringCount:
            return indices.sorted { i1, i2 in
                return shapeAttributes[i1].usedStringCount > shapeAttributes[i2].usedStringCount
            }
        }
    }
    
    // Analyze all shapes and create attributes
    private func analyzeAllShapes() {
        shapeAttributes = []
        fingerPositions = []
        
        for shape in allShapes {
            // Generate finger positions
            let fingerPos = generateFingerPositions(for: shape)
            fingerPositions.append(fingerPos)
            
            // Create attributes for this shape
            let attribute = analyzeShape(shape)
            shapeAttributes.append(attribute)
        }
    }
    
    // Analyze a single shape to create its attributes
    private func analyzeShape(_ shape: String) -> ChordShapeAttributes {
        let frets = shape.split(separator: " ").map { Int(String($0)) }
        
        // Get basic properties
        let nonZeroFrets = frets.compactMap { $0 }.filter { $0 > 0 }
        let hasOpenStrings = frets.contains { $0 == 0 }
        let lowestFret = nonZeroFrets.min() ?? 0
        let highestFret = nonZeroFrets.max() ?? 0
        let fretSpan = highestFret - lowestFret
        let usedStringCount = frets.compactMap { $0 }.count
        
        // Check for barre pattern
        let sameLowestCount = nonZeroFrets.filter { $0 == lowestFret }.count
        let isBarreChord = sameLowestCount >= 3
        
        // Determine position name
        let positionName: String
        if lowestFret == 0 || highestFret <= 3 {
            positionName = "Open Position"
        } else if lowestFret >= 8 {
            positionName = "High Position (Fret \(lowestFret))"
        } else if lowestFret >= 4 {
            positionName = "Mid Position (Fret \(lowestFret))"
        } else {
            positionName = "Low Position (Fret \(lowestFret))"
        }
        
        // Determine difficulty
        let difficulty: String
        if isBarreChord && fretSpan >= 3 {
            difficulty = "Advanced"
        } else if isBarreChord || fretSpan >= 3 {
            difficulty = "Intermediate"
        } else if Set(nonZeroFrets).count >= 3 {
            difficulty = "Easy-Intermediate"
        } else {
            difficulty = "Beginner"
        }
        
        // Create string pattern description
        let stringPattern: String
        if usedStringCount == 6 {
            stringPattern = "All 6 strings"
        } else {
            let playedStrings = frets.enumerated().filter { $0.element != nil }.map { $0.offset + 1 }
            stringPattern = "\(usedStringCount) strings (\(playedStrings.map(String.init).joined(separator: ", ")))"
        }
        
        // Get inversion info
        let inversion = MusicTheory.getInversionInfo(
            rootNoteName: rootNote,
            shapeString: shape,
            chordType: chordType
        )
        
        // Generate tags
        var tags: [String] = []
        
        if hasOpenStrings {
            tags.append("Open Strings")
        }
        
        if isBarreChord {
            tags.append("Barre Chord")
        }
        
        if frets.contains(nil) {
            tags.append("Muted Strings")
        }
        
        if inversion.contains("Root Position") {
            tags.append("Root Position")
        } else if inversion.contains("Inversion") {
            tags.append(inversion)
        }
        
        if fretSpan >= 3 {
            tags.append("Wide Stretch")
        }
        
        return ChordShapeAttributes(
            positionName: positionName,
            difficulty: difficulty,
            stringPattern: stringPattern,
            inversion: inversion,
            tags: tags,
            fretPosition: lowestFret,
            usedStringCount: usedStringCount
        )
    }
    
    // Generate finger positions for a shape
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