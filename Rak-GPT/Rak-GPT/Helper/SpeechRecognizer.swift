//
//  SpeechRecognizer.swift
//  Rak-GPT
//
//  Created by Macbook Pro on 17/05/25.
//

import Speech
import UIKit

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
    
    var recognizedText: String = ""
    var onTextUpdate: ((String) -> Void)?

    let speechRecognizer = SFSpeechRecognizer()
    let speechRequest = SFSpeechAudioBufferRecognitionRequest()
    var speechTask: SFSpeechRecognitionTask? = SFSpeechRecognitionTask()
    let audioEngine = AVAudioEngine()
    let audioSession = AVAudioSession.sharedInstance()
    
    var speechToText = ""
    
    func startSpeechRecognisation() {
        requestPermission()
        #if targetEnvironment(simulator)
            
        #else
            startAudioRecording()
            speechRecognize()
        #endif
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized {
                print("Authorized")
            } else {
                print(status)
            }
        }
    }
    
    func startAudioRecording() {
        let node = audioEngine.inputNode
        
        let format = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            self.speechRequest.append(buffer)
        }
        
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            audioEngine.prepare()
            
            try audioEngine.start()
        } catch {
            
        }
    }
    
    func speechRecognize() {
        
        guard let _ = SFSpeechRecognizer() else {
            print("recognizer not available")
            return
        }
        
        if (speechRecognizer?.isAvailable == false) {
            print("recognizer not available")
        }
        
        speechTask = speechRecognizer?.recognitionTask(with: speechRequest, resultHandler: { result, error in
        
            guard let result = result else {
                return
            }
            
            let recognizedText = result.bestTranscription.segments.last
            
            self.speechToText.append(" " + (recognizedText?.substring.capitalized ?? ""))
            
            DispatchQueue.main.async {
                self.recognizedText = self.speechToText
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.onTextUpdate?(self.recognizedText)
            }
        })
        
        
    }
}
