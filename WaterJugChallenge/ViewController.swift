//
//  ViewController.swift
//  WaterJugChallenge
//
//  Created by David Jackman on 4/22/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
    @IBOutlet weak var xField: UITextField!
    @IBOutlet weak var yField: UITextField!
    @IBOutlet weak var zField: UITextField!
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    var controller: JugController?
    var stepIndex = -1 {
        didSet {
            guard stepIndex >= 0 else { displayInitialResults(); return }
            updateDisplay()
        }
    }
    
    @IBAction func go(_ sender: Any) {
        guard
            let xText = xField.text, let xValue = Int(xText),
            let yText = yField.text, let yValue = Int(yText),
            let zText = zField.text, let zValue = Int(zText) else { return }
        
        xField.resignFirstResponder()
        yField.resignFirstResponder()
        zField.resignFirstResponder()

        controller = JugController(x: xValue, y: yValue, z: zValue)
        controller?.solve()
        
        stepIndex = -1
    }
    
    @IBAction func next(_ sender: Any) {
        stepIndex += 1
    }

    @IBAction func previous(_ sender: Any) {
        stepIndex -= 1
    }
    
    func displayInitialResults() {
        nextButton.isEnabled     = controller?.steps.count ?? 0 > 0
        previousButton.isEnabled = false

        stepLabel.text   = "0/\(controller?.steps.count ?? 0)"
        xLabel?.text     = "0/\(controller?.state.x.capacity ?? 0)"
        yLabel?.text     = "0/\(controller?.state.y.capacity ?? 0)"
        actionLabel.text = controller?.steps.count == 0 ? "No\nSolution" : "Solved!"
    }
    
    func updateDisplay() {
        guard let c = controller, c.steps.count > stepIndex, c.states.count > stepIndex else { return }
        
        stepLabel.text = "\(stepIndex + 1)/\(c.steps.count)"
        
        let step = c.steps[stepIndex]
        
        switch step {
        case .empty(let i):
            actionLabel?.text = "Empty\n\(i)"
            
        case .fill(let i):
            actionLabel?.text = "Fill \(i)"
            
        case .transfer(let ft):
            actionLabel?.text = "Transfer\n\(ft.from) to \(ft.to)"
            
        }
        
        let state = c.states[stepIndex]
        xLabel?.text = "\(state.x.contents)/\(state.x.capacity)"
        yLabel?.text = "\(state.y.contents)/\(state.y.capacity)"
        
        nextButton.isEnabled     = stepIndex + 1 < c.steps.count
        previousButton.isEnabled = stepIndex >= 0
    }

}

