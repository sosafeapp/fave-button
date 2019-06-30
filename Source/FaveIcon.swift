//
//  FaveIcon.swift
//  FaveButton
//
// Copyright © 2016 Jansel Valentin.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class FaveIcon: UIView {

  var iconColor: UIColor = UIColor(red: 0.42, green: 0.47, blue: 0.57, alpha: 1.00)
  var iconImage: UIImage!
  var iconLayer: CAShapeLayer!
  var iconMask:  CALayer!

  var iconLayerFinal: CAShapeLayer?
  var iconMaskFinal:  CALayer?
  var iconImageFill: UIImage?

  var contentRegion: CGRect!
  var tweenValues: [CGFloat]?


  init(region: CGRect, icon: UIImage, color: UIColor, iconFilled: UIImage?) {
    self.iconColor      = color
    self.iconImage      = icon
    self.contentRegion  = region
    self.iconImageFill = iconFilled
    super.init(frame: CGRect.zero)

    applyInit()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


// MARK: create
extension FaveIcon{

  class func createFaveIcon(_ onView: UIView, icon: UIImage, color: UIColor, iconFilled: UIImage?) -> FaveIcon{
    let faveIcon = Init(FaveIcon(region:onView.bounds, icon: icon, color: color, iconFilled: iconFilled)) {
      $0.translatesAutoresizingMaskIntoConstraints = false
      $0.backgroundColor                           = .clear
    }
    onView.addSubview(faveIcon)

    (faveIcon, onView) >>- [.centerX,.centerY]

    faveIcon >>- [.width,.height]

    return faveIcon
  }

  func applyInit(){
    let maskRegion  = contentRegion.size.scaleBy(0.7).rectCentered(at: contentRegion.center)
    let shapeOrigin = CGPoint(x: -contentRegion.center.x, y: -contentRegion.center.y)

    iconMask = Init(CALayer()){
      $0.contents      = iconImage.cgImage
      $0.bounds        = maskRegion
      $0.contentsScale = UIScreen.main.scale
    }

    iconLayer = Init(CAShapeLayer()){
      $0.fillColor = iconColor.cgColor
      $0.path      = UIBezierPath(rect: CGRect(origin: shapeOrigin, size: contentRegion.size)).cgPath
      $0.mask      = iconMask
    }

    self.layer.addSublayer(iconLayer)

    if let iconImageFilled = iconImageFill?.cgImage {
      iconMaskFinal = Init(CALayer()){
        $0.contents      = iconImageFilled
        $0.bounds        = maskRegion
        $0.contentsScale = UIScreen.main.scale
      }

      iconLayerFinal = Init(CAShapeLayer()){
        $0.fillColor = UIColor(red: 1, green: 0.21, blue: 0.2, alpha: 1).cgColor
        $0.path      = UIBezierPath(rect: CGRect(origin: shapeOrigin, size: contentRegion.size)).cgPath
        $0.mask      = iconMaskFinal
      }

      iconLayerFinal?.isHidden = true

      if iconLayerFinal != nil {
        self.layer.addSublayer(iconLayerFinal!)
      }
    }
  }
}


// MARK : animation
extension FaveIcon {

  func animateSelect(_ isSelected: Bool = false, fillColor: UIColor, duration: Double = 0.5, delay: Double = 0){
    let animate = duration > 0.0

    if nil == tweenValues && animate {
      tweenValues = generateTweenValues(from: 0, to: 1.0, duration: CGFloat(duration))
    }

    CATransaction.begin()
    CATransaction.setDisableActions(true)
    iconLayer.fillColor = fillColor.cgColor
    iconLayerFinal?.isHidden = isSelected ? false : true
    CATransaction.commit()

    let selectedDelay = isSelected ? delay : 0

    if isSelected {
      self.alpha = 0
      UIView.animate(
        withDuration: 0,
        delay: selectedDelay,
        options: .curveLinear,
        animations: {
          self.alpha = 1
      }, completion: nil)
    }

    guard animate else {
      return
    }

    let scaleAnimation = Init(CAKeyframeAnimation(keyPath: "transform.scale")){
      $0.values    = tweenValues!
      $0.duration  = duration
      $0.beginTime = CACurrentMediaTime()+selectedDelay
    }
    iconMask.add(scaleAnimation, forKey: nil)
    iconMaskFinal?.add(scaleAnimation, forKey: nil)
  }

  func generateTweenValues(from: CGFloat, to: CGFloat, duration: CGFloat) -> [CGFloat]{
    var values         = [CGFloat]()
    let fps            = CGFloat(60.0)
    let tpf            = duration/fps
    let c              = to-from
    let d              = duration
    var t              = CGFloat(0.0)
    let tweenFunction  = Elastic.ExtendedEaseOut

    while(t < d){
      let scale = tweenFunction(t, from, c, d, c+0.001, 0.39988)  // p=oscillations, c=amplitude(velocity)
      values.append(scale)
      t += tpf
    }
    return values
  }
}
