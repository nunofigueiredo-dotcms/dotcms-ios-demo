import Foundation

// Regression test: dotCMS returns StoryBlock bodies as a JSON object, and
// Apollo hands them over wrapped in AnyHashable. Both shapes must parse.
//
// Simulates what Apollo hands over: the decoded JSON graph wrapped in
// AnyHashable, which is what broke decoding when JSON was a typealias to String.
let data = try! Data(contentsOf: URL(fileURLWithPath: "body_only.json"))
let raw = try! JSONSerialization.jsonObject(with: data)

func toAnyHashable(_ v: Any) -> AnyHashable {
    switch v {
    case let d as [String: Any]: return d.mapValues { toAnyHashable($0) } as AnyHashable
    case let a as [Any]: return a.map { toAnyHashable($0) } as AnyHashable
    case let s as String: return s
    case let n as NSNumber: return n
    default: return String(describing: v)
    }
}

let wrapped: AnyHashable = toAnyHashable(raw)

print("=== Test 1: plain Foundation object ===")
if let sb = StoryBlock(json: raw) {
    print("  parsed \(sb.nodes.count) nodes")
} else { print("  FAILED to parse"); exit(1) }

print("=== Test 2: AnyHashable-wrapped (the Apollo shape) ===")
if let sb = StoryBlock(json: wrapped) {
    print("  parsed \(sb.nodes.count) nodes")
    for n in sb.nodes.prefix(4) {
        switch n {
        case .heading(let l, let t): print("    heading(h\(l)): \(t.prefix(44))")
        case .paragraph(let t):      print("    paragraph:    \(t.prefix(44))")
        case .bulletList(let i):     print("    bulletList:   \(i.count) items")
        case .unsupported(let t):    print("    UNSUPPORTED:  \(t)")
        default:                     print("    other")
        }
    }
    let unsupported = sb.nodes.filter { if case .unsupported = $0 { return true }; return false }
    print("  unsupported nodes: \(unsupported.count)")
} else { print("  FAILED to parse"); exit(1) }

print("=== Test 3: nil and garbage degrade safely ===")
var ok = true
ok = ok && StoryBlock(json: nil) == nil
print("  nil        -> \(StoryBlock(json: nil) == nil ? "nil (ok)" : "unexpected")")
print("  string     -> \(StoryBlock(json: "not json") == nil ? "nil (ok)" : "unexpected")")
ok = ok && StoryBlock(json: [String: Any]()) == nil
print("  empty dict -> \(StoryBlock(json: [String: Any]()) == nil ? "nil (ok)" : "unexpected")")
guard ok else { print("FAILED"); exit(1) }
print("\nAll StoryBlock tests passed.")
