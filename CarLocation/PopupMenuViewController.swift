//
//  PopupMenuViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/23.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit

protocol PopupMenuViewControllerDelegate: class {
    func parentViewControllerForPopuoMenuViewController(_ popupmenuViewController: PopupMenuViewController) -> UIViewController
    func shouldPresentForPopupmenuViewController(_ popupmenuViewController: PopupMenuViewController) -> Bool
    func popupmenuViewControllerDidRequestShowing(_ popupmenuViewController: PopupMenuViewController, animated: Bool)
    func popupmenuViewControllerDidRequestHiding(_ popupmenuViewController: PopupMenuViewController, animated: Bool)
    func storeBusstationName(_ popupmenuViewController: PopupMenuViewController, stationName: String)
}

class PopupMenuViewController: UIViewController {

    private let contentView = UIView(frame: .zero)
    let textfield = UITextField()
    let storeButton = UIButton()
    
    weak var delegate: PopupMenuViewControllerDelegate?
    var isShown: Bool {
        return self.parent != nil
    }
    var contentMaxHeight: CGFloat {
        return 50
    }
    var contentPositionY: CGFloat {
        return self.staturBarHeight + self.navigationBarHeight
    }
    var staturBarHeight: CGFloat = 0
    var navigationBarHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var contentRect = view.bounds
        contentRect.size.height = contentMaxHeight
        contentRect.origin.y = .zero
        contentView.frame = contentRect
        contentView.backgroundColor = .white
        contentView.autoresizingMask = .flexibleWidth
        contentView.alpha = 0.98
        view.addSubview(contentView)
        
        textfield.frame = CGRect(x: 10, y: 6, width: view.frame.width * 0.8, height: 38)
        textfield.placeholder = "バス停名を入力してください"
        textfield.borderStyle = .roundedRect
        contentView.addSubview(textfield)
        
        storeButton.frame = CGRect(x: view.frame.width * 0.8 + 20, y: 10, width: view.frame.width * 0.2 - 30, height: 30)

        storeButton.setTitle("保存", for: .normal)
        storeButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        storeButton.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        storeButton.layer.cornerRadius = 10
        storeButton.addTarget(self, action: #selector(storeButtonPressed(_:)), for: .touchUpInside)
        storeButton.setTitleColor(.black, for: .highlighted)
        contentView.addSubview(storeButton)
        
        staturBarHeight = UIApplication.shared.statusBarFrame.height
        navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 80
    }
    
    @objc func storeButtonPressed(_ sender: UIButton) {
        guard let stationName = textfield.text else {
            preconditionFailure("テキストフィールドからバス停名の取得に失敗しました")
        }
        self.delegate?.storeBusstationName(self, stationName: stationName)
    }


    func showContentView(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.contentView.frame.origin.y = self.contentPositionY
            }
        }
    }
    
    func hideContentView(animated: Bool, completion: ((Bool) -> Swift.Void)?) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentView.frame.origin.y = 0
            }) { (finished) in
                completion?(finished)
            }
        } else {
            self.contentView.frame.origin.y = 0
            completion?(true)
        }
    }
}
