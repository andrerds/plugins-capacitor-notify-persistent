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
    private var checkNotificationsTimer: Timer?
    private var engine: CHHapticEngine?
    private var playerObserver: NSKeyValueObservation?
    
    deinit {
        playerObserver?.invalidate()
        stopContinuousVibration()
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
        if let audioPath = Bundle.main.path(forResource: "sound_custom.caf", ofType: nil) {
            print("SHOULD HEAR AUDIO NOW", audioPath)
            let url = URL(fileURLWithPath: audioPath)

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop infinito
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
                stopContinuousVibration()
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
        vibrationTimer = Timer.scheduledTimer(
            timeInterval: 1.3,
            target: self,
            selector: #selector(vibrate),
            userInfo: nil,
            repeats: true)
        
        // Agendar a verificação regular das notificações
        checkNotificationsTimer?.invalidate()  // Invalidar o timer existente, se houver
        
        checkNotificationsTimer = Timer.scheduledTimer(
            timeInterval: 20.0,
            target: self,
            selector: #selector(checkForClearedNotifications), 
            userInfo: nil,
            repeats: true)
    }
    
    // Parar vibração contínua
    func stopContinuousVibration() {
        print("parando...")
        audioPlayer?.stop()
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        checkNotificationsTimer?.invalidate()
        checkNotificationsTimer = nil
    }
    
    // Verificar se as notificações da categoria ainda existem
    @objc private func checkForClearedNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.getDeliveredNotifications { notifications in
            // Verifique se há notificações entregues da categoria específica
            let category = "VISITOR_REQUEST"
            let hasNotifications = notifications.contains { $0.request.content.categoryIdentifier == category }
            
            if !hasNotifications {
                // Não há notificações da categoria específica, parar vibração e som
                self.stopContinuousVibration()
            }
        }
    }
}


