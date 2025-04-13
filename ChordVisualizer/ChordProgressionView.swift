//
//  ChordProgressionView.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//


//
//  ChordProgressionView.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//

import SwiftUI

struct ChordProgressionView: View {
    let chords: [(rootNote: String, chordType: String, shape: String)]
    let fingerPositions: [[Int?]?]
    let isLeftHanded: Bool
    let highlightColors: [Color]
    
    // Default initializer with optional parameters
    init(chords: [(rootNote: String, chordType: String, shape: String)], 
         fingerPositions: [[Int?]?] = [], 
         isLeftHanded: Bool = false,
         highlightColors: [Color] = []) {
        
        self.chords = chords
        self.isLeftHanded = isLeftHanded
        
        // Ensure finger positions array matches chords array length
        if fingerPositions.count == chords.count {
            self.fingerPositions = fingerPositions
        } else {
            self.fingerPositions = Array(repeating: nil, count: chords.count)
        }
        
        // Ensure colors array matches chords array length
        if highlightColors.count == chords.count {
            self.highlightColors = highlightColors
        } else {
            // Generate colors if none provided
            let defaultColors: [Color] = [
                Color(hex: "#3498db") ?? .blue,
                Color(hex: "#e74c3c") ?? .red,
                Color(hex: "#2ecc71") ?? .green,
                Color(hex: "#9b59b6") ?? .purple,
                Color(hex: "#f39c12") ?? .orange
            ]
            
            self.highlightColors = chords.enumerated().map { index, _ in
                defaultColors[index % defaultColors.count]
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Chord Progression")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            // Display chord names in a row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(0..<chords.count, id: \.self) { index in
                        let chord = chords[index]
                        ChordNameLabel(
                            rootNote: chord.rootNote,
                            chordType: chord.chordType,
                            highlightColor: highlightColors[index]
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Display chord diagrams in a row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<chords.count, id: \.self) { index in
                        let chord = chords[index]
                        VStack {
                            Text("\(chord.rootNote) \(chord.chordType)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(highlightColors[index])
                            
                            FretboardView(
                                shapeString: chord.shape,
                                isLeftHanded: isLeftHanded,
                                fingerPositions: fingerPositions[index],
                                highlightColor: highlightColors[index]
                            )
                            .frame(width: 100, height: 160)
                            .cornerRadius(8)
                            .shadow(color: highlightColors[index].opacity(0.3), radius: 3, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ChordNameLabel: View {
    let rootNote: String
    let chordType: String
    let highlightColor: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(rootNote)
                .font(.system(size: 16, weight: .bold))
            Text(chordType)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(highlightColor.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(highlightColor, lineWidth: 1.5)
        )
        .frame(minWidth: 60)
    }
}

struct ChordProgressionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleChords: [(String, String, String)] = [
            ("C", "Major", "x 3 2 0 1 0"),
            ("G", "Major", "3 2 0 0 0 3"),
            ("Am", "Minor", "x 0 2 2 1 0"),
            ("F", "Major", "1 3 3 2 1 1")
        ]
        
        let sampleFingers: [[Int?]] = [
            [nil, 3, 2, nil, 1, nil],
            [3, 2, nil, nil, nil, 4],
            [nil, nil, 2, 3, 1, nil],
            [1, 3, 4, 2, 1, 1]
        ]
        
        return ChordProgressionView(
            chords: sampleChords,
            fingerPositions: sampleFingers
        )
    }
}