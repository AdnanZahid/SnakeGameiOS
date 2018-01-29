//
//  GameScene.swift
//  SnakeGameiOS
//
//  Created by AdnanZahid on 1/29/18.
//  Copyright © 2018 AdnanZahid. All rights reserved.
//

import SpriteKit

enum Direction {
    case left, right, up, down
}

enum NodeType {
    case empty, snakeHead, food, wall
}

enum RelativeDirection: Int {
    case left = -1
    case center = 0
    case right = 1
}

typealias Grid = [[NodeType]]
typealias GridViews = [[SKSpriteNode]]
typealias StuckPositionGrid = [[Int]]
typealias Snake = [SnakeNode]

let blockSize = 10
let screenColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
let wallColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
let snakeColor = UIColor(red: 0, green: 255/255, blue: 255/255, alpha: 1)
let foodColor = UIColor(red: 0, green: 255/255, blue: 0, alpha: 1)

let snakeInitialSize = 1

class GameScene: SKScene {
    
    let aiHandler = AIHandler()
    var direction: Direction = .right
    var snake: Snake = []
    var foodPosition = (-1, -1)
    var grid: Grid = [[]]
    var gridViews: [[SKSpriteNode]] = [[]]
    
    var deathCount = 0
    var scoreCount = 0
    
    let deathCountLabel = SKLabelNode()
    let scoreCountLabel = SKLabelNode()
    
    var stuckPositionGrid: StuckPositionGrid = [[]]
    
    func isGameOver(snake: Snake, grid: Grid, columns: Int, rows: Int) -> Bool {
        guard let head = snake.first else { return true }
        
        return grid[head.x][head.y] == NodeType.wall
                          || head.x == 0
                          || head.y == 0
                          || head.x == columns - 1
                          || head.y == rows - 1
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        deathCountLabel.fontSize = 20
        scoreCountLabel.fontSize = 20
        
        deathCountLabel.position = CGPoint(x: 100, y: frame.maxY - deathCountLabel.frame.height - 50)
        scoreCountLabel.position = CGPoint(x: frame.maxX - scoreCountLabel.frame.width - 100, y: frame.maxY - scoreCountLabel.frame.height - 50)
        
        addChild(deathCountLabel)
        addChild(scoreCountLabel)
        
        initializeGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        let columns = Int(frame.width) / blockSize
        let rows = Int(frame.height) / blockSize
        
        if !isGameOver(snake: snake, grid: grid, columns: columns, rows: rows) {
            deathCountLabel.text = "Deaths: \(deathCount)"
            scoreCountLabel.text = "Score: \(scoreCount)"
            
            fillNodes(columns: columns, rows: rows, grid: grid)
            
            // If snake gets stuck in the same position for too long (5 times), shuffle the predictions
            guard let head = snake.first else { return }
            stuckPositionGrid[head.x][head.y] += 1
            let shufflePredictions = stuckPositionGrid[head.x][head.y] > 5
            
            let inputs = GameLogic.neuralInputs(snake: snake, grid: grid, absoluteDirection: direction, foodX: foodPosition.0, foodY: foodPosition.1)
            direction = aiHandler.getPredictedDirection(snake: snake, absoluteDirection: direction, inputs: inputs, grid: grid, shufflePredictions: shufflePredictions)
            snake = GameLogic.advanceSnake(snake: snake, direction: direction, grid: &grid)
            
            if GameLogic.checkForFoodCollision(snake: snake, grid: grid) {
                scoreCount += 1
                foodPosition = GameLogic.generateFood(columns: columns, rows: rows, grid: &grid)
                stuckPositionGrid = GameLogic.resetStuckPositionGrid(columns: columns, rows: rows)
                snake = GameLogic.getGrownSnake(snake: snake, direction: direction, grid: &grid)
            }
        
        } else {
            deathCount += 1
            initializeGame()
        }
    }
    
    func initializeGame() {
        let columns = Int(frame.width) / blockSize
        let rows = Int(frame.height) / blockSize
    
        grid = GameLogic.getGrid(columns: columns, rows: rows)
        gridViews = GridViews(repeating: [SKSpriteNode](repeating: SKSpriteNode(), count: rows), count: columns)
        stuckPositionGrid = StuckPositionGrid(repeating: [Int](repeating: 0, count: rows), count: columns)
    
        deathCountLabel.text = "Deaths: \(deathCount)"
        scoreCountLabel.text = "Score: \(scoreCount)"
    
        initializeViews(columns: columns, rows: rows)
    
        scoreCount = 0
        let directions: [Direction] = [.right, .left, .up, .down]
        direction = directions[Int.random(lower: 0, upper: directions.count - 1)]
    
        let snakeX = Int.random(lower: 1, upper: columns - snakeInitialSize - 1)
        let snakeY = Int.random(lower: 1, upper: rows - snakeInitialSize - 1)
    
        foodPosition = GameLogic.generateFood(columns: columns, rows: rows, grid: &grid)
        snake = GameLogic.getSnakeNodes(x: snakeX, y: snakeY, grid: &grid)
        stuckPositionGrid = GameLogic.resetStuckPositionGrid(columns: columns, rows: rows)
    }
    
    func fillNode(x: Int, y: Int, grid: Grid) {
        
        let color: UIColor
        
        switch grid[x][y] {
        case .snakeHead: color = snakeColor
        case .food: color = foodColor
        case .wall: color = wallColor
        case .empty: color = screenColor
        }
        
        gridViews[x][y].color = color
    }
    
    func fillNodes(columns: Int, rows: Int, grid: Grid) {
        for x in 0 ..< columns {
            for y in 0 ..< rows {
                fillNode(x: x,y: y, grid: grid)
            }
        }
    }
    
    func initializeViews(columns: Int, rows: Int) {
        for x in 0 ..< columns {
            for y in 0 ..< rows {
                let view = SKSpriteNode(color: screenColor, size: CGSize(width: blockSize, height: blockSize))
                view.position.x = CGFloat(x * blockSize)
                view.position.y = CGFloat(y * blockSize)
                gridViews[x][y] = view
                addChild(view)
            }
        }
    }
}
