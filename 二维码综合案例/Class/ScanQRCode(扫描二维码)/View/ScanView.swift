//
//  ScanView.swift
//  二维码综合案例
//
//  Created by 瞿杰 on 2019/12/3.
//  Copyright © 2019 yiniu. All rights reserved.
//  扫描二维码视图

import UIKit
import AVFoundation

class ScanView: UIView {

    // 频预览图层
    private let videoLayer = AVCaptureVideoPreviewLayer()
    
    private let rectView = UIView()
    private let bgImageView = UIImageView(image: UIImage(named: "qrcode_border"))
    private let scanImageView = UIImageView(image: UIImage(named: "qrcode_scanline_qrcode"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(videoLayer)
        
        addSubview(rectView)
        rectView.addSubview(bgImageView)
        rectView.addSubview(scanImageView)
        
        rectView.clipsToBounds = true
        rectView.backgroundColor = .clear
        bgImageView.backgroundColor = .clear
        scanImageView.backgroundColor = .clear
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rectView.frame = CGRect(x: 0  , y: 0, width: 200, height: 200)
        rectView.center = CGPoint(x: bounds.width / 2, y: bounds.height/2)

        bgImageView.frame = rectView.bounds
        scanImageView.frame = bgImageView.frame
        
        videoLayer.frame = bounds
    }
}

extension ScanView {
    
    /// 开始扫描前，必须设置好 frame
    func beginScanAnimation() {
        scanImageView.frame = CGRect(origin: CGPoint(x: 0, y: -scanImageView.frame.height), size: scanImageView.frame.size)
        UIView.animate(withDuration: 1.5) {[weak self] in
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self?.scanImageView.frame = CGRect(origin: CGPoint(x: 0, y: self?.scanImageView.frame.height ?? 0), size: self?.scanImageView.frame.size ?? .zero)
        }
        
        // 开始扫描
        startScan()
    }
    
    private func startScan() {
//        print(NSValue(cgRect:videoLayer.frame))
        QJQRCodeTool.scanQRCode(videoLayer: videoLayer, scanArea: rectView.frame, showQRCodeRectBounds: true) { (result:[String]?) in
            guard let result = result else {return}
            print(result)
        }
    }
}


