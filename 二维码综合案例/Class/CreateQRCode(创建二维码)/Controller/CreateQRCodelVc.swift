//
//  CreateQRCodelVc.swift
//  二维码综合案例
//
//  Created by 瞿杰 on 2019/12/3.
//  Copyright © 2019 yiniu. All rights reserved.
//

import UIKit

class CreateQRCodelVc: UIViewController {

    let qrcodeImageView = UIImageView()
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(qrcodeImageView)
        qrcodeImageView.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        qrcodeImageView.center = CGPoint(x: view.bounds.width / 2.0, y: 100)
        qrcodeImageView.backgroundColor = .red
        
        view.addSubview(textView)
        textView.frame = CGRect(x: qrcodeImageView.frame.origin.x, y: qrcodeImageView.frame.maxY + 20, width: 200, height: 100)
        textView.backgroundColor = .orange
        
        let btn = UIButton(frame: CGRect(x: qrcodeImageView.frame.origin.x, y: textView.frame.maxY + 50, width: 200, height: 50))
        btn.addTarget(self, action: #selector(beginCreateQRCode), for: .touchUpInside)
        btn.setTitle("开始创建二维码", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        view.addSubview(btn)
    }
    
}

import CoreImage
extension CreateQRCodelVc {
    
     @objc func beginCreateQRCode() {
        
        qrcodeImageView.image = QJQRCodeTool.createQRCode(qrcodeMessage: textView.text, centerImage: UIImage(named: "erha.png"))
    }
    
    
}
