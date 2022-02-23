////
////  LineChart.swift
////  Interface
////
////  Created by Eugene Dudkin on 23.02.2022.
////
//
// import UIKit
//
// class LineChart: UIView {
//
//    /// gap between each point
//    let lineGap: CGFloat = 60.0
//
//    /// preseved space at top of the chart
//    let topSpace: CGFloat = 40.0
//
//    /// preserved space at bottom of the chart to show labels along the Y axis
//    let bottomSpace: CGFloat = 40.0
//
//    /// The top most horizontal line in the chart will be 10% higher than the highest value in the chart
//    let topHorizontalLine: CGFloat = 110.0 / 100.0
//
//    var dataSource: [PointEntry]?
//    var visibleRange: ClosedRange<Int>?
//    var visibleDataPoints: [CGPoint]?
//
//    /// Contains the main line which represents the data
//    let dataLayer: CALayer = CALayer()
//
//    /// To show the gradient below the main line
//    private let gradientLayer: CAGradientLayer = CAGradientLayer()
//
//    /// Contains dataLayer and gradientLayer
//    private let mainLayer: CALayer = CALayer()
//
//    /// Contains mainLayer and label for each data entry
//    let scrollView: UIScrollView = UIScrollView()
//    /// Contains horizontal lines
//    private let gridLayer: CALayer = CALayer()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    convenience init() {
//        self.init(frame: CGRect.zero)
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupView()
//    }
//
//    private func setupView() {
//        mainLayer.addSublayer(dataLayer)
//        scrollView.layer.addSublayer(mainLayer)
//        scrollView.showsHorizontalScrollIndicator = false
//        gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7).cgColor, UIColor.clear.cgColor]
//        scrollView.layer.addSublayer(gradientLayer)
//        self.layer.addSublayer(gridLayer)
//        self.addSubview(scrollView)
//        self.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
//    }
//
//    func configureVisibleRange() -> ClosedRange<Int>? {
//        let offsetX = scrollView.contentOffset.x
//        let displayWidth = self.frame.size.width
//
//        let minVisibleIndex = Int(offsetX) / Int(lineGap)
//        let maxVisibleIndex = (Int(offsetX) + Int(displayWidth)) / Int(lineGap)
//        return minVisibleIndex...maxVisibleIndex
//    }
//
//
//
//    override func layoutSubviews() {
//        visibleRange = configureVisibleRange()
//        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - 30, height: self.frame.size.height)
//        if let dataSource = dataSource, let visibleRange = visibleRange {
//            scrollView.contentSize = CGSize(width: CGFloat(dataSource.count) * lineGap, height: self.frame.size.height)
//            mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(dataSource.count) * lineGap, height: self.frame.size.height)
//            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
//            gradientLayer.frame = dataLayer.frame
//            visibleDataPoints = convertDataEntriesToPoints(entries: dataSource, range: visibleRange)
//            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
//            clean()
//            drawHorizontalLines(dataEntries: dataSource, range: visibleRange)
//            drawChart()
//            maskGradientLayer()
//            drawLables()
//        }
//    }
//    /**
//     Convert an array of PointEntry to an array of CGPoint on dataLayer coordinate system
//     */
//    private func convertDataEntriesToPoints(entries: [PointEntry], range: ClosedRange<Int>) -> [CGPoint] {
//
//        let rangeEntries = Array(entries[range.lowerBound...range.upperBound-1])
//
//
//        if let max = rangeEntries.max()?.value,
//           let min = rangeEntries.min()?.value {
//
//            var result: [CGPoint] = []
//            let minMaxRange: CGFloat = CGFloat(max - min) * topHorizontalLine
//
//            for i in range.lowerBound..<range.upperBound {
//                let height = dataLayer.frame.height * (1 - ((CGFloat(entries[i].value) - CGFloat(min)) / minMaxRange))
//                let point = CGPoint(x: CGFloat(i)*lineGap + 40, y: height)
//                result.append(point)
//            }
//            return result
//        }
//        return []
//    }
//
//    /**
//     Draw a zigzag line connecting all points in dataPoints
//     */
//    private func drawChart() {
//        if let visibleDataPoints = visibleDataPoints,
//           !visibleDataPoints.isEmpty,
//           let path = createPath() {
//
//            let lineLayer = CAShapeLayer()
//            lineLayer.path = path.cgPath
//            lineLayer.strokeColor = UIColor.white.cgColor
//            lineLayer.fillColor = UIColor.clear.cgColor
//            dataLayer.addSublayer(lineLayer)
//        }
//    }
//
//    /**
//     Create a zigzag bezier path that connects all points in dataPoints
//     */
//    private func createPath() -> UIBezierPath? {
//        guard let visibleDataPoints = visibleDataPoints, !visibleDataPoints.isEmpty else {
//            return nil
//        }
//        let path = UIBezierPath()
//        path.move(to: visibleDataPoints[0])
//
//        for i in 1..<visibleDataPoints.count {
//            path.addLine(to: visibleDataPoints[i])
//        }
//        return path
//    }
//
//
//    /**
//     Create a gradient layer below the line that connecting all dataPoints
//     */
//    private func maskGradientLayer() {
//        if let visibleDataPoints = visibleDataPoints,
//           !visibleDataPoints.isEmpty {
//
//            let path = UIBezierPath()
//            path.move(to: CGPoint(x: visibleDataPoints[0].x, y: dataLayer.frame.height))
//            path.addLine(to: visibleDataPoints[0])
//            if let straightPath = createPath() {
//                path.append(straightPath)
//            }
//            path.addLine(to: CGPoint(x: visibleDataPoints[visibleDataPoints.count-1].x, y: dataLayer.frame.height))
//            path.addLine(to: CGPoint(x: visibleDataPoints[0].x, y: dataLayer.frame.height))
//
//            let maskLayer = CAShapeLayer()
//            maskLayer.path = path.cgPath
//            maskLayer.fillColor = UIColor.white.cgColor
//            maskLayer.strokeColor = UIColor.clear.cgColor
//            maskLayer.lineWidth = 0.0
//
//            gradientLayer.mask = maskLayer
//        }
//    }
//
//    /**
//     Create titles at the bottom for all entries showed in the chart
//     */
//    private func drawLables() {
//        if let dataEntries = dataSource,
//           !dataEntries.isEmpty {
//            for i in 0..<dataEntries.count {
//                let textLayer = CATextLayer()
//                textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2 + 40,
//                                         y: mainLayer.frame.size.height - bottomSpace/2 - 8,
//                                         width: lineGap,
//                                         height: 16)
//                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
//                textLayer.backgroundColor = UIColor.clear.cgColor
//                textLayer.alignmentMode = CATextLayerAlignmentMode.center
//                textLayer.contentsScale = UIScreen.main.scale
//                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
//                textLayer.fontSize = 11
//                textLayer.string = dataEntries[i].label
//                mainLayer.addSublayer(textLayer)
//            }
//        }
//    }
//
//    /**
//     Create horizontal lines (grid lines) and show the value on the left of each line
//     */
//    private func drawHorizontalLines(dataEntries: [PointEntry], range: ClosedRange<Int>) {
//
//        let visibleDataEntries = dataEntries[range.lowerBound..<range.upperBound]
//
//
//        var gridValues: [CGFloat]? = nil
//        if visibleDataEntries.count < 4 && !visibleDataEntries.isEmpty {
//            gridValues = [0, 1]
//        } else if visibleDataEntries.count >= 4 {
//            gridValues = [0, 0.25, 0.5, 0.75, 1]
//        }
//        if let gridValues = gridValues {
//            for value in gridValues {
//                let height = value * gridLayer.frame.size.height
//                let width = gridLayer.frame.size.width
//
//                let path = UIBezierPath()
//                path.move(to: CGPoint(x: 0, y: height))
//                path.addLine(to: CGPoint(x: width, y: height))
//
//                let lineLayer = CAShapeLayer()
//                lineLayer.path = path.cgPath
//                lineLayer.fillColor = UIColor.clear.cgColor
//                lineLayer.strokeColor = #colorLiteral(red: 0.2784313725, green: 0.5411764706, blue: 0.7333333333, alpha: 1).cgColor
//                lineLayer.lineWidth = 0.5
//                if (value > 0.0 && value < 1.0) {
//                    lineLayer.lineDashPattern = [4, 4]
//                }
//
//                gridLayer.addSublayer(lineLayer)
//
//                var minMaxGap:CGFloat = 0
//                var lineValue:Int = 0
//                if let max = visibleDataEntries.max()?.value,
//                   let min = visibleDataEntries.min()?.value {
//                    minMaxGap = CGFloat(max - min) * topHorizontalLine
//                    lineValue = Int((1-value) * minMaxGap) + Int(min)
//                }
//
//                let textLayer = CATextLayer()
//                textLayer.frame = CGRect(x: width - 30, y: height, width: 50, height: 16)
//                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
//                textLayer.backgroundColor = UIColor.clear.cgColor
//                textLayer.contentsScale = UIScreen.main.scale
//                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
//                textLayer.fontSize = 12
//                textLayer.string = "\(lineValue)"
//
//                gridLayer.addSublayer(textLayer)
//            }
//        }
//    }
//
//    private func clean() {
//        mainLayer.sublayers?.forEach({
//            if $0 is CATextLayer {
//                $0.removeFromSuperlayer()
//            }
//        })
//        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
//        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
//    }
// }