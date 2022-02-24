//
//  ChartView.swift
//  Interface
//
//  Created by Eugene Dudkin on 23.02.2022.
//
import UIKit

class ChartView: UIView {
    
    public var dataSource: [ChartCandle]?
    
    private var visibleRange: ClosedRange<Int>?
    private var visibleDataPoints: [CGPoint]?
    
    private let xPointGap: CGFloat = 60.0
    private let topSpace: CGFloat = 40.0
    private let bottomSpace: CGFloat = 40.0
    private let topHorizontalLine: CGFloat = 110.0 / 100.0
    private let dataLayer: CALayer = .init()
    private let gradientLayer: CAGradientLayer = .init()
    private let mainLayer: CALayer = .init()
    private let scrollView: UIScrollView = .init()
    private let gridLayer: CALayer = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        scrollView.showsHorizontalScrollIndicator = false
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        scrollView.layer.addSublayer(gradientLayer)
        self.layer.addSublayer(gridLayer)
        self.addSubview(scrollView)
    }
    
    func configureVisibleRange() -> ClosedRange<Int>? {
        let offsetX = scrollView.contentOffset.x
        let displayWidth = self.frame.size.width
        
        var minVisibleIndex = Int(offsetX) / Int(xPointGap) - 15
        var maxVisibleIndex = (Int(offsetX) + Int(displayWidth)) / Int(xPointGap) + 15
        
        if minVisibleIndex < 0 {
            minVisibleIndex = 0
        }
        
        if let dataSource = dataSource, maxVisibleIndex > dataSource.count {
            maxVisibleIndex = dataSource.count
        }
        
        return minVisibleIndex...maxVisibleIndex
    }
    
    override func layoutSubviews() {
        
        visibleRange = configureVisibleRange()
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - 30, height: self.frame.size.height)
        
        if let dataSource = dataSource, let visibleRange = visibleRange {
            
            scrollView.contentSize = CGSize(
                width: CGFloat(dataSource.count) * xPointGap,
                height: self.frame.size.height
            )
            
            mainLayer.frame = CGRect(
                x: 0,
                y: 0,
                width: CGFloat(dataSource.count) * xPointGap,
                height: self.frame.size.height
            )
            
            dataLayer.frame = CGRect(
                x: 0,
                y: topSpace,
                width: mainLayer.frame.width,
                height: mainLayer.frame.height - topSpace - bottomSpace
            )
            
            gradientLayer.frame = dataLayer.frame
            visibleDataPoints = convertDataSourceToPoints(datasource: dataSource, range: visibleRange)
            
            gridLayer.frame = CGRect(
                x: 0,
                y: topSpace,
                width: self.frame.width,
                height: mainLayer.frame.height - topSpace - bottomSpace
            )
            
            clean()
            drawHorizontalLines(dataSource: dataSource, range: visibleRange)
            drawLineChart()
            maskGradientLayer()
            drawHorizontalLables()
            configureDelegates()
        }
    }
    
    private func configureDelegates() {
        scrollView.delegate = self
    }
    
    private func convertDataSourceToPoints(
        datasource: [ChartCandle],
        range: ClosedRange<Int>
    ) -> [CGPoint] {
        
        let visibleDataSource = Array(datasource[range.lowerBound..<range.upperBound])
        
        if let max = visibleDataSource.max()?.value,
           let min = visibleDataSource.min()?.value {
            
            var result: [CGPoint] = []
            let minMaxRange = CGFloat(max - min) * topHorizontalLine
            
            for i in range.lowerBound..<range.upperBound {
                let value = CGFloat(datasource[i].value)
                let height = dataLayer.frame.height * (1 - ((value - CGFloat(min)) / minMaxRange))
                let point = CGPoint(x: CGFloat(i) * xPointGap + 40, y: height)
                result.append(point)
            }
            return result
        }
        return []
    }
    
    private func drawLineChart() {
        if let visibleDataPoints = visibleDataPoints,
           !visibleDataPoints.isEmpty,
           let path = createPath() {
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    private func createPath() -> UIBezierPath? {
        guard let visibleDataPoints = visibleDataPoints, !visibleDataPoints.isEmpty else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: visibleDataPoints[0])
        
        for i in 1..<visibleDataPoints.count {
            path.addLine(to: visibleDataPoints[i])
        }
        return path
    }
    
    private func maskGradientLayer() {
        if let visibleDataPoints = visibleDataPoints,
           !visibleDataPoints.isEmpty {
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: visibleDataPoints[0].x, y: dataLayer.frame.height))
            path.addLine(to: visibleDataPoints[0])
            if let straightPath = createPath() {
                path.append(straightPath)
            }
            path.addLine(to: CGPoint(
                x: visibleDataPoints[visibleDataPoints.count - 1].x,
                y: dataLayer.frame.height
            ))
            path.addLine(to: CGPoint(
                x: visibleDataPoints[0].x,
                y: dataLayer.frame.height
            ))
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            maskLayer.fillColor = UIColor.red.cgColor
            maskLayer.strokeColor = UIColor.red.cgColor
            maskLayer.lineWidth = 0.0
            
            gradientLayer.mask = maskLayer
        }
    }
    
    private func drawHorizontalLables() {
        if let dataSource = dataSource,
           !dataSource.isEmpty {
            for i in 0..<dataSource.count {
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(
                    x: xPointGap * CGFloat(i) - xPointGap / 2 + 40,
                    y: mainLayer.frame.size.height - bottomSpace / 2 - 8,
                    width: xPointGap,
                    height: 16
                )
                textLayer.foregroundColor = UIColor.label.cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 11
                textLayer.string = dataSource[i].label
                mainLayer.addSublayer(textLayer)
            }
        }
    }

    private func drawHorizontalLines(dataSource: [ChartCandle], range: ClosedRange<Int>) {
        
        let visibleDataSource = dataSource[range.lowerBound..<range.upperBound]
        let gridValues: [CGFloat] = [0, 0.25, 0.5, 0.75, 1]
        
        for value in gridValues {
            let height = value * gridLayer.frame.size.height
            let width = gridLayer.frame.size.width
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: width, y: height))
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.lineWidth = 0.5
            if value > 0.0 && value < 1.0 {
                lineLayer.lineDashPattern = [4, 4]
            }
            
            gridLayer.addSublayer(lineLayer)
            
            var minMaxGap: CGFloat = 0
            var lineValue: Int = 0
            if let max = visibleDataSource.max()?.value,
               let min = visibleDataSource.min()?.value {
                minMaxGap = CGFloat(max - min) * topHorizontalLine
                lineValue = Int((1 - value) * minMaxGap) + Int(min)
            }
            
            let textLayer = CATextLayer()
            textLayer.frame = CGRect(x: width - 30, y: height, width: 50, height: 16)
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.backgroundColor = UIColor.clear.cgColor
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
            textLayer.fontSize = 12
            textLayer.string = "\(lineValue)"
            
            gridLayer.addSublayer(textLayer)
        }
    }
    
    private func clean() {
        mainLayer.sublayers?.forEach {
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        dataLayer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        gridLayer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
    }
}


extension ChartView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
    }
}
