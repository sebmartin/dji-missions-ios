//
//  TargetView.swift
//  DJI Missions
//
//  Created by Seb Martin on 2022-04-04.
//

import SwiftUI

struct Target: View {
    var size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: size / 15.0, antialiased: true)
            Circle()
                .frame(width: 4.0, height: 4.0, alignment: .center)
            HStack {
                Group{
                    VStack {
                        Triangle()
                            .rotation(Angle(degrees: 135))
                            .scale(1.2)
                        Triangle()
                            .rotation(Angle(degrees: 45))
                            .scale(1.2)
                    }
                    VStack {
                        Triangle()
                            .rotation(Angle(degrees: -135))
                            .scale(1.2)
                        Triangle()
                            .rotation(Angle(degrees: -45))
                            .scale(1.2)
                    }
                }
            }
        }.frame(width: size, height: size, alignment: .center)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}
