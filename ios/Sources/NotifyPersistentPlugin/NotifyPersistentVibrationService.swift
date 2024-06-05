//
//  NotifyPersistentVibrationService.swift
//  CapacitorNotifyPersistent
//
//  Created by André de Souza on 29/05/24.
//

import Foundation
import AVFoundation
import UIKit
import CoreHaptics

final class NotifyPersistentVibrationService {
    static let shared = NotifyPersistentVibrationService()
    private var audioPlayer: AVAudioPlayer?
    private var vibrationTimer: Timer?
    private var engine: CHHapticEngine?
    private var playerObserver: NSKeyValueObservation?
    
    deinit {
        playerObserver?.invalidate()
    }

    private init() {
        prepareHaptics()
    }
    
    // Configurar a sessão de áudio
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    // Iniciar reprodução do áudio silencioso
    private func startSilentAudio() {
        if let audioPath = Bundle.main.path(forResource: "out2.caf", ofType: nil) {
               print("SHOULD HEAR AUDIO NOW", audioPath)
               let url = URL(fileURLWithPath: audioPath)

               do {
                   audioPlayer = try AVAudioPlayer(contentsOf: url)
                   audioPlayer?.numberOfLoops = 0
                   audioPlayer?.prepareToPlay()
                   audioPlayer?.play()

                   // Adicionar observador para a propriedade 'isPlaying'
                   playerObserver = audioPlayer?.observe(\.isPlaying, options: [.new, .old]) { [weak self] (player, change) in
                       guard let self = self else { return }
                       if let isPlaying = change.newValue, !isPlaying {
                           print("Audio stopped playing")
                           self.stopContinuousVibration()
                       }
                   }
               } catch {
                   print("Couldn't load audio file")
                   audioPlayer?.stop()
               }
           } else {
               print("NOT FILE AUDIO")
           }
           
           if let player = audioPlayer, player.isPlaying {
               print("Audio is playing")
           } else {
               print("Audio is not playing")
               stopContinuousVibration()
           }
    }
    
    // Preparar o motor de háptica
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine Creation Error: \(error)")
        }
    }
    
    // Função para vibrar
    @objc private func vibrate() {
        let vibrationID: SystemSoundID = 4095
        AudioServicesPlaySystemSound(vibrationID)
    }
    
    // Iniciar vibração contínua
    func startContinuousVibration() {
        setupAudioSession()
        startSilentAudio()
        vibrationTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(vibrate), userInfo: nil, repeats: true)
    }
    
    // Parar vibração contínua
    func stopContinuousVibration() {
        print("parando...")
        audioPlayer?.stop()
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
}


