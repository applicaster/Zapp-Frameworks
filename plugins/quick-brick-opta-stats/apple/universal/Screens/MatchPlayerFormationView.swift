//
//  MatchPlayerFormationView.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/12/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import UIKit

class MatchPlayerFormationView: UIView {
    var homeTeamFormation: String = ""
    var awayTeamFormation: String = ""
    var homePlayers = [Player]()
    var awayPlayers = [Player]()

    fileprivate var homeTeamFormationPerColumn = [Int]()
    fileprivate var awayTeamFormationPerColumn = [Int]()

    fileprivate let homeTeamFormationStackView = UIStackView()
    fileprivate let awayTeamFormationStackView = UIStackView()

    func update() {
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        UIColor(white: 0.9, alpha: 1.0).setStroke()
        UIColor.white.setFill()

        drawBorder(rect)
        drawMiddleLine(rect)
        drawMiddleCircle(rect)
        drawCornerCircles(rect)

        drawTeamBox(rect, isHomeTeam: true)
        drawTeamBox(rect, isHomeTeam: false)

        addPlayers(rect)
    }

    // MARK: -

    fileprivate func drawBorder(_ rect: CGRect) {
        let borderPath = UIBezierPath(rect: rect.insetBy(dx: 1.0, dy: 1.0))
        borderPath.lineWidth = 2.0
        borderPath.stroke()
        borderPath.fill()
    }

    fileprivate func drawMiddleLine(_ rect: CGRect) {
        let middleLinePath = UIBezierPath()
        middleLinePath.lineWidth = 2.0
        middleLinePath.move(to: CGPoint(x: rect.midX, y: 0))
        middleLinePath.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        middleLinePath.stroke()
    }

    fileprivate func drawMiddleCircle(_ rect: CGRect) {
        let middleCircleRadius = rect.height / 3.0
        let middleCirclePath = UIBezierPath(ovalIn: CGRect(x: rect.midX - (middleCircleRadius * 0.5), y: rect.midY - (middleCircleRadius * 0.5), width: middleCircleRadius, height: middleCircleRadius))
        middleCirclePath.lineWidth = 2.0
        middleCirclePath.stroke()
    }

    fileprivate func drawCornerCircles(_ rect: CGRect) {
        let radius = CGFloat(14.0)

        for cornerIndex in 0 ..< 4 {
            var center = CGPoint.zero
            var startAngle = CGFloat(0)
            var endAngle = CGFloat(0)

            switch cornerIndex {
            case 0: // top left
                center = CGPoint(x: rect.minX, y: rect.minY)
                startAngle = 0
                endAngle = CGFloat.pi / 2.0
            case 1: // top right
                center = CGPoint(x: rect.maxX, y: rect.minY)
                startAngle = CGFloat.pi / 2.0
                endAngle = CGFloat.pi
            case 2: // bottom left
                center = CGPoint(x: rect.minX, y: rect.maxY)
                startAngle = -CGFloat.pi / 2.0
                endAngle = 0
            case 3: // bottom right
                center = CGPoint(x: rect.maxX, y: rect.maxY)
                startAngle = CGFloat.pi
                endAngle = -CGFloat.pi / 2.0
            default:
                break
            }

            let cornerCirclePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            cornerCirclePath.lineWidth = 2.0
            cornerCirclePath.stroke()
        }
    }

    fileprivate func drawHalfCircle(_ rect: CGRect, isHomeTeam: Bool) {
        let centerXPadding = CGFloat(20.0)
        let radius = rect.height * 0.3
        let centerPoint: CGPoint

        if isHomeTeam {
            centerPoint = CGPoint(x: rect.minX + centerXPadding, y: rect.midY)
        } else {
            centerPoint = CGPoint(x: rect.maxX - centerXPadding, y: rect.midY)
        }

        let halfCirclePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2.0, endAngle: CGFloat.pi / 2.0, clockwise: isHomeTeam)
        halfCirclePath.lineWidth = 2.0
        halfCirclePath.stroke()
    }

    fileprivate func drawTeamBox(_ rect: CGRect, isHomeTeam: Bool) {
        let boxHalfHeight = (rect.height * 0.5) * 0.5
        let boxEdgePadding = CGFloat(1)
        let boxWidth = (rect.width * 0.5) * 0.3

        let innerBoxHalfHeight = boxHalfHeight * 0.5
        let innerBoxEdgePadding = CGFloat(0)
        let innerBoxWidth = boxWidth * 0.4

        let boxPath: UIBezierPath
        let innerBoxPath: UIBezierPath
        let dCirclePath: UIBezierPath

        if isHomeTeam {
            boxPath = UIBezierPath(rect: CGRect(x: rect.minX + boxEdgePadding, y: rect.midY - boxHalfHeight, width: boxWidth, height: boxHalfHeight * 2.0))
            innerBoxPath = UIBezierPath(rect: CGRect(x: rect.minX + innerBoxEdgePadding, y: rect.midY - innerBoxHalfHeight, width: innerBoxWidth, height: innerBoxHalfHeight * 2.0))
            dCirclePath = UIBezierPath(arcCenter: CGPoint(x: rect.minX + innerBoxWidth * 0.5, y: rect.midY), radius: boxWidth, startAngle: -CGFloat.pi * 0.5, endAngle: CGFloat.pi * 0.5, clockwise: true)
        } else {
            boxPath = UIBezierPath(rect: CGRect(x: rect.maxX - boxEdgePadding - boxWidth, y: rect.midY - boxHalfHeight, width: boxWidth, height: boxHalfHeight * 2.0))
            innerBoxPath = UIBezierPath(rect: CGRect(x: rect.maxX - innerBoxEdgePadding - innerBoxWidth, y: rect.midY - innerBoxHalfHeight, width: innerBoxWidth, height: innerBoxHalfHeight * 2.0))
            dCirclePath = UIBezierPath(arcCenter: CGPoint(x: rect.maxX - innerBoxWidth * 0.5, y: rect.midY), radius: boxWidth, startAngle: CGFloat.pi * 0.5, endAngle: -CGFloat.pi * 0.5, clockwise: true)
        }

        boxPath.lineWidth = 2.0
        innerBoxPath.lineWidth = 2.0

        dCirclePath.stroke()
        boxPath.stroke()
        boxPath.fill()
        innerBoxPath.stroke()
    }

    // MARK: -

    fileprivate func addPlayers(_ rect: CGRect) {
        removeAllSubviews()

        addPlayersUsingFormation(homeTeamFormation, rect: rect, isHomeTeam: true)
        addPlayersUsingFormation(awayTeamFormation, rect: rect, isHomeTeam: false)
    }

    fileprivate func addPlayersUsingFormation(_ formation: String, rect: CGRect, isHomeTeam: Bool) {
        let players = isHomeTeam ? homePlayers : awayPlayers

        if players.count == 0 { return }

        let stackViewToUse = isHomeTeam ? homeTeamFormationStackView : awayTeamFormationStackView

        for view in stackViewToUse.arrangedSubviews {
            stackViewToUse.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        if stackViewToUse.superview == nil {
            stackViewToUse.translatesAutoresizingMaskIntoConstraints = false
            stackViewToUse.axis = .horizontal
            stackViewToUse.alignment = .center
            stackViewToUse.distribution = .fillEqually // .equalSpacing

            addSubview(stackViewToUse)

            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": stackViewToUse]))

            if isHomeTeam {
                addConstraint(NSLayoutConstraint(item: stackViewToUse, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 5.0))
                addConstraint(NSLayoutConstraint(item: stackViewToUse, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            } else {
                addConstraint(NSLayoutConstraint(item: stackViewToUse, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
                addConstraint(NSLayoutConstraint(item: stackViewToUse, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -5.0))
            }
        }

        var formationIndices = [Int]()
        var biggest = 0
        for c in formation {
            if let index = Int(String(c)) {
                formationIndices.append(index)
                if index > biggest {
                    biggest = index
                }
            }
        }

        formationIndices.insert(1, at: 0) // insert goalkeeper

        let dimension = CGFloat(25.0)
        let spacing = abs(frame.height - (CGFloat(biggest) * dimension)) / CGFloat(biggest)

        var playerIndex = 0

        for index in formationIndices {
            let columnStackView = UIStackView(arrangedSubviews: [])
            columnStackView.axis = .vertical
            columnStackView.alignment = .center
            columnStackView.distribution = .equalCentering
            columnStackView.spacing = spacing

            var playerViews = [UIView]()

            for _ in 0 ..< index {
                let player = players[playerIndex]
                let view = PlayerShirtView(text: player.shirtNumber ?? "X", radius: 20.0)
                view.isHomeTeam = isHomeTeam
                playerViews.append(view)
                playerIndex += 1
            }
            /* if index == -1 {
                 playerViews.append(MatchPlayerFormationView.createPlayerCircle(number: "1", radius: 20.0, isHomeTeam: isHomeTeam))
             } else {
                 for _ in 0..<index {
                     playerViews.append(MatchPlayerFormationView.createPlayerCircle(number: "X", radius: 20.0, isHomeTeam: isHomeTeam))
                 }
             } */

            for view in playerViews {
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: view.frame.width / view.frame.height))
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: dimension))
                columnStackView.addArrangedSubview(view)
            }

            stackViewToUse.addArrangedSubview(columnStackView)
        }

        if !isHomeTeam {
            let views = stackViewToUse.arrangedSubviews.reversed()
            stackViewToUse.removeAllSubviews()
            for view in views {
                stackViewToUse.addArrangedSubview(view)
            }
        }
    }
}
