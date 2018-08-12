//
//  Forest.swift
//  Forest
//
//  Created by muukii on 8/12/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import Foundation

public protocol PathType {

  associatedtype Source : Routing
  associatedtype Destination

  func apply(source: Source, completion: @escaping (RoutingResult<Destination>) -> Void)
}

public struct Path<S : Routing, D> : PathType {

  public typealias Destination = D
  public typealias Source = S

  public typealias Apply = (_ source: S, _ completion: @escaping (RoutingResult<D>) -> Void) throws -> Void

  private let _apply: Apply

  public init(_ apply: @escaping Apply) {
    self._apply = apply
  }

  public func apply(source: S, completion: @escaping (RoutingResult<D>) -> Void) {
    do {
      try _apply(source, completion)
    } catch {
      completion(.failure(error))
    }
  }
}

public protocol Routing {

}

extension Routing {

  public var path: Paths<Self> {
    return .init(base: self)
  }
}

/// Proxy
public struct Paths<Base> {

  public let base: Base

  init(base: Base) {
    self.base = base
  }
}

extension Routing {

  public func go<P: PathType>(to path: P, completion: @escaping (RoutingResult<P.Destination>) -> Void = { _ in }) where P.Source == Self {
    path.apply(source: self, completion: completion)
  }
}

public enum RoutingResult<D> {
  case success(D)
  case failure(Error)
}

public protocol RouterType {
  associatedtype Root : Routing
  var root: Root? { get }
}

public final class Router<T: Routing> : RouterType where T : AnyObject {

  public typealias Root = T

  public weak var root: T?

  public init(root: T) {
    self.root = root
  }

  public func go<P: PathType>(to path: P, completion: @escaping (RoutingResult<P.Destination>) -> Void) where P.Source == T {
    root?.go(to: path, completion: completion)
  }

  public func go<P: PathType>(to path: P, from source: P.Source, completion: @escaping (RoutingResult<P.Destination>) -> Void) {
    source.go(to: path, completion: completion)
  }
}
