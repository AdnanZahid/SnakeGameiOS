//
//  AIHandler.swift
//  SnakeGameiOS
//
//  Created by AdnanZahid on 1/29/18.
//  Copyright © 2018 AdnanZahid. All rights reserved.
//

import CoreML

class AIHandler {
    
    let model = SnakeModel()
    
    func getPredictedDirection(snake: Snake, absoluteDirection: Direction, inputs: [CGFloat], grid: Grid, shufflePredictions: Bool) -> Direction {
    
        var prediction = 0.0
    
        var relativeDirections: [RelativeDirection] = [.left, .center, .right]
    
        if shufflePredictions {
            relativeDirections.shuffle()
        }
    
        var noMatchFound = false
        
        var relativeDirectionOutside: RelativeDirection = .left
        
        for relativeDirection in relativeDirections {
            relativeDirectionOutside = relativeDirection
            
            guard let multiArrayInputs = try? MLMultiArray(shape: [5], dataType: .double) else { fatalError("Input parsing error.") }
            for i in 0 ..< inputs.count { multiArrayInputs[i] = NSNumber(value: Double(inputs[i])) }
            multiArrayInputs[4] = NSNumber(value: relativeDirection.rawValue)
            guard let snakeModelOutput = try? model.prediction(input1: multiArrayInputs) else { fatalError("Output parsing error.") }
            prediction = snakeModelOutput.output1[0].doubleValue
            
            if prediction > 0.9 {
                break
            }
            noMatchFound = true
        }
        
        if noMatchFound && shufflePredictions {
            for relativeDirection in relativeDirections {
                relativeDirectionOutside = relativeDirection
                
                guard let multiArrayInputs = try? MLMultiArray(shape: [5], dataType: .double) else { fatalError("Input parsing error.") }
                for i in 0 ..< inputs.count { multiArrayInputs[i] = NSNumber(value: Double(inputs[i])) }
                multiArrayInputs[4] = NSNumber(value: relativeDirection.rawValue)
                guard let snakeModelOutput = try? model.prediction(input1: multiArrayInputs) else { fatalError("Output parsing error.") }
                prediction = snakeModelOutput.output1[0].doubleValue
                
                if prediction >= 0 {
                    break
                }
            }
        }
        
        switch absoluteDirection {
        case .right:
            switch relativeDirectionOutside {
                case .left: return .up
                case .center: return .right
                default: return .down
            }
        case .left:
            switch relativeDirectionOutside {
                case .left: return .down
                case .center: return .left
                default: return .up
            }
        case .up:
            switch relativeDirectionOutside {
                case .left: return .left
                case .center: return .up
                default: return .right
            }
        case .down:
            switch relativeDirectionOutside {
                case .left: return .right
                case .center: return .down
                default: return .left
            }
        }
    }
}
