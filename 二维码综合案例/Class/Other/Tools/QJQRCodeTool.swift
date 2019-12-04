//
//  QJQRCodeTool.swift
//  二维码综合案例
//
//  Created by 瞿杰 on 2019/12/3.
//  Copyright © 2019 yiniu. All rights reserved.
//

import UIKit

class QJQRCodeTool: NSObject {

    // 单例对象
    private static let share = QJQRCodeTool()
    /// 扫描视图
    private weak var videoLayer : AVCaptureVideoPreviewLayer?
    /// 是否显示扫描到的二维码矩形边框
    private var isShowQRCodeRectBounds = true
    private var resultBlock:( (_ result:[String]?) -> () )?
}

// MARK: 创建二维码
extension QJQRCodeTool {
    class func createQRCode(qrcodeMessage:String , centerImage:UIImage?) -> UIImage? {
        // 1. 创建二维码滤镜 CIQRCodeGenerator
        let filter = CIFilter(name: "CIQRCodeGenerator")
        // 清除滤镜中的设置值，恢复默认值
        filter?.setDefaults()
        
        // 2. 输入数据
        // KVC
        let dataMessage = qrcodeMessage.data(using: .utf8)
        filter?.setValue(dataMessage, forKey: "inputMessage")
        
        // 设置二维码的纠错率:
        // value = "L" 表示水平 7%的字码可以被修改(或庶挡)
        // value = "M" 表示水平 15%的字码可以被修改(或庶挡)
        // value = "Q" 表示水平 25%的字码可以被修改(或庶挡)
        // value = "H" 表示水平 30%的字码可以被修改(或庶挡)
        filter?.setValue("M", forKey: "inputCorrectionLevel")
        
        // 3. 从滤镜取出二维码
        let image = UIImage(ciImage: (filter?.outputImage)!)
        
        // 4.显示
        return getNewImage(sourceImage: image, centerImage: centerImage)
    }
    
    private class func getNewImage(sourceImage:UIImage , centerImage:UIImage?) -> UIImage? {
        let size = CGSize(width: 200, height: 200)
        // 1. 开启图形上下文
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        // 2. 绘制大图
        sourceImage.draw(in: CGRect(origin: .zero, size: size))
        // 3. 绘制小图
        if centerImage != nil {
            let width:CGFloat = 50 , height:CGFloat = 50
            let x = (size.width - width) / 2.0 , y = (size.height - height) / 2.0
            centerImage!.draw(in: CGRect(x: x, y: y, width: width, height: height))
        }
        
        // 4. 取出结果图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // 5. 关闭上下文
        UIGraphicsEndImageContext()
        // 6. 返回新图片
        return image
    }
}


// MARK: 识别二维码
extension QJQRCodeTool {
    
    /// 识别图中的二维码
    /// - Parameter image: 被识别的图片
    class func discernQRCode(for image:UIImage , resultBlock:((_ resultImage:UIImage , _ qrcodeFeatures:[CIQRCodeFeature]?)->())?) {
        print("开始识别图中二维码")
        guard let ciImage = CIImage(image: image)  else{
            resultBlock?(image , nil)
            return
        }
                
        // 1.创建一个二维码探测器 ,高精确度CIDetectorAccuracyHigh
        // CIDetectorTypeText
        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
                
        // 2. 二接探测二维码特征
        guard let features = dector?.features(in: ciImage) as? [CIQRCodeFeature]  else{
            resultBlock?(image , nil)
            return
        }
//        for qrcodeFeature in features {
//            print(qrcodeFeature.messageString , qrcodeFeature.bounds)
//        }
        //        for item in features {
        //            if item.type == "QRCode" {
        //                let qrcodeFeature = item as! CIQRCodeFeature
        //                print(qrcodeFeature.messageString , qrcodeFeature.bounds)
        //
        //                imageView.image = drawRect(image:imageView.image! , feature: qrcodeFeature)
        //
        //            } else if item.type == "Text" {
        //                let textFeature = item as! CITextFeature
        //
        //            }
        //
        //        }
        var image_features = featuresImage(origin: image , features: features)
        image_features = image_features == nil ? image : image_features!
        // 回调
        resultBlock?(image_features! , features)
        return
    }

    private class func featuresImage(origin image:UIImage , features:[CIQRCodeFeature]) -> UIImage?{
        
        let size = image.size
        
        // 开启上下文
        UIGraphicsBeginImageContext(size)
        // 把大图绘制上去
        image.draw(in: CGRect(origin: .zero, size: size))
        
        UIColor.red.set()
        // 绘制 rect 路径
        for feature in features {
            // 转换坐标系(y方向是反方向)，即 feature.bounds的原点在左下角，转成 我们绘制的原点在左上角 矩形
            let bounds = reverseYAxle(rect: feature.bounds, fatherHeight: size.height) // 是识别的二维码位置
            let path = UIBezierPath(rect: bounds)
            path.lineWidth = 4
            path.stroke()
        }
        
        
        // 获取新的图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        // 关闭上下文
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

// MARK: 扫描二维码
import AVFoundation

extension QJQRCodeTool : AVCaptureMetadataOutputObjectsDelegate {
    
    /// 扫描二维码
    /// - Parameters:
    ///   - videoLayer: 扫描视图，如果限定 scanArea ，就一定要先设置好 frame.size
    ///   - scanArea: 基于 videoLayer 上的扫描区域, zero 表示整个扫描区域
    ///   - showQRCodeRectBounds: 是否显示扫描到的二维码矩形边框
    class func scanQRCode(videoLayer:AVCaptureVideoPreviewLayer , scanArea:CGRect , showQRCodeRectBounds:Bool , resultBlock:@escaping (_ result:[String]?)->()) {
        
        // 为了扫描到的结果准备
        share.isShowQRCodeRectBounds = showQRCodeRectBounds
        share.videoLayer = videoLayer
        share.resultBlock = resultBlock

        // 1. 设置输入
        // 1.1 获取摄像头设备🎥
        guard let device = AVCaptureDevice.default(for: .video) else {
            resultBlock(nil)
            return
        }
        // 1.2 把摄像头当作输入设备
        guard let inputDevice = try? AVCaptureDeviceInput(device: device) else {
            resultBlock(nil)
            return
        }
        
        // 2. 设置输出
        let output = AVCaptureMetadataOutput()
        // 2.1 设置结果处理的代理 AVCaptureMetadataOutputObjectsDelegate
        output.setMetadataObjectsDelegate(self.share, queue: DispatchQueue.main)
        
        // 3. 创建会话，连接 输入 输出
        let session = AVCaptureSession()
        if !session.canAddInput(inputDevice) && !session.canAddOutput(output) {
            resultBlock(nil)
            return
        }
        session.addInput(inputDevice)
        session.addOutput(output)
        
        // 3.1 设置二维码可以识别的码制
        // 设置输出的识别类型，必须在添加到会话后才可以设置 , 不然会崩溃
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // 设置扫描二维码区域 , rectOfInterest 原点是在左下角
        let size = videoLayer.frame.size
        let interestFrame = reverseYAxle(rect: scanArea, fatherHeight: size.height)
        let x = interestFrame.origin.x / size.width
        let y = interestFrame.origin.y / size.height
        let w = interestFrame.width / size.width
        let h = interestFrame.height / size.height
        output.rectOfInterest = CGRect(x: x, y: y, width: w, height: h)
        
        // 3.2 添加视频预览图层，可以让用户直观看到
        videoLayer.session = session
        
        // 3.2 启动会话, 让输入对象开始 采集数据，让输出对象开始 处理数据
        session.startRunning()
    }
    
    // MARK: 处理扫描二维码结果 AVCaptureMetadataOutputObjectsDelegate
    // 扫描到结果 调用
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // 先移除先前识别二维码添加进去的 形状图层
        removeAllSubShapLayer()
        
        // 扫描结果得到的字符串数组
        var results = [String]()
        
        for objct in metadataObjects {
            // 二维码识别的结果类 AVMetadataMachineReadableCodeObject
            if objct.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                var codeObj = objct as! AVMetadataMachineReadableCodeObject
                
                // 1. 转换成为 二维码 在 预览图层上的 真正坐标
                codeObj = videoLayer?.transformedMetadataObject(for: codeObj) as! AVMetadataMachineReadableCodeObject
                // 四个角坐标点
                print(codeObj.corners)
                // 识别的二维码得到的信息
                print(codeObj.stringValue)
                
                results.append(codeObj.stringValue ?? "")
                
                // 2. 把识别的二维码矩形框显示出来
                if isShowQRCodeRectBounds {
                    showQRCodeRectBounds(codeObj: codeObj)
                }
            }
        }
        
        resultBlock?(results)
    }
    /// 显示识别的二维码矩形框
    private func showQRCodeRectBounds(codeObj:AVMetadataMachineReadableCodeObject) {
        
        let shapLayer = CAShapeLayer() // 形状图层
        shapLayer.backgroundColor = UIColor.clear.cgColor
        shapLayer.fillColor = UIColor.clear.cgColor
        shapLayer.strokeColor = UIColor.red.cgColor
        shapLayer.lineWidth = 2
        
        let bezierPath = UIBezierPath()
        
        let points = codeObj.corners
        for point in points {
            bezierPath.currentPoint == .zero ? bezierPath.move(to: point) : bezierPath.addLine(to: point)
        }
        bezierPath.close()
        
        shapLayer.path = bezierPath.cgPath
        videoLayer?.addSublayer(shapLayer)
    }
    /// 移除形状图层
    private func removeAllSubShapLayer() {
        guard let subShapLayers = videoLayer?.sublayers else {
            return
        }
        for shapLayer in subShapLayers {
            shapLayer.removeFromSuperlayer()
        }
    }
}


// MARK: 转换工具方法
extension QJQRCodeTool {
    /// 颠倒Y轴后 , 可以把 rect 以左下角为原点 转成 以左上角为原点的 位置 ，反之亦然
    /// - Parameters:
    ///   - rect: 需要颠倒Y轴 的 frame
    ///   - fatherHeight: 父控件的高度
    class func reverseYAxle(rect:CGRect , fatherHeight:CGFloat) -> CGRect {
        
        // 先将 rect 自身origin的 左下角点 转到 左上角点
        var rectTmp = CGRect(x: rect.origin.x, y: rect.origin.y + rect.height, width: rect.width, height: rect.height)
        
        // 然后再将左下角原点转成左上角原点，即位置 y 方向进行反转，
        var rect2 = CGRect(x: rectTmp.origin.x, y: fatherHeight - rectTmp.origin.y, width: rectTmp.width, height: rectTmp.height)
        
        return rect2
    }
}
