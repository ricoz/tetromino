//
//  Tetromino.swift
//  Bricks
//
//  Created by Rico Zuniga on 12/1/14.
//  Copyright (c) 2014 Ulap. All rights reserved.
//

import Foundation

enum Direction {
    case left, right, down, none
}

enum Rotation {
    case counterclockwise, clockwise
}

enum Shape {
    case I, O, T, J, L, S, Z
    
    static func randomShape() -> Shape {
        let shapes: [Shape] = [.I, .O, .T, .J, .L, .S, .Z]
        let count = UInt32(shapes.count)
        let randShape = Int(arc4random_uniform(count))
        return shapes[randShape]
    }
}

let bitmaps: [Shape: [[[Int]]]] = [
    .I: [[[0, 1], [0, 1], [0, 1], [0, 1]], [[0, 0, 0, 0], [1, 1, 1, 1]]],
    .O: [[[2, 2], [2, 2]]],
    .T: [[[3, 3, 3], [0, 3, 0], [0, 0, 0]], [[3, 0], [3, 3], [3, 0]], [[0, 0, 0], [0, 3, 0], [3, 3, 3]], [[0, 0, 3], [0, 3, 3], [0, 0, 3]]],
    .J: [[[0, 4, 4], [0, 4, 0], [0, 4, 0]], [[4, 0, 0], [4, 4, 4], [0, 0, 0]], [[0, 4, 0], [0, 4, 0], [4, 4, 0]], [[0, 0, 0], [4, 4, 4], [0, 0, 4]]],
    .L: [[[0, 5, 0], [0, 5, 0], [0, 5, 5]], [[0, 0, 5], [5, 5, 5], [0, 0, 0]], [[5, 5, 0], [0, 5, 0], [0, 5, 0]], [[0, 0, 0], [5, 5, 5], [5, 0, 0]]],
    .S: [[[0, 6, 0], [0, 6, 6], [0, 0, 6]], [[0, 0, 0], [0, 6, 6], [6, 6, 0]], [[0, 6, 0], [0, 6, 6], [0, 0, 6]], [[0, 0, 0], [0, 6, 6], [6, 6, 0]]],
    .Z: [[[0, 7, 0], [7, 7, 0], [7, 0, 0]], [[0, 0, 0], [7, 7, 0], [0, 7, 7]], [[0, 7, 0], [7, 7, 0], [7, 0, 0]], [[0, 0, 0], [7, 7, 0], [0, 7, 7]]]
]

class Tetromino {
    let shape = Shape.randomShape()
    
    var bitmap: [[Int]] {
        let bitmapSet = bitmaps[shape]!
        return bitmapSet[rotationalState]
    }
    
    var position = (x: 0, y: 0)
    
    private var rotationalState: Int
    
    init() {
        let bitmapSet = bitmaps[shape]!
        let count = UInt32(bitmapSet.count)
        rotationalState = Int(arc4random_uniform(count))
    }
    
    func moveTo(direction: Direction) {
        switch direction {
        case .left:
            position.x -= 1
        case .right:
            position.x += 1
        case .down:
            position.y += 1
        case .none:
            break
        }
    }
    
    func rotate(rotation: Rotation = .counterclockwise) {
        switch rotation {
        case .counterclockwise:
            let bitmapSet = bitmaps[shape]!
            if rotationalState + 1 == bitmapSet.count {
                rotationalState = 0
            } else {
                rotationalState += 1
            }
        case .clockwise:
            let bitmapSet = bitmaps[shape]!
            if rotationalState == 0 {
                rotationalState = bitmapSet.count - 1
            } else {
                rotationalState -= 1
            }
        }
    }
}
