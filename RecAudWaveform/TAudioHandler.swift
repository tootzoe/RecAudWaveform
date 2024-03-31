//
//  TAudioHandler.swift
//  SoxlibTest
//
//  Created by thor on 26/3/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import Foundation
import AVFoundation


class TAudioHandler : NSObject , ObservableObject , AVAudioRecorderDelegate {
    
    private var audioM4aDev : AVAudioRecorder?
    private var audioWavDev : AVAudioRecorder?
    private var recFolder = URL.documentsDirectory
    
    private var hasAudioSession = false
    
  
    
    
    #if os(iOS)
    private func setupAudioSession() throws {
        let audSess = AVAudioSession.sharedInstance()
        try audSess.setCategory(.playAndRecord, mode: .default)
        try audSess.setActive(true)
        hasAudioSession = true
    }
    
    public func starRecM4a( ) throws {
        let recSett : [String : Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        if !hasAudioSession {
            try setupAudioSession()
        }
         
        let fn =    Date.yyyyMMddHHmmss
      
        
        let recFilename = recFolder.appendingPathComponent("rec\(fn).m4a", conformingTo: .mpeg4Audio)
        
      //  print(recFilename)
        
      
        
        audioM4aDev = try AVAudioRecorder(url: recFilename, settings: recSett)
        audioM4aDev?.prepareToRecord()  // this call will write file type header data to disk, here write m4a meta data to file (written file can be found)
        
        audioM4aDev?.record()
       // print("M4a recording....")
         
    }
    
    
    public func starRecWav( _ fpath: String ) throws {
        
        if FileManager.default.fileExists(atPath: fpath) {
            do {
                try FileManager.default.removeItem(atPath: fpath)
            }catch{
                print(error.localizedDescription)
            }
        }
        
        let fn =  URL(fileURLWithPath: fpath , isDirectory: false)
         
        
        let recSett : [String : Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
           // AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        if !hasAudioSession {
            try setupAudioSession()
        }
     
        
        audioWavDev = try AVAudioRecorder(url: fn, settings: recSett)
        audioWavDev?.prepareToRecord() // this call will write file type header data to disk, here write wav header data to file (written file can be found)
        
        audioWavDev?.record()
       
         
       // print("Wav start recording  ....\(fn)")
         
    }
    
    
    #else
    
     public func starRecM4a( ) throws {
         
         let fn = URL.documentsDirectory.appendingPathComponent("rec\(Date.yyyyMMddHHmmss).m4a", conformingTo: .mpeg4Audio)
         
   
         let settings : [String : Any] = [AVFormatIDKey : kAudioFormatMPEG4AAC ,
                         AVSampleRateKey: 12000,
                  AVNumberOfChannelsKey : 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
         ]
         
         audioM4aDev = try AVAudioRecorder(url: fn, settings: settings)
         audioM4aDev?.delegate = self
         audioM4aDev?.prepareToRecord()
         
         audioM4aDev?.record()
          
         print("M4a start recording  ....\(fn)")
     }
    
    
    public func starRecWav(_ fpath: String) throws { 
 
        if FileManager.default.fileExists(atPath: fpath) {
           try? FileManager.default.removeItem(atPath: fpath)
        }
 
        
        let settings : [String : Any] = [AVFormatIDKey : kAudioFormatLinearPCM ,
                        AVSampleRateKey: 12000,
                 AVNumberOfChannelsKey : 2,
             
        ]
         
        
        audioWavDev = try AVAudioRecorder(url:  URL(fileURLWithPath: fpath) , settings: settings)
        audioWavDev?.delegate = self
        audioWavDev?.prepareToRecord()
        
        audioWavDev?.record()
         
        print("Wav start recording  ....\(fpath)")
    }
    
    
    #endif
    
    
    
      func stopRecM4a() {
          audioM4aDev?.stop()
         // print("M4a recording stopped....")
      }
      func stopRecWav() {
          audioWavDev?.stop()
         // print("Wav recording stopped....")
      }
  
    // MARK: -
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Audio recofing done........")
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("audio recording error: " , error?.localizedDescription ?? "")
    }
    
    
}

public extension Date {
    static  var yyyyMMddHHmmss : String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        return df.string(from: .now)
    }
}




















