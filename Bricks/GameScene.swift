//
//  GameScene.swift
//  Bricks
//
//  Created by Rico Zuniga on 12/1/14.
//  Copyright (c) 2014 Ulap. All rights reserved.
//

import SpriteKit

let colors: [SKColor] = [
    SKColor.lightGrayColor(),
    SKColor.cyanColor(),
    SKColor.yellowColor(),
    SKColor.magentaColor(),
    SKColor.blueColor(),
    SKColor.orangeColor(),
    SKColor.greenColor(),
    SKColor.redColor(),
    SKColor.darkGrayColor()
]

let gameBitmapDefault: [[Int]] = [
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8],
    [8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8]
]

let blockSize: CGFloat = 18.0
let defaultSpeed = NSTimeInterval(1200)

class GameScene: SKScene {
    var dropTime = defaultSpeed
    var lastUpdate:NSDate?
    
    let gameBoard = SKSpriteNode()
    let nextTetrominoDisplay = SKSpriteNode()
    
    var activeTetromino = Tetromino()
    var nextTetromino = Tetromino()
    
    var gameBitmapDynamic = gameBitmapDefault
    var gameBitmapStatic = gameBitmapDefault
    
    let scoreLabel = SKLabelNode()
    let levelLabel = SKLabelNode()
    
    var score = 0
    var level = 1
    var nextLevel = 3000

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.anchorPoint = CGPoint(x: 0, y: 1.0)

        gameBoard.anchorPoint = CGPoint(x: 0, y: 1.0)
        for col in 0..<gameBitmapDefault[0].count {
            for row in 0..<gameBitmapDefault.count {
                let bit = gameBitmapDefault[row][col]
                let square = SKSpriteNode(color: colors[bit], size: CGSize(width: blockSize, height: blockSize))
                square.anchorPoint = CGPoint(x: 0, y: 0)
                square.position = CGPoint(x: col * Int(blockSize) + col, y: -row * Int(blockSize) + -row)
                gameBoard.addChild(square)
            }
        }
        
        let gameBoardFrame = gameBoard.calculateAccumulatedFrame()
        gameBoard.position = CGPoint(x: CGRectGetMidX(self.frame) - gameBoardFrame.width / 2, y: -125)
        self.addChild(gameBoard)
        
        centerActiveTetromino()
        refresh()
        lastUpdate = NSDate()
        
        nextTetrominoDisplay.anchorPoint = CGPoint(x: 0, y: 1.0)
        showNextTetromino()
        
        updateScoreWith(points: 0)
    }
    
    func centerActiveTetromino() {
        let cols = gameBitmapDefault[0].count
        let brickWidth = activeTetromino.bitmap[0].count
        activeTetromino.position = (cols / 2 -  brickWidth, 0)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let gameBoardFrame = gameBoard.calculateAccumulatedFrame()
            
            if location.x < gameBoardFrame.origin.x {
                moveTetrominoTo(.Left)
            } else if location.x > gameBoardFrame.origin.x + gameBoardFrame.width {
                moveTetrominoTo(.Right)
            } else if CGRectContainsPoint(gameBoardFrame, location) {
                rotateTetromino()
            } else if location.y < gameBoardFrame.origin.y {
                instaDrop()
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if lastUpdate != nil {
            let elapsed = lastUpdate!.timeIntervalSinceNow * -1000.0
            if elapsed > dropTime {
                moveTetrominoTo(.Down)
            }
        }
    }
    
    func moveTetrominoTo(direction: Direction) {
        if collidedWith(direction) == false {
            activeTetromino.moveTo(direction)
            
            if direction == .Down {
                updateScoreWith()
                lastUpdate = NSDate()
            }
        } else {
            if direction == .Down {
                didLand()
                return
            }
        }
        
        refresh()
    }
    
    func rotateTetromino() {
        activeTetromino.rotate()
        
        if collidedWith(.None) {
            activeTetromino.rotate(rotation: .Clockwise)
        } else {
            refresh()
        }
    }
    
    func collidedWith(direction: Direction) -> Bool {
        func collided(x: Int, y: Int) -> Bool {
            for row in 0..<activeTetromino.bitmap.count {
                for col in 0..<activeTetromino.bitmap[row].count {
                    if activeTetromino.bitmap[row][col] > 0 && gameBitmapStatic[y + row][x + col + 1] > 0 {
                        return true
                    }
                }
            }
            
            return false
        }
        
        let x = activeTetromino.position.x
        let y = activeTetromino.position.y
        
        switch direction {
        case .Left:
            return collided(x - 1, y)
        case .Right:
            return collided(x + 1, y)
        case .Down:
            return collided(x, y + 1)
        case .None:
            return collided(x, y)
        }
    }
    
    func clearLines() {
        var linesToClear = [Int]()
        for row in 0..<gameBitmapDynamic.count - 1 {
            var isLine = true
            for col in 0..<gameBitmapDynamic[0].count {
                if gameBitmapDynamic[row][col] == 0 {
                    isLine = false
                }
            }
            
            if isLine {
                linesToClear.append(row)
            }
        }
        
        if linesToClear.count > 0 {
            for line in linesToClear {
                gameBitmapDynamic.removeAtIndex(line)
                gameBitmapDynamic.insert([8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8], atIndex: 1)
            }
            
            var multiplier = linesToClear.count == 4 ? 10 : 1
            updateScoreWith(points: linesToClear.count * linesToClear.count * linesToClear.count)
        }
    }
    
    func instaDrop() {
        while collidedWith(.Down) == false {
            updateScoreWith(points: 2)
            activeTetromino.moveTo(.Down)
            updateGameBitmap()
            
        }
        didLand()
    }
    
    func didLand() {
        clearLines()
        
        gameBitmapStatic.removeAll(keepCapacity: true)
        gameBitmapStatic = gameBitmapDynamic
        
        activeTetromino = nextTetromino
        centerActiveTetromino()
        
        nextTetromino = Tetromino()
        showNextTetromino()
        
        refresh()
        lastUpdate = NSDate()
    }
    
    func refresh() {
        updateGameBitmap()
        updateGameBoard()
    }
    
    func updateGameBitmap() {
        gameBitmapDynamic.removeAll(keepCapacity: true)
        gameBitmapDynamic = gameBitmapStatic
        
        for row in 0..<activeTetromino.bitmap.count {
            for col in 0..<activeTetromino.bitmap[row].count {
                if activeTetromino.bitmap[row][col] > 0 {
                    gameBitmapDynamic[activeTetromino.position.y + row][activeTetromino.position.x + col + 1] = activeTetromino.bitmap[row][col]
                }
            }
        }
    }
    
    func updateGameBoard() {
        let squares = gameBoard.children as [SKSpriteNode]
        var currentSquare = 0
        
        for col in 0..<gameBitmapDynamic[0].count {
            for row in 0..<gameBitmapDynamic.count {
                let bit = gameBitmapDynamic[row][col]
                let square = squares[currentSquare]
                if square.color != colors[bit] {
                    square.color = colors[bit]
                }
                ++currentSquare
            }
        }
    }
    
    func showNextTetromino() {
        nextTetrominoDisplay.removeAllChildren()
        
        for row in 0..<nextTetromino.bitmap.count {
            for col in 0..<nextTetromino.bitmap[row].count {
                if nextTetromino.bitmap[row][col] > 0 {
                    let bit = nextTetromino.bitmap[row][col]
                    let square = SKSpriteNode(color: colors[bit], size: CGSize(width: blockSize, height: blockSize))
                    square.anchorPoint = CGPoint(x: 0, y: 1.0)
                    square.position = CGPoint(x: col * Int(blockSize) + col, y: -row * Int(blockSize) + -row)
                    nextTetrominoDisplay.addChild(square)
                }
            }
        }
        
        let nextTetrominoDisplayFrame = nextTetrominoDisplay.calculateAccumulatedFrame()
        let gameBoardFrame = gameBoard.calculateAccumulatedFrame()
        nextTetrominoDisplay.position = CGPoint(x: gameBoardFrame.origin.x + gameBoardFrame.width - nextTetrominoDisplayFrame.width, y: -30)
        
        if nextTetrominoDisplay.parent == nil {
            self.addChild(nextTetrominoDisplay)
        }
    }
    
    func updateScoreWith(points: Int = 1) {
        if scoreLabel.parent == nil && levelLabel.parent == nil {
            let gameBoardFrame = gameBoard.calculateAccumulatedFrame()
            
            scoreLabel.text = "Score: \(score)"
            scoreLabel.fontSize = 20.0
            scoreLabel.fontColor = SKColor.whiteColor()
            scoreLabel.horizontalAlignmentMode = .Left
            scoreLabel.position = CGPoint(x: gameBoardFrame.origin.x, y: -scoreLabel.frame.height - 50)
            self.addChild(scoreLabel)
            
            levelLabel.text = "Level: \(level)"
            levelLabel.fontSize = 20.0
            levelLabel.fontColor = SKColor.whiteColor()
            levelLabel.horizontalAlignmentMode = .Left
            levelLabel.position = CGPoint(x: scoreLabel.frame.origin.x, y: -levelLabel.frame.height - scoreLabel.frame.height - 50 - 10)
            self.addChild(levelLabel)
        }
        
        score += points * level * level
        scoreLabel.text = "Score: \(score)"
        
        if score > nextLevel {
            levelLabel.text = "Level: \(++level)"
            nextLevel = Int(2.5 * Double(nextLevel))
            
            if dropTime - 150 <= 0 {
                // Maximum speed
                dropTime = 100
            } else {
                dropTime -= 150
            }
        }
    }
}
