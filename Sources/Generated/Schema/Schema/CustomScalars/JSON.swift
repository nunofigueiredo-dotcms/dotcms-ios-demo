// @generated
// This file was automatically generated and can be edited to
// implement advanced custom scalar functionality.
//
// Any changes to this file will not be overwritten by future
// code generation execution.

import ApolloAPI
import Foundation

extension DotCMSAPI {
  /// dotCMS returns StoryBlock bodies as a JSON **object**, not a string.
  ///
  /// Apollo generates custom scalars as `typealias JSON = String` by default,
  /// which fails to decode a real body with
  /// `couldNotConvert(value: AnyHashable([...]))`. This custom scalar accepts
  /// whatever shape arrives — object, array, string or number — so a body that
  /// changes shape degrades to `nil` at the parser rather than throwing.
  struct JSON: CustomScalarType, Hashable {
    /// The raw value exactly as Apollo decoded it.
    let raw: AnyHashable

    init(_jsonValue value: JSONValue) throws {
      self.raw = value
    }

    var _jsonValue: JSONValue { raw }

    // NOTE: do NOT override _asAnyHashable to return `raw`.
    //
    // Apollo's DataDict stores whatever _asAnyHashable returns and reads it
    // back with a FORCE cast (`_data[key] as! T`). Returning the raw value
    // stores a bare Dictionary, so the cast back to DotCMSAPI.JSON aborts with
    // swift_dynamicCastFailure — a SIGABRT the moment a blog detail loads from
    // the normalized cache. The default Hashable conformance stores `self`,
    // which is what the force cast expects.

    /// Foundation-typed representation for `JSONSerialization`-style parsing.
    ///
    /// Apollo hands back nested values wrapped in `AnyHashable`, which do not
    /// cast directly to `[String: Any]`, so unwrap the graph recursively.
    var jsonObject: Any? { Self.unwrap(raw) }

    static func unwrapValue(_ value: Any?) -> Any? { unwrap(value) }

    private static func unwrap(_ value: Any?) -> Any? {
      guard let value else { return nil }

      if let hashable = value as? AnyHashable, !(value is String) {
        let base = hashable.base
        // Only recurse when unwrapping actually revealed a different value,
        // otherwise a plain scalar would loop.
        if !(base is AnyHashable) || type(of: base) != type(of: value) {
          return unwrapContainer(base)
        }
      }
      return unwrapContainer(value)
    }

    private static func unwrapContainer(_ value: Any) -> Any? {
      switch value {
      case let dict as [String: AnyHashable]:
        return dict.mapValues { unwrap($0) ?? NSNull() }
      case let array as [AnyHashable]:
        return array.map { unwrap($0) ?? NSNull() }
      case let array as [Any]:
        return array.map { unwrap($0) ?? NSNull() }
      default:
        return value
      }
    }
  }
}
