//
//  ViewController.swift
//  Dicee
//
//  Created by Cesar Enrique Mora Guerra on 10/3/18.
//  Copyright © 2018 Cesar Enrique Mora Guerra. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    //MARK: - Variables Globales
    var diceArray = [SCNNode()]
    @IBOutlet var sceneView: ARSCNView!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.autoenablesDefaultLighting = true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    
    
    //MARK: -Funcion para detectar los toques de el usuario
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first
            {
                addDice(atLocation: hitResult)
            }
        }
    }
    
    
    
    //MARK: - Añadir dados
    func addDice (atLocation location: ARHitTestResult)
    {
        //Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/ship.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true)
        {
            diceNode.position = SCNVector3(
                /* X */     location.worldTransform.columns.3.x,
                /* Y */     location.worldTransform.columns.3.y + (diceNode.boundingSphere.radius * 2),
                /* Z */     location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }

    
    
    //MARK: - Funcion girar dados
    func roll(dice : SCNNode)
    {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 3),
            y: 0,
            z: CGFloat(randomZ * 3),
            duration: 0.5)
        )
    }
    
    
    
    //MARK: - Funcion Girar todos
    func rollAll()
    {
        if !diceArray.isEmpty{
            for dice in diceArray
            {
                roll(dice: dice)
            }
        }
    }
    
    

    @IBAction func quitarTodo(_ sender: UIBarButtonItem)
    {
        if !diceArray.isEmpty
        {
            for dice in diceArray
            {
                dice.removeFromParentNode()
            }
        }
    }
    
    
    
    //MARK: - Boton Girar Dados de Nuevo
    @IBAction func rollAgain(_ sender: UIBarButtonItem)
    {
        rollAll()
    }
    
    
    
    //MARK: - Shake
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?)
    {
        rollAll()
    }
    
    
    
    //MARK: - Funcion para detectar planos
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
    
    
    //MARK: - Crear Plano Horizontal
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode
    {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
    
        return planeNode
    }
}
