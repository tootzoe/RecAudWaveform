//
//  ContentView.swift
//  RecAudWaveform
//
//  Created by thor on 31/3/24
//  
//
//  Email: toot@tootzoe.com  Tel: +855 69325538 
//
//


 


import SwiftUI

import TAudioWaveform
 
 
    

struct ContentView: View {
    
    private var audioHandler = TAudioHandler()
  
    @StateObject private var waveformSrcObj =  WavformDatRoutor
    @State private var isRecording = false

    @State private var isShowRecWid = false
    
    @State private var currFilesCnt = URL.allFilesInDocDir.count
    
    
    private var wavDummy : URL {
        URL.temporaryDirectory.appendingPathComponent("wavdummy", conformingTo: .wav)
        
    }
    
    var body: some View {
        VStack {
            List{
                Section("Total files:"  ){
                    Text("Files count: \(currFilesCnt)")
                }
                
                ForEach(URL.allFilesInDocDir , id: \.url) { it in
                    TAudioListRow(url: it.url )
                        .swipeActions{
                            Button("delete"){
                                try?  FileManager.default.removeItem(at: it.url)
                                withAnimation {
                                    currFilesCnt = URL.allFilesInDocDir.count
                                }
                               
                            }.tint(.red)
                        }
                    
                }
                
            }
            
            Color.yellow
                .frame(width: 50,height: 50)
                .clipShape(Circle())
                .padding(30)
                .scaleEffect(CGSize(width: 2.0, height: 2.0))
                .scaleEffect(CGSize(width: isRecording ? 2.0 : 1.0, height: 1.0))
                .overlay(content: {
                    Image(systemName: isRecording ?  "mic.fill" : "mic" )
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fit)
                        .frame(width: 22)
                })
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ value in
                            withAnimation(.smooth(duration: 0.2)) {
                                isRecording = true
                            }
                        })
                        .onEnded({ value in
                            withAnimation(.bouncy(duration: 0.5)) {
                                isRecording = false
                            }
                        })
                ).onChange(of: isRecording) { _, isRec in
                    if isRec {
                        waveformSrcObj.wavformDat = []
                        startRec(wavDummy)
                        withAnimation {
                            isShowRecWid = true
                        }
                        
                    }else{
                        stopRec()
                       // currFilesCnt = URL.allFilesInDocDir.count
                        withAnimation {
                            isShowRecWid = false
                        }
                    }
                }
                  
            
            
            
            
        }
        .padding()
        .overlay {
            
            if isShowRecWid {
                ZStack{
                    Group{
                        RoundedRectangle(cornerRadius: 25.0)
                            .fill(.black)
                            .opacity(0.6)
                        
                        TAudioWaveWid(wavDat: waveformSrcObj.wavformDat , maxData: waveformSrcObj.wavformDat.count )
                            
                        
                    }
                }
                .frame(width: 300 , height: 200)
                }else{
                    EmptyView()
                }
            

        }
        
        
    }
    
    
    
    
    func startRec(_ wavUrl : URL)  {
 
        try? audioHandler.starRecM4a()
        try? audioHandler.starRecWav(wavUrl.path)
        
        
              DispatchQueue.global(qos: .userInitiated).async {
                  fifoReadWav(wavUrl.path()  )
              }
     
    }
    
    func stopRec()  {
        fifoReadWavExit( );
        
        audioHandler.stopRecM4a()
        audioHandler.stopRecWav()
    }
}


struct TFileItem {
    let url: URL
    let createDt : Date
}


extension URL {
    
   static    var allFilesInDocDir : [TFileItem] {
        
        let doc = URL.documentsDirectory
        
       // guard var files =  FileManager.default.subpaths(atPath: doc.path()) else {return[]}
       
     
       
       guard let femu =  FileManager.default.enumerator(at: doc, includingPropertiesForKeys: [.creationDateKey]) else {return[]}
       
       
       var rtnLs = [TFileItem]()
        
       for case let tmpUrl as URL in femu {
           guard let vals = try? tmpUrl.resourceValues(forKeys: [.creationDateKey]),
                 !tmpUrl.pathComponents.contains(".Trash")
           else {continue}
         //  print(tmpUrl)
          // print("dt: " , vals.creationDate)
           rtnLs.append(TFileItem(url: tmpUrl, createDt: vals.creationDate!))
       }
        
       return rtnLs .sorted {  $0.createDt > $1.createDt }
        
     
    }
    
}

#Preview {
    ContentView()
}
