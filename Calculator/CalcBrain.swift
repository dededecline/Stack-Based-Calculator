//
//  CalcBrain.swift
//  Calculator
//
//  Created by Daniel Klein on 7/12/15.
//  Copyright (c) 2015 Daniel H Klein. All rights reserved.
//

import Foundation

class CalcBrain {
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    
    private enum Op: Printable {
        case Operand(Double)
        case UnaryOp(String, Double -> Double)
        case BinaryOp(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOp(let symbol, _):
                    return symbol
                case .BinaryOp(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOp("+", +))
        learnOp(Op.BinaryOp("-") {$1 - $0})
        learnOp(Op.BinaryOp("×", *))
        learnOp(Op.BinaryOp("÷") {$1 / $0})
        learnOp(Op.UnaryOp("√", sqrt))
        learnOp(Op.UnaryOp("sin", sin))
        learnOp(Op.UnaryOp("cos", cos))
    }
    
    func clear() {
        opStack.removeAll(keepCapacity: false)
    }
    
    func pushOperand(operand: Double) -> Double?{
        opStack.append(Op.Operand(operand))
        return eval()
    }
    
    func performOp(symbol: String) -> Double?{
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return eval()
    }
    
    func eval() -> Double? {
        let (result, remainder) = eval(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    private func eval(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOp(_, let operation):
                let operandEval = eval(remainingOps)
                if let operand = operandEval.result {
                    return (operation(operand), operandEval.remainingOps)
                }
            case .BinaryOp(_, let operation):
                let op1Eval = eval(remainingOps)
                if let operand1 = op1Eval.result {
                    let op2Eval = eval(op1Eval.remainingOps)
                    if let operand2 = op2Eval.result {
                        return (operation(operand1, operand2), op2Eval.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
}