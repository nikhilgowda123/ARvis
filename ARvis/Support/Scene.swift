//  Scene.swift
//  ARvis
//  Created by Nikhil, Ayush.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import AVFoundation


func addVideoToSCNNode(url: String, node: SCNNode, title: String, year: String, director: String, stars: String, imDbRating: String, genres: String, plot: String, worldWideCollection: String) {
    
    let videoNode = SKVideoNode(url: URL(string: url)!)
    let videoScene = SKScene(size: CGSize(width: 1280, height: 720))
    videoScene.addChild(videoNode)
    
    videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
    videoNode.size = videoScene.size
    print(videoScene.size.width / 2)
    print(videoScene.size.height / 2)
    
    let tvPlane = SCNPlane(width: 1.0, height: 0.5625)
    tvPlane.firstMaterial?.diffuse.contents = videoScene
    tvPlane.firstMaterial?.isDoubleSided = true
    
    let tvPlaneNode = SCNNode(geometry: tvPlane)
    tvPlaneNode.eulerAngles = SCNVector3(0, GLKMathDegreesToRadians(180), GLKMathDegreesToRadians(-90))
    tvPlaneNode.opacity = 1
    
    videoNode.play()

    // Add label nodes to a separate SKScene
    let labelScene = SKScene(size: CGSize(width: 1280, height: 400))
    labelScene.backgroundColor = .black // Make the background transparent

    // Add title label
    let titleLabel = SKLabelNode(text: "Title: " + title)
    titleLabel.position = CGPoint(x: labelScene.size.width / 2, y: 350)
    titleLabel.fontSize = 44
    titleLabel.fontName = "AvenirNext-Bold"
    titleLabel.fontColor = UIColor(red: 0.98, green: 0.89, blue: 0.24, alpha: 1.0) // Use a custom color
    titleLabel.horizontalAlignmentMode = .center
    titleLabel.verticalAlignmentMode = .center
    labelScene.addChild(titleLabel)

    // Add stars label
    let starsLabel = SKLabelNode(text: "Main Lead: " + stars)
    starsLabel.position = CGPoint(x: labelScene.size.width / 2, y: 300)
    starsLabel.fontSize = 32
    starsLabel.fontName = "AvenirNext-Regular"
    starsLabel.fontColor = .white
    starsLabel.horizontalAlignmentMode = .center
    starsLabel.verticalAlignmentMode = .center
    labelScene.addChild(starsLabel)
    
    let genresLabel = SKLabelNode(text: "Genres: " + genres)
    genresLabel.position = CGPoint(x: labelScene.size.width / 2, y: 250)
    genresLabel.fontSize = 32
    genresLabel.fontName = "AvenirNext-Regular"
    genresLabel.fontColor = .white
    genresLabel.horizontalAlignmentMode = .center
    genresLabel.verticalAlignmentMode = .center
    labelScene.addChild(genresLabel)
    
    let imdbRatingLabel = SKLabelNode(text: "IMDB Rating: " + imDbRating)
    imdbRatingLabel.position = CGPoint(x: labelScene.size.width / 2, y: 200)
    imdbRatingLabel.fontSize = 32
    imdbRatingLabel.fontName = "AvenirNext-Regular"
    imdbRatingLabel.fontColor = .white
    imdbRatingLabel.horizontalAlignmentMode = .center
    imdbRatingLabel.verticalAlignmentMode = .center
    labelScene.addChild(imdbRatingLabel)
    
    let languagesLabel = SKLabelNode(text: "Available Languages: " + plot)
    languagesLabel.position = CGPoint(x: labelScene.size.width / 2, y: 150)
    languagesLabel.fontSize = 32
    languagesLabel.fontName = "AvenirNext-Regular"
    languagesLabel.fontColor = .white
    languagesLabel.horizontalAlignmentMode = .center
    languagesLabel.verticalAlignmentMode = .center
    labelScene.addChild(languagesLabel)
    
    
    let collectionLabel = SKLabelNode(text: "World Wide Collection: "+worldWideCollection)
    collectionLabel.position = CGPoint(x: labelScene.size.width / 2, y: 100)
    collectionLabel.fontSize = 32
    collectionLabel.fontName = "AvenirNext-Regular"
    collectionLabel.fontColor = .white
    collectionLabel.horizontalAlignmentMode = .center
    collectionLabel.verticalAlignmentMode = .center
    labelScene.addChild(collectionLabel)

    // Adjust label plane width to match the widest label
    let maxWidth = max(titleLabel.frame.width, starsLabel.frame.width) + 40 // Add some padding
    let labelPlane = SCNPlane(width: maxWidth / 625, height: 0.3)
    labelPlane.firstMaterial?.diffuse.contents = labelScene
    labelPlane.firstMaterial?.isDoubleSided = true
    labelPlane.firstMaterial?.transparency = 0.92

    let labelPlaneNode = SCNNode(geometry: labelPlane)
    labelPlaneNode.position = SCNVector3(x: 0.5, y: 0.0, z: 0.0) // Move the label plane up slightly
    labelPlaneNode.eulerAngles = SCNVector3(0,GLKMathDegreesToRadians(180),GLKMathDegreesToRadians(-90)) // Rotate the label plane to face the camera

    node.addChildNode(labelPlaneNode)

    node.addChildNode(tvPlaneNode)
        
    
}
