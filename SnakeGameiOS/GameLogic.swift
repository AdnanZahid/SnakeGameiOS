//
//  GameLogic.swift
//  SnakeGameiOS
//
//  Created by AdnanZahid on 1/29/18.
//  Copyright © 2018 AdnanZahid. All rights reserved.
//

import UIKit

class GameLogic {
    
    static func getSnakeNodes(x: Int, y: Int, grid: inout Grid) -> Snake {
        // Create initial snake
        var snake: Snake = []
        for i in 0 ..< snakeInitialSize {
            let segment = SnakeNode(x: x + i, y: y)
            snake.append(segment)
        }
        
        grid[x][y] = .snakeHead
        for i in 1 ..< snake.count {
            grid[snake[i].x][snake[i].y] = .wall
        }
        
        return snake
    }
    
    static func getGrownSnake(snake: Snake, direction: Direction, grid: inout Grid) -> Snake {
        
        guard let tail = snake.last else { return [] }
        
        let newTail: SnakeNode
        var newSnakeNodes = snake
        
        switch direction {
        case .right:
            newTail = SnakeNode(x: tail.x - 1, y: tail.y)
        case .left:
            newTail = SnakeNode(x: tail.x + 1, y: tail.y)
        case .up:
            newTail = SnakeNode(x: tail.x, y: tail.y + 1)
        case .down:
            newTail = SnakeNode(x: tail.x, y: tail.y-1)
        }
        
        grid[newTail.x][newTail.y] = .wall
        
        newSnakeNodes.append(newTail)
        
        return newSnakeNodes
    }
    
    static func advanceSnake(snake: Snake, direction: Direction, grid: inout Grid) -> Snake {
        var newSnakeNodes = snake
        guard let head = newSnakeNodes.first else { return [] }
        guard let tail = newSnakeNodes.popLast() else { return [] }
        
        grid[tail.x][tail.y] = .empty
        
        switch direction {
        case .up:
            tail.x = head.x
            tail.y = head.y + 1
        case .down:
            tail.x = head.x
            tail.y = head.y - 1
        case .left:
            tail.x = head.x - 1
            tail.y = head.y
        case .right:
            tail.x = head.x + 1
            tail.y = head.y
        }
        
        newSnakeNodes.insert(tail, at: 0)
        
        if grid[tail.x][tail.y] != .food && grid[tail.x][tail.y] != .wall {
            grid[tail.x][tail.y] = .snakeHead
        }
        
        for i in 1 ..< newSnakeNodes.count {
            grid[newSnakeNodes[i].x][newSnakeNodes[i].y] = .wall
        }
        
        return newSnakeNodes
    }
    
    static func getOrthogonalAngle(snake: Snake, foodX: Int, foodY: Int, absoluteDirection: Direction) -> CGFloat {
        guard let head = snake.first else { return 0.0 }
        
        let base = foodX - head.x
        let perpendicular = foodY - head.y
        
        let hypotenuse = sqrt(Double(base ** 2 + perpendicular ** 2)) + 0.00001
        
        var angle = asin(Double(perpendicular) / hypotenuse).radiansToDegrees
        
        angle = ((angle + 360).truncatingRemainder(dividingBy: 360)).truncatingRemainder(dividingBy: 90)
        
        if absoluteDirection == Direction.right {
            if base >= 0 && perpendicular >= 0      { angle = angle + 0 }
            else if base <= 0 && perpendicular >= 0 { angle = angle + 90 }
            else if base <= 0 && perpendicular <= 0 { angle = angle + 90 }
            else                                    { angle = angle + 0 }
        } else if absoluteDirection == Direction.up {
            if base >= 0 && perpendicular >= 0      { angle = angle + 0 }
            else if base <= 0 && perpendicular >= 0 { angle = angle + 0 }
            else if base <= 0 && perpendicular <= 0 { angle = angle + 90 }
            else                                    { angle = angle + 90 }
        } else if absoluteDirection == Direction.left {
            if base >= 0 && perpendicular >= 0      { angle = angle + 90 }
            else if base <= 0 && perpendicular >= 0 { angle = angle + 0 }
            else if base <= 0 && perpendicular <= 0 { angle = angle + 0 }
            else                                    { angle = angle + 90 }
        } else {
            if base >= 0 && perpendicular >= 0      { angle = angle + 90 }
            else if base <= 0 && perpendicular >= 0 { angle = angle + 90 }
            else if base <= 0 && perpendicular <= 0 { angle = angle + 0 }
            else                                    { angle = angle + 0 }
        }
        
        return CGFloat(angle - 90).degreesToRadians / (.pi/2)
    }
    
    static func getNeighboringNodes(snake: Snake, absoluteDirection: Direction, grid: Grid) -> (NodeType, NodeType, NodeType) {
        guard let head = snake.first else { return (.empty, .empty, .empty) }
        
        switch absoluteDirection {
        case .right:
            return (grid[head.x][head.y - 1], grid[head.x + 1][head.y], grid[head.x][head.y + 1])
        case .left:
            return (grid[head.x][head.y + 1], grid[head.x - 1][head.y], grid[head.x][head.y - 1])
        case .up:
            return (grid[head.x - 1][head.y], grid[head.x][head.y - 1], grid[head.x + 1][head.y])
        case .down:
            return (grid[head.x + 1][head.y], grid[head.x][head.y + 1], grid[head.x - 1][head.y])
        }
    }
    
    static func areNeighboringNodesBlocked(nodes: (NodeType, NodeType, NodeType)) -> (Int, Int, Int) {
        let leftBlocked = (nodes.0 == NodeType.wall)
        let centerBlocked = (nodes.1 == NodeType.wall)
        let rightBlocked = (nodes.2 == NodeType.wall)
        
        return (leftBlocked.intValue(), centerBlocked.intValue(), rightBlocked.intValue())
    }
    
    static func neuralInputs(snake: Snake, grid: Grid, absoluteDirection: Direction, foodX: Int, foodY: Int) -> [CGFloat] {
        
        let angle = getOrthogonalAngle(snake: snake, foodX: foodX, foodY: foodY, absoluteDirection: absoluteDirection)
        let neighboringNodes = getNeighboringNodes(snake: snake, absoluteDirection: absoluteDirection, grid: grid)
        let neighboringNodesBlocked = areNeighboringNodesBlocked(nodes: neighboringNodes)
        
        return [CGFloat(neighboringNodesBlocked.0), CGFloat(neighboringNodesBlocked.1), CGFloat(neighboringNodesBlocked.2), angle]
    }
    
    static func getGrid(columns: Int, rows: Int) -> Grid {
        var grid = Grid(repeating: [NodeType](repeating: .empty, count: rows), count: columns)
        
        for x in 0 ..< columns {
            grid[x][0] = NodeType.wall
            grid[x][rows-1] = NodeType.wall
        }
        
        for y in 0 ..< rows {
            grid[0][y] = NodeType.wall
            grid[columns-1][y] = NodeType.wall
        }
        
        return grid
    }
    
    static func generateFood(columns: Int, rows: Int, grid: inout Grid) -> (Int, Int) {
        let foodX = Int.random(lower: 1, upper: columns - snakeInitialSize - 1)
        let foodY = Int.random(lower: 1, upper: rows - snakeInitialSize - 1)
        
        grid[foodX][foodY] = .food
        
        return (foodX, foodY)
    }    
    
    static func resetStuckPositionGrid(columns: Int, rows: Int) -> [[Int]] {
        return StuckPositionGrid(repeating: [Int](repeating: 0, count: rows), count: columns)
    }
    
    static func checkForFoodCollision(snake: Snake, grid: Grid) -> Bool {
        guard let head = snake.first else { return false }
        return grid[head.x][head.y] == NodeType.food
    }
}
