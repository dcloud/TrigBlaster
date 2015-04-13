//
//  GameScene.swift
//  TrigBlaster
//
//  Created by Daniel Cloud on 4/12/15.
//  Copyright (c) 2015 Daniel Cloud. All rights reserved.
//

import SpriteKit
import CoreMotion

let MaxPlayerAcceleration: CGFloat = 400
let MaxPlayerSpeed: CGFloat = 200

class GameScene: SKScene {

    let playerSprite = SKSpriteNode(imageNamed: "Player")
    var playerAcceleration = CGVector(dx: 0, dy: 0)
    var playerVelocity = CGVector(dx: 0, dy: 0)

    var accelerometerX: UIAccelerationValue = 0
    var accelerometerY: UIAccelerationValue = 0

    var lastUpdateTime: CFTimeInterval = 0

    let motionManager = CMMotionManager()

    deinit {
        stopMonitoringAcceleration()
    }

    override func didMoveToView(view: SKView) {
        size = view.bounds.size

        backgroundColor = SKColor(red: 94.0/255, green: 63.0/255, blue: 107.0/255, alpha: 1.0)

        playerSprite.position = CGPoint(x: (size.width - playerSprite.size.width)/2, y: (size.height - playerSprite.size.height)/2)
        addChild(playerSprite)

        startMonitoringAcceleration()
    }

    override func update(currentTime: CFTimeInterval) {
        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
        lastUpdateTime = currentTime

        updatePlayerAccelerationFromMotionManager()
        updatePlayer(deltaTime)
    }

    func startMonitoringAcceleration() {

        if motionManager.accelerometerAvailable {
            motionManager.startAccelerometerUpdates()
            NSLog("accelerometer updates on...")
        }
    }

    func stopMonitoringAcceleration() {

        if motionManager.accelerometerAvailable && motionManager.accelerometerActive {
            motionManager.stopAccelerometerUpdates()
            NSLog("accelerometer updates off...")
        }
    }

    func updatePlayerAccelerationFromMotionManager() {
        if let acceleration = motionManager.accelerometerData?.acceleration {

            let filterFactor = 0.75

            accelerometerX = acceleration.x * filterFactor + accelerometerX * (1 - filterFactor)
            accelerometerY = acceleration.y * filterFactor + accelerometerY * (1 - filterFactor)

            playerAcceleration.dx = CGFloat(accelerometerY) * -MaxPlayerAcceleration
            playerAcceleration.dy = CGFloat(accelerometerX) * MaxPlayerAcceleration
        }
    }

    func updatePlayer(dt: CFTimeInterval) {
        playerVelocity.dx = playerVelocity.dx + playerAcceleration.dx * CGFloat(dt)
        playerVelocity.dy = playerVelocity.dy + playerAcceleration.dy * CGFloat(dt)

        playerVelocity.dx = max(-MaxPlayerSpeed, min(MaxPlayerSpeed, playerVelocity.dx))
        playerVelocity.dy = max(-MaxPlayerSpeed, min(MaxPlayerSpeed, playerVelocity.dy))

        var newX = playerSprite.position.x + playerVelocity.dx * CGFloat(dt)
        var newY = playerSprite.position.y + playerVelocity.dy * CGFloat(dt)

        newX = min(size.width, max(0, newX));
        newY = min(size.height, max(0, newY));

        println("newX: \(newX)")
        println("newY: \(newY)")

        playerSprite.position = CGPoint(x: newX, y: newY)
    }
}
