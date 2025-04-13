//
//  ChordAudioPlayer.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//


//
//  ChordAudioPlayer.swift
//  ChordVisualizer
//
//  Created by Ali Sami Gözükırmızı on 13.04.2025.
//

import Foundation
import AVFoundation
import SwiftUI

class ChordAudioPlayer: ObservableObject {
    private var audioPlayers: [AVAudioPlayer] = []
    private var isSetup = false
    @Published var isPlaying = false
    
    private var soundsDirectory: URL? {
        Bundle.main.url(forResource: "ChordSounds", withExtension: nil)
    }
    
    // Root note frequencies in Hz (A4 = 440Hz)
    private let rootNoteFrequencies: [String: Double] = [
        "A": 110.0,
        "A#": 116.54,
        "Bb": 116.54,
        "B": 123.47,
        "C": 130.81,
        "C#": 138.59,
        "Db": 138.59,
        "D": 146.83,
        "D#": 155.56,
        "Eb": 155.56,
        "E": 164.81,
        "F": 174.61,
        "F#": 185.0,
        "Gb": 185.0,
        "G": 196.0,
        "G#": 207.65,
        "Ab": 207.65
    ]
    
    // Play a chord using the notes in the chord
    func playChord(rootNote: String, chordType: String, voicing: String) {
        stopAllSounds()
        
        // Get the notes for this chord
        let (notes, _) = MusicTheory.getChordNotes(rootNoteName: rootNote, chordType: chordType)
        guard !notes.isEmpty else { return }
        
        // Parse the voicing to know which strings are played
        let frets = voicing.split(separator: " ").map { Int(String($0)) }
        guard frets.count == 6 else { return }
        
        // Create an array of frequencies to play
        var frequencies: [Double] = []
        
        // For each string that is played (not muted), calculate the frequency
        for (i, fretOpt) in frets.enumerated() {
            if let fret = fretOpt {
                // Get the base frequency of the open string
                let openStringNote = MusicTheory.getNoteName(
                    noteIndex: MusicTheory.openStringIndices[i],
                    preferSharp: true
                )
                
                if let openFreq = rootNoteFrequencies[openStringNote] {
                    // Calculate the frequency with the fret position
                    // Each fret increases frequency by a half step (multiply by 2^(1/12))
                    let freq = openFreq * pow(2.0, Double(fret) / 12.0)
                    frequencies.append(freq)
                }
            }
        }
        
        // Generate and play tones for each frequency
        for freq in frequencies {
            if let player = createTonePlayer(frequency: freq) {
                audioPlayers.append(player)
                player.play()
            }
        }
        
        isPlaying = true
    }
    
    // Create an audio player that generates a tone at the specified frequency
    private func createTonePlayer(frequency: Double, duration: Double = 1.0) -> AVAudioPlayer? {
        // Sample rate and amplitude
        let sampleRate = 44100.0
        let amplitude: Float = 0.25
        
        // Calculate a good buffer size
        let bufferLength = Int(duration * sampleRate)
        let audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )
        
        // Create a buffer
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: AVAudioFrameCount(bufferLength)) else {
            return nil
        }
        
        buffer.frameLength = buffer.frameCapacity
        
        // Get the audio buffer
        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
        
        // Fill the buffer with a sine wave
        for frame in 0..<Int(buffer.frameLength) {
            let value = sin(2.0 * .pi * frequency * Double(frame) / sampleRate)
            
            // Apply an envelope to avoid clicks (simple linear fade in/out)
            var envelope: Float = 1.0
            let fadeFrames = Int(0.01 * sampleRate) // 10ms fade
            
            if frame < fadeFrames {
                envelope = Float(frame) / Float(fadeFrames) // Fade in
            } else if frame > bufferLength - fadeFrames {
                envelope = Float(bufferLength - frame) / Float(fadeFrames) // Fade out
            }
            
            channels[0][frame] = Float(value) * amplitude * envelope
        }
        
        // Convert buffer to data
        do {
            let audioFile = try AVAudioFile(
                forWriting: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tone.caf"),
                settings: audioFormat!.settings
            )
            try audioFile.write(from: buffer)
            
            // Create a player with the generated file
            let player = try AVAudioPlayer(contentsOf: audioFile.url)
            return player
        } catch {
            print("Could not create audio file: \(error)")
            return nil
        }
    }
    
    // Stop all currently playing sounds
    func stopAllSounds() {
        for player in audioPlayers {
            if player.isPlaying {
                player.stop()
            }
        }
        audioPlayers.removeAll()
        isPlaying = false
    }
}

// MARK: - UI Component for Playing Chords
struct ChordPlayerView: View {
    let rootNote: String
    let chordType: String
    let shapeString: String
    @StateObject private var audioPlayer = ChordAudioPlayer()
    
    var body: some View {
        HStack {
            Button(action: {
                if audioPlayer.isPlaying {
                    audioPlayer.stopAllSounds()
                } else {
                    audioPlayer.playChord(
                        rootNote: rootNote,
                        chordType: chordType,
                        voicing: shapeString
                    )
                }
            }) {
                HStack {
                    Image(systemName: audioPlayer.isPlaying ? "stop.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding(8)
                }
                .background(Color(hex: "#3498db") ?? .blue)
                .cornerRadius(8)
            }
            
            Text("Play \(rootNote) \(chordType)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}