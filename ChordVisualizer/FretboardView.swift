//
//  FretboardView.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//


import SwiftUI

// MARK: - Fretboard Drawing View

struct FretboardView: View {
    let shapeString: String
    let isLeftHanded: Bool
    let fingerPositions: [Int?]? // Optional array of finger positions (1-4 or nil)
    let highlightColor: Color? // Optional highlight color for this chord
    
    // Initialize with default parameters
    init(shapeString: String, isLeftHanded: Bool = false,
         fingerPositions: [Int?]? = nil, highlightColor: Color? = nil) {
        self.shapeString = shapeString
        self.isLeftHanded = isLeftHanded
        self.fingerPositions = fingerPositions
        self.highlightColor = highlightColor
    }

    // MARK: - Drawing Constants (Internal)
    private let numFretsDisplay = 9
    private let padXRatio: CGFloat = 0.05 // Padding relative to width
    private let padYRatio: CGFloat = 0.10 // Padding relative to height
    private let nutWidthRatio: CGFloat = 0.015 // Nut width relative to width
    private let dotRadiusFactor: CGFloat = 0.30 // Dot radius relative to string spacing
    private let markerRadiusFactor: CGFloat = 0.10
    private let openIndicatorRadiusFactor: CGFloat = 0.20
    private let fingerTextScale: CGFloat = 0.6 // Scale factor for finger number text

    // Colors
    private let bgColor = Color(hex: "#f4d03f") ?? .yellow // Ochre/Yellow
    private let fretColor = Color(hex: "#adadad") ?? .gray // Darker Grey
    private let markerColor = Color(hex: "#888888") ?? .gray // Dark Grey marker dots
    private let stringColor = Color(hex: "#eeeeee") ?? .gray.opacity(0.5) // Very light grey strings
    // Make dotColor a computed property that uses highlightColor or default blue
    private var dotColor: Color {
        return highlightColor ?? (Color(hex: "#3498db") ?? .blue)
    }
    private let openStringColor = Color(hex: "#3498db") ?? .blue // Blue for open indicators
    private let mutedStringColor = Color(hex: "#333333") ?? .black // Black 'X'
    private let nutColor = Color.black
    private let fingerTextColor = Color.white

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Use ZStack to build the view
                let width = geometry.size.width
                let height = geometry.size.height

                // Prevent division by zero or negative sizes during layout transitions
                if width <= 50 || height <= 50 {
                    Rectangle().fill(bgColor) // Placeholder if too small
                } else {
                    // Calculate dynamic spacing based on available geometry
                    let padX = width * padXRatio
                    let padY = height * padYRatio
                    let nutWidth = max(4, width * nutWidthRatio) // Ensure min width
                    let drawingWidth = width - (2 * padX) - nutWidth
                    let drawingHeight = height - (2 * padY)

                    // Ensure spacing is positive before proceeding
                    if drawingWidth <= 0 || drawingHeight <= 0 {
                        Rectangle().fill(bgColor)
                    } else {
                        let stringSpacing = drawingHeight / 5 // 5 spaces between 6 strings
                        let fretSpacing = drawingWidth / CGFloat(numFretsDisplay)
                        let dotRadius = max(2, stringSpacing * dotRadiusFactor)
                        let markerRadius = max(1, stringSpacing * markerRadiusFactor)
                        let openIndicatorRadius = max(2, stringSpacing * openIndicatorRadiusFactor)

                        // --- Canvas Drawing ---
                        Canvas { context, size in
                            // Draw background rectangle
                            context.fill(
                                Path(CGRect(x: 0, y: 0, width: width, height: height)),
                                with: .color(bgColor)
                            )
                            
                            // Parse the shape string into fret numbers (nil for 'x')
                            let frets = shapeString.split(separator: " ").map { Int(String($0)) } // nil if not Int or 'x'
                            if frets.count != 6 { // Ensure valid 6-string input
                                drawEmptyFretboard(context: context, size: size, stringSpacing: stringSpacing, fretSpacing: fretSpacing, nutWidth: nutWidth, padX: padX, padY: padY, markerRadius: markerRadius)
                                return
                            }

                            // 1. Draw Empty Board (background, frets, strings, markers)
                            drawEmptyFretboard(context: context, size: size, stringSpacing: stringSpacing, fretSpacing: fretSpacing, nutWidth: nutWidth, padX: padX, padY: padY, markerRadius: markerRadius)

                            // 2. Calculate Display Logic (which frets to show)
                            var minFret = 99, maxFret = 0, hasFrets = false
                            for fretOpt in frets {
                                if let fretNum = fretOpt, fretNum > 0 {
                                    hasFrets = true
                                    minFret = min(minFret, fretNum)
                                    maxFret = max(maxFret, fretNum)
                                }
                            }

                            var startFret = 1 // Fret number for the first visible fret line after the nut
                            if hasFrets && maxFret > numFretsDisplay {
                                startFret = max(1, minFret)
                                if startFret + numFretsDisplay - 1 < maxFret {
                                    startFret = maxFret - numFretsDisplay + 1
                                }
                            }

                            // 3. Draw Fret Number Indicator (if not starting at fret 1)
                            if startFret > 1 {
                                let fretNumX = padX + nutWidth + fretSpacing / 2
                                let indicatorY = padY * 0.5
                                context.draw(Text("\(startFret)").font(.system(size: 10, weight: .bold)).foregroundColor(.gray),
                                            at: CGPoint(x: fretNumX, y: indicatorY), anchor: .center) // Center anchor looks better
                            }

                            // 4. Draw Dots and Indicators (O/X)
                            let indicatorX = padX * 0.5 // X position for O/X indicators left of nut

                            for (i, fretOpt) in frets.enumerated() { // i = 0 (low E) to 5 (high e)
                                // Y increases downwards: high e (i=5) top, low E (i=0) bottom
                                let stringY = padY + CGFloat(5 - i) * stringSpacing

                                if fretOpt == nil { // Muted ('x')
                                    context.draw(Text("✕").font(.system(size: 12, weight: .bold)).foregroundColor(mutedStringColor),
                                                at: CGPoint(x: indicatorX, y: stringY), anchor: .center)
                                } else if let fretNum = fretOpt {
                                    if fretNum == 0 { // Open ('0')
                                        let openPath = Path { path in
                                            path.addEllipse(in: CGRect(x: indicatorX - openIndicatorRadius, y: stringY - openIndicatorRadius, width: openIndicatorRadius * 2, height: openIndicatorRadius * 2))
                                        }
                                        context.stroke(openPath, with: .color(openStringColor), lineWidth: 1.5)

                                    } else if fretNum > 0 { // Fretted note
                                        // Check if the fret is within the display range
                                        if fretNum >= startFret && fretNum < startFret + numFretsDisplay {
                                            let displayFret = fretNum - startFret + 1 // Which visible fret slot (1-based)
                                            // Calculate X position for the center of the fret
                                            let dotX = padX + nutWidth + (CGFloat(displayFret) - 0.5) * fretSpacing
                                            let dotRect = CGRect(x: dotX - dotRadius, y: stringY - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                                            context.fill(Path(ellipseIn: dotRect), with: .color(dotColor))
                                            
                                            // Draw finger number if available
                                            if let fingerPositions = fingerPositions,
                                               fingerPositions.count == 6,
                                               let fingerNum = fingerPositions[i],
                                               fingerNum > 0 && fingerNum <= 4 {
                                                context.draw(
                                                    Text("\(fingerNum)")
                                                        .font(.system(size: dotRadius * fingerTextScale, weight: .bold))
                                                        .foregroundColor(fingerTextColor),
                                                    at: CGPoint(x: dotX, y: stringY),
                                                    anchor: .center
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 5. Draw string labels (E, A, D, G, B, e)
                            let stringLabels = ["E", "A", "D", "G", "B", "e"]
                            let stringLabelX = width - padX * 0.4
                            
                            for i in 0..<6 {
                                let stringY = padY + CGFloat(i) * stringSpacing
                                context.draw(
                                    Text(stringLabels[5-i])
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(.gray),
                                    at: CGPoint(x: stringLabelX, y: stringY),
                                    anchor: .center
                                )
                            }
                        }
                        .scaleEffect(x: isLeftHanded ? -1 : 1, y: 1, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: - Drawing Helpers
    private func drawEmptyFretboard(context: GraphicsContext, size: CGSize, stringSpacing: CGFloat, fretSpacing: CGFloat, nutWidth: CGFloat, padX: CGFloat, padY: CGFloat, markerRadius: CGFloat) {
        let width = size.width
        let height = size.height
        
        // Sanity check to prevent division by zero
        guard width > 0, height > 0, stringSpacing > 0, fretSpacing > 0 else { return }

        let y1 = padY // Top string Y
        let y2 = height - padY // Bottom string Y
        let x2 = width - padX // Right edge for frets
        let nutXStart = padX
        let nutXEnd = padX + nutWidth
        let fretStartX = nutXEnd // Where frets begin

        // Nut (Black Vertical Line)
        context.fill(Path(CGRect(x: nutXStart, y: y1 - stringSpacing * 0.1, width: nutWidth, height: (y2 - y1) + stringSpacing * 0.2)), with: .color(nutColor))

        // Frets (Grey Vertical Lines)
        for i in 0...numFretsDisplay {
            let fretX = fretStartX + CGFloat(i) * fretSpacing
            if fretX <= x2 + 1 { // Only draw if within bounds
                var path = Path()
                path.move(to: CGPoint(x: fretX, y: y1))
                path.addLine(to: CGPoint(x: fretX, y: y2))
                context.stroke(path, with: .color(fretColor), lineWidth: 1)
            }
        }

        // Strings (Light Horizontal Lines)
        for i in 0..<6 { // i=0 (low E) to 5 (high e)
            let stringY = padY + CGFloat(i) * stringSpacing // Y increases downwards
            var path = Path()
            path.move(to: CGPoint(x: fretStartX, y: stringY))
            path.addLine(to: CGPoint(x: x2, y: stringY))
            // Increase thickness for lower strings
            let stringWeight = 1.0 + (0.4 * (5.0 - CGFloat(i)) / 5.0)
            context.stroke(path, with: .color(stringColor), lineWidth: stringWeight)
        }

        // Fret Markers (Single Grey Dots)
        let markerFrets = [3, 5, 7, 9, 12, 15, 17, 19, 21]
        let startFret = 1 // Assuming start fret 1 for markers for simplicity here

        for markerFret in markerFrets {
             if markerFret >= startFret && markerFret < startFret + numFretsDisplay {
                let displayFret = markerFret - startFret + 1
                let markerX = fretStartX + (CGFloat(displayFret) - 0.5) * fretSpacing
                let centerY = height / 2 // Vertical center of the fretboard area

                if markerX <= x2 { // Only draw if within bounds
                    let markerRect = CGRect(x: markerX - markerRadius, y: centerY - markerRadius, width: markerRadius * 2, height: markerRadius * 2)
                    if markerFret % 12 == 0 { // Double dot for 12th
                         let offset = stringSpacing * 0.8
                         let rect1 = markerRect.offsetBy(dx: 0, dy: -offset)
                         let rect2 = markerRect.offsetBy(dx: 0, dy: offset)
                         context.fill(Path(ellipseIn: rect1), with: .color(markerColor))
                         context.fill(Path(ellipseIn: rect2), with: .color(markerColor))
                    } else { // Single dot
                         context.fill(Path(ellipseIn: markerRect), with: .color(markerColor))
                    }
                }
            }
        }
    }
}
