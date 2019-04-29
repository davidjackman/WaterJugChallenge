//
//  ViewController.swift
//  WaterJugChallenge
//
//  Created by David Jackman on 4/22/19.
//  Copyright © 2019 David Jackman. All rights reserved.
//

import UIKit

class JugViewController: UIViewController {

    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    
    @IBOutlet weak var xField: UITextField!
    @IBOutlet weak var yField: UITextField!
    @IBOutlet weak var zField: UITextField!
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var autoButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var xJugView: UIView!
    @IBOutlet weak var yJugView: UIView!
    @IBOutlet weak var xWaterView: UIView!
    @IBOutlet weak var yWaterView: UIView!
    
    @IBOutlet weak var xHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yHeightConstraint: NSLayoutConstraint!
    
    lazy var controller = JugController(x: 8, y: 5, z: 3, solved: true)
    lazy var viewModel  = JugViewModel(controller: controller)
    lazy var animator   = JugAnimator(viewModel: viewModel, button: autoButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: JugViewModel.ViewModelChanged, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            self?.updateDisplay()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: JugViewModel.ViewModelChanged, object: nil)
    }
    
    /**
     Attempts to find a solution to the values in the `TextField`s using a `JugController`
     which is stored in the instance property `controller`
     
     This resets the `stepIndex` to -1
     */
    @IBAction func solve(_ sender: Any) {
        guard
            let xText = xField.text, let xValue = Int(xText),
            let yText = yField.text, let yValue = Int(yText),
            let zText = zField.text, let zValue = Int(zText) else { return }
        
        xField.resignFirstResponder()
        yField.resignFirstResponder()
        zField.resignFirstResponder()

        controller = JugController(x: xValue, y: yValue, z: zValue)
        viewModel  = JugViewModel(controller: controller)
        animator   = JugAnimator(viewModel: viewModel, button: autoButton)
        
        controller.solve()
        
        updateDisplay()
    }
    
    /**
     Toggles the automatic animation of the solution.

     This resets the animation if it had previously reached the end.

     - parameters:
        - sender: the button that invoked this method
     */
    @IBAction func auto(_ sender: UIButton) {
        animator.toggleAnimation()
    }

    /**
     Updates the `stepIndex` to the next index
     */
    @IBAction func next(_ sender: Any) {
        animator.next()
    }

    /**
     Updates the `stepIndex` to the previous index
     */
    @IBAction func previous(_ sender: Any) {
        animator.previous()
    }
    
    /**
     Updates the view with the values returned from the `viewModel`
    */
    func updateDisplay() {
        func updateXYLabels() {
            xLabel.text = viewModel.xLabelText
            yLabel.text = viewModel.yLabelText
        }
        
        func updateActionLabel() {
            actionLabel.text = viewModel.actionLabelText
        }
        
        func updateStepLabel() {
            stepLabel.text = viewModel.stepLabelText
        }
        
        func updateButtons() {
            nextButton.isEnabled     = viewModel.nextButtonIsEnabled
            previousButton.isEnabled = viewModel.previousButtonInEnabled
        }
        
        nextButton.isEnabled     = false
        previousButton.isEnabled = false
        
        // TODO: This pattern makes this look pretty ugly.....
        xHeightConstraint.constant = viewModel.xHeight(for: xJugView.bounds.height)
        yHeightConstraint.constant = viewModel.yHeight(for: yJugView.bounds.height)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.xJugView.layoutIfNeeded()
            self.yJugView.layoutIfNeeded()
            
            updateStepLabel()
            updateActionLabel()
            updateXYLabels()
        }) { (_) in
            updateButtons()
        }
    }

}

extension JugViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
