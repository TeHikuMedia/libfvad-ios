//
//  VAD.swift
//  Whakahua
//
//  Created by Thomas Kiddle on 5/10/21.
//

import Foundation
import libfvad

class VAD{
    
    let inst: OpaquePointer
    let sampleRate:Int32
    let aggressiveness:Int32
    
    
    public init?(_ sampleRate:Int,_ agressiveness:Int) {
        guard let inst = fvad_new() else { return nil }
        self.inst = inst
        
        self.sampleRate = Int32(sampleRate)
        self.aggressiveness = Int32(agressiveness)
        
        //very aggressive
        guard fvad_set_mode(self.inst, self.aggressiveness) == 0 else {
            fatalError("Invalid value")
        }
        
        //16000hz
        guard fvad_set_sample_rate(inst, self.sampleRate) == 0 else {
            assertionFailure("Invalid value, should be 8000|16000|32000|48000")
            return
        }
    }
    
    public convenience init?(){
        self.init(16000,3)
    }
    
    ///  Calculates a VAD decision for an audio duration.
    ///
    /// - Parameter frames:  Array of signed 16-bit samples.
    /// - Parameter count:  Specify count of frames.
    ///                  Since internal processor supports only counts of 10, 20 or 30 ms,
    ///                  so for example at 16000 kHz, `count` must be either 160, 320 or 480.
    ///
    /// - Returns:  VAD decision.
    public func isSpeech(frames: UnsafePointer<Int16>, count: Int) -> Bool {
        
        switch fvad_process(inst, frames, count) {
        case 0:
            return false
        case 1:
            return true
        default:
            assertionFailure("Defaulted on fvad_process")
            return false
        }
    }
    
    deinit {
        // Frees the dynamic memory of a specified VAD instance.
        fvad_free(inst)
    }
    
}


