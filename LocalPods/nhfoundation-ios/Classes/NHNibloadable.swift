//
//  NHNibloadable.swift
//  NHFoundation
//
//  Created by 骆亮 on 2021/11/10.
//
/*
 注册nib相关
 */

import Foundation
import UIKit

public protocol NHNibloadable {
    static var nh_nibIdentifier: String { get }
}

extension NHNibloadable {
    static var nh_nib: UINib {
        return UINib(nibName: nh_nibIdentifier, bundle: nil)
    }
}

// MARK: - 从nib中读取UIView
extension UIView: NHNibloadable {
    public static var nh_nibIdentifier: String {
        return String(describing: self)
    }
}
extension NHNibloadable where Self: UIView {
    public static func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        guard let view = UINib(nibName: nh_nibIdentifier, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Couldn't find nib file for \(String(describing: Self.self))")
        }
        return view
    }
}


// MARK: - 从nib中读取UIViewController
extension UIViewController: NHNibloadable {
    public static var nh_nibIdentifier: String {
        return String(describing: self)
    }
}
extension NHNibloadable where Self: UIViewController {
    public static func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        return Self(nibName: nh_nibIdentifier, bundle: bundle)
    }
}
extension NHNibloadable where Self: UITableViewController {
    public static func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        return Self(nibName: nh_nibIdentifier, bundle: bundle)
    }
}


// MARK: - 从nib中读取UITableView
extension NHNibloadable where Self: UITableView {
    public static func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        guard let tableView = UINib(nibName: nh_nibIdentifier, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Couldn't find nib file for \(String(describing: Self.self))")
        }
        return tableView
    }
}





// MARK:- 复用相关 TableView
extension UITableView {
    
    /// 注册Cell，基于xib
    /// - Parameter type: type.self
    public func nh_registerCell<T: UITableViewCell>(_ type: T.Type) {
        register(T.nh_nib, forCellReuseIdentifier: String(describing: T.self))
    }
    
    /// 注册HeaderFooterView，基于xib
    /// - Parameter type: type.self
    public func nh_registerHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type) {
        register(type.nh_nib, forCellReuseIdentifier: String(describing: T.self))
    }
    
    /// 获取Cell
    /// - Parameter type: type.self
    /// - Returns: type
    public func nh_dequeueReusableCell<T: UITableViewCell>(_ type: T.Type) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("Couldn't find nib file for \(String(describing: T.self))")
        }
        return cell
    }
    
    /// 获取Cell
    /// - Parameters:
    ///   - type: type.self
    ///   - indexPath: indexPath
    /// - Returns: type
    public func nh_dequeueReusableCell<T: UITableViewCell>(_ type: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Couldn't find nib file for \(String(describing: T.self))")
        }
        return cell
    }
    
    /// 获取HeaderFooterView
    /// - Parameter type: type.self
    /// - Returns: type
    public func nh_dequeueResuableHeaderFooterView<T: UITableViewHeaderFooterView>(type: T.Type) -> T {
        guard let headerFooterView = self.dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T
            else { fatalError("Couldn't find nib file for \(String(describing: T.self))") }
        return headerFooterView
    }
    
}


// MARK:- 复用相关 UICollectionView
extension UICollectionView {
    
    /// 注册Cell
    /// - Parameter type: type.self
    public func nh_registerCell<T: UICollectionViewCell>(type: T.Type) {
        register(T.nh_nib, forCellWithReuseIdentifier: String(describing: T.self))
    }
    
    /// 获取Cell
    /// - Parameters:
    ///   - type: type.self
    ///   - indexPath: indexPath
    /// - Returns: type
    public func nh_dequeueReusableCell<T: UICollectionViewCell>(type: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Couldn't find nib file for \(String(describing: T.self))")
        }
        return cell
    }
    
}
