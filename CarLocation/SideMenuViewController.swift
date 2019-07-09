//
//  SideMenuViewController.swift
//  CarLocation
//
//  Created by 吉野史也 on 2019/07/07.
//  Copyright © 2019 yoshinofumiya. All rights reserved.
//

import UIKit

protocol SidemenuViewControllerDelegate: class {
    func parentViewControllerForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> UIViewController
    func shouldPresentForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> Bool
    func sidemenuViewControllerDidRequestShowing(_ sidemenuViewController: SideMenuViewController, contentAvailability: Bool, animated: Bool)
    func sidemenuViewControllerDidRequestHiding(_ sidemenuViewController: SideMenuViewController, animated: Bool)
    func sidemenuViewController(_ sidemenuViewController: SideMenuViewController, didSelectItemAt indexPath: IndexPath)
}

class SideMenuViewController: UIViewController {
    
    private let contentView = UIView(frame: .zero)
    private let tableView = UITableView(frame: .zero, style: .plain)
    weak var delegate: SidemenuViewControllerDelegate?
    private var panGestureRecognizer: UIPanGestureRecognizer!
    var isShown: Bool {
        return self.parent != nil
    }
    private var beganLocation: CGPoint = .zero
    private var beganState: Bool = false
    private var contentMaxWidth: CGFloat {
        return view.bounds.width * 0.8
    }
    
    //指でスクロールしたときの微妙な位置を表現
    private var contentRatio: CGFloat {
        get {
            return contentView.frame.maxX / contentMaxWidth
        }
        set {
            let ratio = min(max(newValue, 0), 1)
            contentView.frame.origin.x = contentMaxWidth * ratio - contentView.frame.width
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowRadius = 3.0
            contentView.layer.shadowOpacity = 0.8
            
            view.backgroundColor = UIColor(white: 0, alpha: 0.3 * ratio)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //コンテントビューの大きさ、位置、高さを設定し、親ビューに追加
        var contentRect = view.bounds
        contentRect.size.width = contentMaxWidth
        contentRect.origin.x = -contentRect.width
        contentView.frame = contentRect
        contentView.backgroundColor = .white
        contentView.autoresizingMask = .flexibleHeight
        view.addSubview(contentView)
        
        //テーブルビューをコンテントビューに追加
        tableView.frame = contentView.bounds
        tableView.separatorInset = .zero
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")
        contentView.addSubview(tableView)
        tableView.reloadData()
        
        //タップ感知の追加
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SideMenuViewController.backgroundTapped(sender:)))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //これは特に理解しなくても良い
    @objc private func backgroundTapped(sender: UITapGestureRecognizer) {
        
        //タップアクションが有効なのは、画面右側のバックグラウンドビューのみという設定
        let tappedLocation = sender.location(in: view)
        if sender.state == .ended && tappedLocation.x > contentMaxWidth {
            hideContentView(animated: true) { (_) in
                self.willMove(toParent: nil)
                self.removeFromParent()
                self.view.removeFromSuperview()
            }
        }
    }
    
    //これも簡単
    func showContentView(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.contentRatio = 1.0
            }
        } else {
            contentRatio = 1.0
        }
    }
    
    func hideContentView(animated: Bool, completion: ((Bool) -> Swift.Void)?) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentRatio = 0
            }, completion: { (finished) in
                completion?(finished)
            })
        } else {
            contentRatio = 0
            completion?(true)
        }
    }
    
    func startPanGestureRecognizing() {
        if let parentViewController = self.delegate?.parentViewControllerForSidemenuViewController(self) {
            
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandled(panGestureRecognizer:)))
            panGestureRecognizer.delegate = self
            parentViewController.view.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    @objc private func panGestureRecognizerHandled(panGestureRecognizer: UIPanGestureRecognizer) {
        guard let shouldPresent = self.delegate?.shouldPresentForSidemenuViewController(self), shouldPresent else {
            return
        }
        
        let translation = panGestureRecognizer.translation(in: view)
        if translation.x > 0 && contentRatio == 1.0 {
            return
        }
        
        let location = panGestureRecognizer.location(in: view)
        switch panGestureRecognizer.state {
        case .began:
            beganState = isShown
            beganLocation = location
            if translation.x >= 0 {
                self.delegate?.sidemenuViewControllerDidRequestShowing(self, contentAvailability: false, animated: false)
            }
        case .changed:
            let distance = beganState ? beganLocation.x - location.x : location.x - beganLocation.x
            if distance >= 0 {
                let ratio = distance / (beganState ? beganLocation.x : (view.bounds.width - beganLocation.x))
                let contentRatio = beganState ? 1 - ratio : ratio
                self.contentRatio = contentRatio
            }
            
        case .ended, .cancelled, .failed:
            if contentRatio <= 1.0, contentRatio >= 0 {
                if location.x > beganLocation.x {
                    showContentView(animated: true)
                } else {
                    self.delegate?.sidemenuViewControllerDidRequestHiding(self, animated: true)
                }
            }
            beganLocation = .zero
            beganState = false
        default: break
        }
    }
}


//MARK - テーブルビューのDelegate
extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Default", for: indexPath)
        cell.textLabel?.text = "Item \(indexPath.row)"
        return cell
    }
}

//MARK - タップジェスチャーのDelegate
extension SideMenuViewController: UIGestureRecognizerDelegate {

    //テーブルビュー内のセルをタップされた時、ジェスチャーを無効にする
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchedLocation = gestureRecognizer.location(in: tableView)
        
        if tableView.indexPathForRow(at: touchedLocation) != nil {
            return false
        }
        return true
    }

}