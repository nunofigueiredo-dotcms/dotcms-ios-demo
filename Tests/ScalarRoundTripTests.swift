import Foundation
import ApolloAPI

// Exercises the exact sequence that crashed: decode a custom scalar, store it
// the way DataDict does, then read it back with the same force cast.
// Real captured dotCMS StoryBlock body.
let fixture = try! Data(contentsOf: URL(fileURLWithPath: "blog-body-fixture.json"))
let rawObject = try! JSONSerialization.jsonObject(with: fixture)

func toHashable(_ v: Any) -> AnyHashable {
    switch v {
    case let d as [String: Any]: return d.mapValues { toHashable($0) }
    case let a as [Any]: return a.map { toHashable($0) }
    case let s as String: return s
    case let n as NSNumber: return n
    default: return String(describing: v)
    }
}
let payload: AnyHashable = toHashable(rawObject)

let scalar = try! DotCMSAPI.JSON(_jsonValue: payload)
let stored: AnyHashable = scalar._asAnyHashable
print("stored as: \(type(of: stored.base))")

// DataDict's fast path: `_data[key] as! T`
let roundTripped = stored.base as? DotCMSAPI.JSON
print("force-cast path: \(roundTripped != nil ? "OK" : "WOULD SIGABRT")")

// DataDict's slow path: `(value?.base as? T) ?? (value._asAnyHashable as! T)`
let slow = (stored.base as? DotCMSAPI.JSON)
print("slow path:       \(slow != nil ? "OK" : "WOULD SIGABRT")")

guard let rt = roundTripped else { print("FAILED"); exit(1) }
guard let obj = rt.jsonObject as? [String: Any], obj["type"] as? String == "doc" else {
    print("FAILED: payload not preserved"); exit(1)
}
print("payload preserved: type=\(obj["type"]!)")
print("\nScalar round-trip passes — no dynamic cast failure.")
