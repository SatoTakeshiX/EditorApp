//
//  UIView+Extension.swift
//  EditorApp
//
//  Created by satoutakeshi on 2019/11/30.
//  Copyright © 2019 satoutakeshi. All rights reserved.
//

import UIKit
import SwiftUI

extension UIView {
    var renderedImage: UIImage {
        let image = UIGraphicsImageRenderer(size: self.bounds.size).image { context in
            UIColor.lightGray.set()
            UIRectFill(bounds)
            context.cgContext.setAlpha(0.75)
            self.layer.render(in: context.cgContext)
        }
        return image
    }

    func screenShot(size: CGSize) -> UIImage {
        // キャプチャする範囲を取得.
        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        // 対象のview内の描画をcontextに複写する.
        self.layer.render(in: context)
        // 現在のcontextのビットマップをUIImageとして取得.
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        // contextを閉じる
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension View {
    var renderedImage: UIImage {
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 160)))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.rootViewController = hosting
        window.makeKey()
        return hosting.view.renderedImage
    }
}
