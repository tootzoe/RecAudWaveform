//
//  TAudioWaveWid.swift
//  testsoxlib
//
//  Created by thor on 6/3/24
//
//
//  Email: toot@tootzoe.com  Tel: +855 69325538
//
//



import SwiftUI

 


struct TAudioWaveWid: View {
     
    let wavDat : [Double]
    
    let maxData : Int
     
    
    var body: some View {
 
            
            Canvas{ ctx , sz in
                
                var lines = Path()
                
                
                let midY = sz.height / 2.0
                
                guard wavDat.count > 1 else { return }
                
                let xInc = sz.width / Double( maxData / 2 )
                
                var posIdx = 0
                
                var timestep = 0.0
                
                repeat{
                    
                    let wavL =  wavDat[posIdx]
                    let wavR = wavDat[posIdx + 1]
                    posIdx += 2
                    
                    
                    let pLeft  = CGPoint(x: Double(timestep), y: midY - midY * wavL )
                    let pRight = CGPoint(x: Double(timestep), y: wavR * midY + midY )
                    
                    lines.move(to: pLeft)
                    lines.addLine(to: pRight)
                    
                    
                    timestep += xInc
                    
                    ctx.stroke(lines, with: .color(.green))
                    
                    
                } while  posIdx <   wavDat.count - 1
                
                
            }
 
    }
    
}

#Preview {
    TAudioWaveWid( wavDat: [2,3] , maxData: 200)
    
}
