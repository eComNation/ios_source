//
//  YSRangeSlider.swift
//  YSRangeSlider
//
//  Created by Laurentiu Ungur on 22/01/16.
//  Copyright © 2016 Yardi. All rights reserved.
//

import UIKit

@IBDesignable open class YSRangeSlider: UIControl {
    // MARK: - Public Properties
    
    /// The minimum possible value to select in the range
    @IBInspectable open var minimumValue: CGFloat = 0.0 {
        didSet { updateComponentsPosition() }
    }
    /// The maximum possible value to select in the range
    @IBInspectable open var maximumValue: CGFloat = 1.0 {
        didSet { updateComponentsPosition() }
    }
    /// The preselected minimum value from range [minimumValue, maximumValue]
    @IBInspectable open var minimumSelectedValue: CGFloat = 0.0 {
        didSet{
            if minimumSelectedValue < minimumValue || minimumSelectedValue > maximumValue {
                minimumSelectedValue = minimumValue
            }
            updateComponentsPosition()
        }
    }
    /// The preselected maximum value from range [minimumValue, maximumValue]
    @IBInspectable open var maximumSelectedValue: CGFloat = 1.0 {
        didSet{
            if maximumSelectedValue < minimumValue || maximumSelectedValue > maximumValue {
                maximumSelectedValue = maximumValue
            }
            updateComponentsPosition()
        }
    }
    /// The color of the slider
    @IBInspectable open var sliderLineColor: UIColor = UIColor.black {
        didSet { sliderLineLayer.backgroundColor = sliderLineColor.cgColor }
    }
    /// The color of slider between left and right thumb
    @IBInspectable open var sliderLineColorBetweenThumbs: UIColor = UIColor.yellow {
        didSet { thumbsDistanceLineLayer.backgroundColor = sliderLineColorBetweenThumbs.cgColor }
    }
    /// Padding between slider and controller sides
    @IBInspectable open var sliderSidePadding: CGFloat = 15.0 {
        didSet { layoutSubviews() }
    }
    /// The color of the left thumb
    @IBInspectable open var leftThumbColor: UIColor = UIColor.black {
        didSet { leftThumbLayer.backgroundColor = leftThumbColor.cgColor }
    }
    /// The color of the right thumb
    @IBInspectable open var rightThumbColor: UIColor = UIColor.black {
        didSet { rightThumbLayer.backgroundColor = rightThumbColor.cgColor }
    }
    /// The corner radius of the left thumb
    @IBInspectable open var leftThumbCornerRadius: CGFloat = 10.0 {
        didSet { leftThumbLayer.cornerRadius = leftThumbCornerRadius }
    }
    /// The corner radius of the right thumb
    @IBInspectable open var rightThumbCornerRadius: CGFloat = 10.0 {
        didSet { rightThumbLayer.cornerRadius = rightThumbCornerRadius }
    }
    /// The size of the thumbs
    @IBInspectable open var thumbsSize: CGFloat = 20.0 {
        didSet {
            leftThumbLayer.frame.size = CGSize(width: thumbsSize, height: thumbsSize)
            rightThumbLayer.frame.size = CGSize(width: thumbsSize, height: thumbsSize)
        }
    }
    /// The height of the slider
    @IBInspectable open var sliderLineHeight: CGFloat = 1.0 {
        didSet {
            sliderLineLayer.frame.size.height = sliderLineHeight
            thumbsDistanceLineLayer.frame.size.height = sliderLineHeight
        }
    }
    /// The delegate of `YSRangeSlider`
    open weak var delegate: YSRangeSliderDelegate?
    
    // MARK: - Private Properties
    
    fileprivate let sliderLineLayer = CALayer()
    fileprivate let leftThumbLayer = CALayer()
    fileprivate let rightThumbLayer = CALayer()
    fileprivate let thumbsDistanceLineLayer = CALayer()
    fileprivate let thumbTouchAreaExpansion: CGFloat = -90.0
    fileprivate var leftThumbSelected = false
    fileprivate var rightThumbSelected = false
    
    // MARK: - Init
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        sliderLineLayer.backgroundColor = sliderLineColor.cgColor
        layer.addSublayer(sliderLineLayer)
        
        thumbsDistanceLineLayer.backgroundColor = sliderLineColorBetweenThumbs.cgColor
        layer.addSublayer(thumbsDistanceLineLayer)
        
        leftThumbLayer.backgroundColor = leftThumbColor.cgColor
        leftThumbLayer.cornerRadius = leftThumbCornerRadius
        leftThumbLayer.frame = CGRect(x: 0, y: 0, width: thumbsSize, height: thumbsSize)
        layer.addSublayer(leftThumbLayer)
        
        rightThumbLayer.backgroundColor = rightThumbColor.cgColor
        rightThumbLayer.cornerRadius = rightThumbCornerRadius
        rightThumbLayer.frame = CGRect(x: 0, y: 0, width: thumbsSize, height: thumbsSize)
        layer.addSublayer(rightThumbLayer)
        
        updateComponentsPosition()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let frameMiddleY = frame.height / 2.0
        let lineLeftSide = CGPoint(x: sliderSidePadding, y: frameMiddleY)
        let lineRightSide = CGPoint(x: frame.width - sliderSidePadding, y: frameMiddleY)
        
        sliderLineLayer.frame = CGRect(x: lineLeftSide.x, y: lineLeftSide.y, width: lineRightSide.x - lineLeftSide.x, height: sliderLineHeight)
        
        updateThumbsPosition()
    }
    
    // MARK: - Touch Tracking
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let pressGestureLocation = touch.location(in: self)
        
        if leftThumbLayer.frame.insetBy(dx: thumbTouchAreaExpansion, dy: thumbTouchAreaExpansion).contains(pressGestureLocation) ||
           rightThumbLayer.frame.insetBy(dx: thumbTouchAreaExpansion, dy: thumbTouchAreaExpansion).contains(pressGestureLocation) {
            let distanceFromLeftThumb = distanceBetweenPoints(pressGestureLocation, centerOfRect(leftThumbLayer.frame))
            let distanceFromRightThumb = distanceBetweenPoints(pressGestureLocation, centerOfRect(rightThumbLayer.frame))
            
            if distanceFromLeftThumb < distanceFromRightThumb {
                leftThumbSelected = true
                animateThumbLayer(leftThumbLayer, isSelected: true)
            } else if maximumSelectedValue == maximumValue && centerOfRect(leftThumbLayer.frame).x == centerOfRect(rightThumbLayer.frame).x {
                leftThumbSelected = true
                animateThumbLayer(leftThumbLayer, isSelected: true)
            } else {
                rightThumbSelected = true
                animateThumbLayer(rightThumbLayer, isSelected: true)
            }
            
            return true
        }
        
        return false
    }
    
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let percentage = (location.x - sliderLineLayer.frame.minX - thumbsSize / 2) / (sliderLineLayer.frame.maxX - sliderLineLayer.frame.minX)
        let selectedValue = percentage * (maximumValue - minimumValue) + minimumValue
        
        if leftThumbSelected {
            minimumSelectedValue = (selectedValue < maximumSelectedValue) ? selectedValue : maximumSelectedValue
        } else if rightThumbSelected {
            maximumSelectedValue = (selectedValue > minimumSelectedValue) ? selectedValue : minimumSelectedValue
        }
        
        return true
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if leftThumbSelected {
            leftThumbSelected = false
            animateThumbLayer(leftThumbLayer, isSelected: false)
        } else {
            rightThumbSelected = false
            animateThumbLayer(rightThumbLayer, isSelected: false)
        }
    }
    
    // MARK: - Private Methods
    
    fileprivate func updateComponentsPosition() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateThumbsPosition()
        CATransaction.commit()
        
        delegate?.rangeSliderDidChange(self, minimumSelectedValue: minimumSelectedValue, maximumSelectedValue: maximumSelectedValue)
    }
    
    fileprivate func updateThumbsPosition() {
        let leftThumbCenter = CGPoint(x: getXPositionAlongSliderForValue(minimumSelectedValue), y: sliderLineLayer.frame.midY)
        let rightThumbCenter = CGPoint(x: getXPositionAlongSliderForValue(maximumSelectedValue), y: sliderLineLayer.frame.midY)
        
        leftThumbLayer.position = leftThumbCenter
        rightThumbLayer.position = rightThumbCenter
        thumbsDistanceLineLayer.frame = CGRect(x: leftThumbLayer.position.x, y: sliderLineLayer.frame.origin.y, width: rightThumbLayer.position.x - leftThumbLayer.position.x, height: sliderLineHeight)
    }
    
    fileprivate func getPercentageAlongSliderForValue(_ value: CGFloat) -> CGFloat {
        return (minimumValue != maximumValue) ? (value - minimumValue) / (maximumValue - minimumValue) : 0
    }
    
    fileprivate func getXPositionAlongSliderForValue(_ value: CGFloat) -> CGFloat {
        let percentage = getPercentageAlongSliderForValue(value)
        let differenceBetweenMaxMinCoordinatePositionX = sliderLineLayer.frame.maxX - sliderLineLayer.frame.minX
        let offset = percentage * differenceBetweenMaxMinCoordinatePositionX
    
        return sliderLineLayer.frame.minX + offset
    }
    
    fileprivate func distanceBetweenPoints(_ firstPoint: CGPoint, _ secondPoint: CGPoint) -> CGFloat {
        let xDistance = secondPoint.x - firstPoint.x
        let yDistance = secondPoint.y - firstPoint.y
        
        return sqrt(pow(xDistance, 2) + pow(yDistance, 2))
    }
    
    fileprivate func centerOfRect(_ rect: CGRect) -> CGPoint {
        return CGPoint(x: rect.midX, y: rect.midY)
    }
    
    fileprivate func animateThumbLayer(_ thumbLayer: CALayer, isSelected selected: Bool) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        thumbLayer.transform = selected ? CATransform3DMakeScale(1.3, 1.3, 1) : CATransform3DIdentity
        CATransaction.commit()
    }
}

// MARK: - YSRangeSliderDelegate

public protocol YSRangeSliderDelegate: class {
    /**
        Delegate method that is called every time minimum or maximum selected value is changed
        - Parameters:
            - rangeSlider: Current instance of `YSRangeSlider`
            - minimumSelectedValue: The minimum selected value
            - maximumSelectedValue: The maximum selected value
     */
    func rangeSliderDidChange(_ rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue: CGFloat)
}
