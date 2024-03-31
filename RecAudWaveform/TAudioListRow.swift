//
//  TAudioListRow.swift
//  RecWaveform
//
//  Created by thor on 29/3/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//



import SwiftUI
import AVFoundation

class TWaveformDat : ObservableObject {
  @Published    var wavformDat  =  [Double]()
}

struct TAudioListRow: View {
    
    let url : URL
    
   @StateObject var wfdat = TWaveformDat()
    
    var wavformDat  =  [Double]()
    
    @State private var wavFilePath = " "
    @State private var btnDisabled = false
    
    
    var body: some View {
        VStack(alignment: .leading){
            Text(url.lastPathComponent)
            ScrollView(.horizontal) {
                HStack {
                    Button{
                       // print("gen waveform....")
                        btnDisabled = true
                        wfdat.wavformDat = []
                      genWavform()
                        
                    }label: {
                        Image(systemName: "waveform.badge.plus")

                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green.opacity(0.4))
                    .onChange(of: wavFilePath) { _, nv in
                        if !nv.isEmpty {
                            genWavefor2(nv)
                        }
                        btnDisabled = false
                    }
                    .disabled(btnDisabled)
                    
                    TAudioWaveWid(wavDat: wfdat.wavformDat, maxData: wfdat.wavformDat.count)
                        .frame(minWidth: Double( wfdat.wavformDat.count) * 1.6  , minHeight: 64)
                        
                    Spacer()
                }
            }
            .overlay {
                if wavFilePath.isEmpty {
                    ProgressView()
                }else{
                    EmptyView()
                }
            }.overlay(alignment: .trailing) {
                Button(action: {}, label: {
                    Image(systemName: "play.rectangle")
                })
                .buttonStyle(.bordered)
            }
        }
    }
    
    
    
    public mutating func addWavformDat(_ dat : [Double]) {
        wavformDat.append(contentsOf: dat)
    }
    
    
    func genWavform(  )   {
        wavFilePath = ""
        
        if url.pathExtension.lowercased() == "wav" {
            Task{ @MainActor in
                wavFilePath = url.path()
            }
           
            return
        }
        
        
        let wavUrl = URL.temporaryDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .wav)
       
        Task{
            do{
                try   await  extraAudioAndSaveToWav(srcUrl: url, dstUrl: wavUrl)
                
            }catch{
                print(error.localizedDescription)
            }
            
        }
        
        try?  FileManager.default.removeItem(at: wavUrl)
    }
    
    func genWavefor2(_ wavPathName : String)  {
        
        let maxSecs = 60
        let buffSize = 40 * maxSecs * 2  // 1 second = 40, has 2 channels
        
        var wavformBuff = Array<Double>(repeating: 0, count: buffSize)
        
        let cnt   = genWavformByFile(wavPathName, 0, 60, &wavformBuff, Int32(wavformBuff.count))
        
        if cnt > 0 {
                wfdat.wavformDat =  Array(wavformBuff.prefix(cnt))
        }
        
       
    }
    
 
    ///   srcURL can be .mov, .mp4, .m4a
      func extraAudioAndSaveToWav( srcUrl: URL,   dstUrl : URL)   async  throws {
         
       
        let myAsset = AVAsset(url: srcUrl)
          
        // initialize asset reader, writer
         let assetReader = try AVAssetReader(asset: myAsset)
         let assetWriter = try AVAssetWriter(outputURL: dstUrl, fileType: .wav)
 
        
        // configure output audio settings
        let audioSettings: [String : Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
          let audioTrack = try   await myAsset.loadTracks(withMediaType: .audio).first
        
        guard let audioTrack = audioTrack   else {return}
        
        let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: audioSettings)
        

        
        if assetReader.canAdd(assetReaderAudioOutput) {
            assetReader.add(assetReaderAudioOutput)
        } else {
            fatalError("could not add audio output reader")
        }
     
        let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
         
        
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        assetWriter.add(audioInput)
        
        assetWriter.startWriting()
        assetReader.startReading()
        assetWriter.startSession(atSourceTime: CMTime.zero)
         
          audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while (audioInput.isReadyForMoreMediaData) {
                let sample = assetReaderAudioOutput.copyNextSampleBuffer()
                if (sample != nil) {
                    audioInput.append(sample!)
                } else {
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        assetWriter.finishWriting {
                            assetReader.cancelReading()
                            
                        }
                        Task { @MainActor in
                            try await Task.sleep(nanoseconds:30_000_000)
                            wavFilePath = dstUrl.path()
                        }
                        
                    }
                    break
                }
            }
        }
       
    }
 
}

#Preview {
    TAudioListRow(url: URL(fileURLWithPath: ""))
}
