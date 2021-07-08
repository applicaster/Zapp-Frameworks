//
//  QuickBrickViewController.swift
//  QuickBrickApple
//
//  Created by Anna Bauza on 03/02/2020.
//

import UIKit
import ZappCore
import XrayLogger

class QuickBrickViewController: UIViewController {
    lazy var logger = Logger.getLogger(for: QuickBrickViewControllerLogs.subsystem)

    var orientationStack = [UIInterfaceOrientationMask.all]
    var orientationMask: UIInterfaceOrientationMask = QuickBrickViewController.initialOrientationMask
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
          return orientationMask
    }

    override public var shouldAutorotate: Bool {
          return true
    }
    
    static var initialOrientationMask: UIInterfaceOrientationMask {
        var retValue:UIInterfaceOrientationMask = .portrait
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            retValue = .landscape
        default:
            break
        }
        return retValue
    }
    
    /// Allow Orientation for specific screen
    ///
    /// - Parameters:
    ///   - orientation: int value representing 
    ///         JS_PORTAIT = 1
    ///         JS_LANDSCAPE = 1
    ///         JS_LANDSCAPE_REVERSED = 4
    ///         JS_PORTAIT_REVERSED = 8
    ///         JS_LANDSCAPE_SENSOR = JS_LANDSCAPE | JS_LANDSCAPE_REVERSED
    ///         JS_PORTAIT_SENSOR = JS_PORTAIT | JS_PORTAIT_REVERSED
    ///         JS_FULL_SENSOR = JS_LANDSCAPE_SENSOR | JS_PORTAIT_SENSOR
    ///         JS_SENSOR = JS_LANDSCAPE_SENSOR | JS_PORTAIT
    public func allowOrientationForScreen(_ orientation:Int){
        self.orientationMask =  mapOrientation(orientation)
        orientationStack.append(orientationMask)
        forceOrientationIfNeeded(orientationMask: orientationMask)
    }

    /// Release Orientation for specific screen to previous state
    public func releaseOrientationForScreen(){
        if(orientationStack.count > 1) {
            _ = orientationStack.dropLast()
            forceOrientationIfNeeded(orientationMask: orientationStack.last ?? UIInterfaceOrientationMask.all)
        }
    }
    
    private func mapOrientation(_ orientation: Int) -> UIInterfaceOrientationMask {
        let JS_PORTAIT = 0x00000001
        let JS_LANDSCAPE = 0x00000002 // landscapeRight: 2,
        let JS_LANDSCAPE_REVERSED = 0x00000004
        let JS_PORTAIT_REVERSED = 0x00000008
        let JS_LANDSCAPE_SENSOR = JS_LANDSCAPE | JS_LANDSCAPE_REVERSED
        let JS_PORTAIT_SENSOR = JS_PORTAIT | JS_PORTAIT_REVERSED
        let JS_FULL_SENSOR = JS_LANDSCAPE_SENSOR | JS_PORTAIT_SENSOR
        let JS_SENSOR = JS_LANDSCAPE_SENSOR | JS_PORTAIT
        
        switch orientation {
        case JS_PORTAIT:
            return UIInterfaceOrientationMask.portrait
        case JS_LANDSCAPE:
            return UIInterfaceOrientationMask.landscapeRight
        case JS_LANDSCAPE_REVERSED:
            return UIInterfaceOrientationMask.landscapeLeft
        case JS_LANDSCAPE_SENSOR:
            return UIInterfaceOrientationMask.landscape
        case JS_PORTAIT_REVERSED:
            return UIInterfaceOrientationMask.portraitUpsideDown
        case JS_PORTAIT_SENSOR:
            return UIInterfaceOrientationMask.portrait
        case JS_FULL_SENSOR:
            return UIInterfaceOrientationMask.all
        case JS_SENSOR:
            return UIInterfaceOrientationMask.allButUpsideDown
        default:
            return UIInterfaceOrientationMask.all
        }
    }
    
    private func mapOrientationMask(_ orientationMask: UIInterfaceOrientationMask) -> UIInterfaceOrientation {
        switch orientationMask {
        case UIInterfaceOrientationMask.portrait:
            return UIInterfaceOrientation.portrait
        case UIInterfaceOrientationMask.landscape:
            return UIInterfaceOrientation.landscapeRight
        case UIInterfaceOrientationMask.landscapeRight:
            return UIInterfaceOrientation.landscapeRight
        case UIInterfaceOrientationMask.landscapeLeft:
            return UIInterfaceOrientation.landscapeLeft
        case UIInterfaceOrientationMask.all:
            return UIInterfaceOrientation.portrait
        case UIInterfaceOrientationMask.allButUpsideDown:
            return UIInterfaceOrientation.portrait
        case UIInterfaceOrientationMask.portraitUpsideDown:
            return UIInterfaceOrientation.portraitUpsideDown
        default:
            return UIInterfaceOrientation.portrait
        }
    }
    
    private func forceOrientationIfNeeded(orientationMask: UIInterfaceOrientationMask){
        switch orientationMask {
            case UIInterfaceOrientationMask.portrait:
                if(!UIDevice.current.orientation.isPortrait){
                    forceOrientation(UIInterfaceOrientation.portrait)
                }
                break
            case UIInterfaceOrientationMask.landscape:
                if(!UIDevice.current.orientation.isLandscape){
                    forceOrientation(UIInterfaceOrientation.landscapeRight)
                }
                break
            case UIInterfaceOrientationMask.landscapeRight:
                if(UIDevice.current.orientation.rawValue != UIInterfaceOrientation.landscapeRight.rawValue){
                    forceOrientation(UIInterfaceOrientation.landscapeRight)
                }
                break
            case UIInterfaceOrientationMask.landscapeLeft:
                if(UIDevice.current.orientation.rawValue != UIInterfaceOrientation.landscapeLeft.rawValue){
                    forceOrientation(UIInterfaceOrientation.landscapeLeft)
                }
                break
            case UIInterfaceOrientationMask.all:
                break
            case UIInterfaceOrientationMask.allButUpsideDown:
                if(!UIDevice.current.orientation.isLandscape && UIDevice.current.orientation.rawValue != UIInterfaceOrientation.portrait.rawValue){
                    forceOrientation(UIInterfaceOrientation.portrait)
                }
                break
            case UIInterfaceOrientationMask.portraitUpsideDown:
                if(UIDevice.current.orientation.rawValue != UIInterfaceOrientation.portraitUpsideDown.rawValue){
                    forceOrientation(UIInterfaceOrientation.portraitUpsideDown)
                }
                break
            default:
                break
        }
    }
    
    private func forceOrientation(_ orientation: UIInterfaceOrientation){
        logger?.debugLog(message: QuickBrickViewControllerLogs.forceOrientation.message,
                         category: QuickBrickViewControllerLogs.forceOrientation.category,
                         data: ["orientation": "\(orientation.rawValue)"])

        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
}
