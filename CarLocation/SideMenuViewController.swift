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
        return view.bounds.width * 0.6
    }
    
    let menuList = ["バス路線検索", "お知らせ", "設定", "管理マップへ"]
    
    //指でスクロールしたときの微妙な位置を表現
    private var contentRatio: CGFloat {
        get {
            return (view.bounds.maxX - contentView.frame.origin.x) / contentMaxWidth
        }
        set {
            let ratio = min(max(newValue, 0), 1)
            contentView.frame.origin.x = view.bounds.width - contentMaxWidth * ratio
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowRadius = 3.0
            contentView.layer.shadowOpacity = 0.8
            
            view.backgroundColor = UIColor(white: 0, alpha: 0.2 * ratio)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //コンテントビューの大きさ、位置、高さを設定し、親ビューに追加
        var contentRect = view.bounds
        contentRect.size.width = contentMaxWidth
        contentRect.origin.x = view.bounds.width
        contentView.frame = contentRect
        contentView.backgroundColor = .white
        contentView.autoresizingMask = .flexibleHeight
        contentView.alpha = 0.9
        view.addSubview(contentView)
        
        //テーブルビューをコンテントビューに追加
        let statusbarHeight = UIApplication.shared.statusBarFrame.height
        tableView.contentInset = UIEdgeInsets(top: statusbarHeight, left: 0, bottom: 0, right: 0)
        tableView.frame = contentView.bounds
        tableView.separatorInset = .zero
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")
        tableView.isScrollEnabled = false
        
        let headerView = UIView()
        headerView.frame.size.height = 60
        tableView.tableHeaderView = headerView
        
        let footerView = UIView()
        let footerLabel = UILabel()
        footerLabel.frame = CGRect(x: 0, y: 0, width: contentMaxWidth - 10, height: 50)
        footerLabel.text = "Version 1.0"
        footerLabel.font = footerLabel.font.withSize(14)
        footerLabel.textAlignment = .right
        footerView.alpha = 0.6
        footerView.addSubview(footerLabel)
        footerView.frame.size.height = 50
        tableView.tableFooterView = footerView
        
        contentView.addSubview(tableView)
        
        tableView.reloadData()
        
        //タップ感知の追加
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SideMenuViewController.backgroundTapped(sender:)))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //これは特に理解しなくても良い
    @objc private func backgroundTapped(sender: UITapGestureRecognizer) {
        
        //タップアクションが有効なのは、画面左側のバックグラウンドビューのみという設定
        let tappedLocation = sender.location(in: view)
        if sender.state == .ended && tappedLocation.x < view.bounds.width - contentMaxWidth {
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
        if translation.x < 0 && contentRatio == 1.0 {
            return
        }
        
        let location = panGestureRecognizer.location(in: view)
        switch panGestureRecognizer.state {
        case .began:
            beganState = isShown
            beganLocation = location
            if translation.x <= 0 {
                self.delegate?.sidemenuViewControllerDidRequestShowing(self, contentAvailability: false, animated: false)
            }
        case .changed:
            let distance = beganState ? location.x - beganLocation.x : beganLocation.x - location.x
            if distance >= 0 {
                let ratio = distance / (beganState ? (view.bounds.width - beganLocation.x) : beganLocation.x)
                let contentRatio = beganState ? 1 - ratio : ratio
                self.contentRatio = contentRatio
                print(contentRatio)
            }
            
        case .ended, .cancelled, .failed:
            if contentRatio <= 1.0, contentRatio >= 0 {
                if location.x < beganLocation.x {
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
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Default", for: indexPath)
        cell.textLabel?.text = menuList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.sidemenuViewController(self, didSelectItemAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
