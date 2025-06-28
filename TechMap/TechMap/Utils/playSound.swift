//
//  playSound.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import Foundation
import AVFoundation

func playSound(named fileName: String) {
    guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: "m4a") else { return }
    
    do {
        let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
        audioPlayer.prepareToPlay()
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
        audioPlayer.play()
    } catch {
        print("Error playing sound: \(error)")
    }
}

