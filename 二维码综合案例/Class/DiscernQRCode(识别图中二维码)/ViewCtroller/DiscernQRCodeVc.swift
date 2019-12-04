//
//  DiscernQRCodeVc.swift
//  二维码综合案例
//
//  Created by 瞿杰 on 2019/12/3.
//  Copyright © 2019 yiniu. All rights reserved.
//

import UIKit
import CoreImage

class DiscernQRCodeVc: UIViewController {

    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.image = UIImage(named: "201804191342034618.png")
        imageView.backgroundColor = .orange
        imageView.frame = CGRect(origin:CGPoint(x: 50, y: 100), size: CGSize(width: 300, height: 300))
        
        let btn = UIButton(frame: CGRect(x: 100, y: imageView.frame.maxY + 50, width: 200, height: 50))
        btn.addTarget(self, action: #selector(beginDiscernQRCode), for: .touchUpInside)
        btn.setTitle("开始识别二维码", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        view.addSubview(btn)
    }
    

    @objc func beginDiscernQRCode() {
        guard let image = imageView.image else {
            return
        }
        QJQRCodeTool.discernQRCode(for: image) { (resultImage, qrcodeFeatures:[CIQRCodeFeature]?) in
            self.imageView.image = resultImage
            guard let qrcodeFeatures = qrcodeFeatures else {return}
            for feature in qrcodeFeatures {
                print(feature.messageString , feature.bounds)
            }
        }
    }

    
}
