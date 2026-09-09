#!/usr/bin/env python3
"""Convert a GraphQL introspection JSON response into stable SDL.

Output is deterministically sorted so that a diff against the committed schema
reflects real schema changes, never server-side ordering noise.
"""
import json
import sys

BUILTIN_SCALARS = {"String", "Int", "Float", "Boolean", "ID"}


def type_ref(t):
    kind = t.get("kind")
    if kind == "NON_NULL":
        return type_ref(t["ofType"]) + "!"
    if kind == "LIST":
        return "[" + type_ref(t["ofType"]) + "]"
    return t.get("name") or "?"


def fmt_args(args):
    if not args:
        return ""
    parts = []
    for a in sorted(args, key=lambda x: x["name"]):
        s = f"{a['name']}: {type_ref(a['type'])}"
        if a.get("defaultValue") is not None:
            s += f" = {a['defaultValue']}"
        parts.append(s)
    return "(" + ", ".join(parts) + ")"


def emit(t, out):
    kind, name = t["kind"], t["name"]
    if name.startswith("__"):
        return

    if kind == "SCALAR":
        if name not in BUILTIN_SCALARS:
            out.append(f"scalar {name}")
            out.append("")
        return

    if kind in ("OBJECT", "INTERFACE"):
        keyword = "type" if kind == "OBJECT" else "interface"
        ifaces = sorted(i["name"] for i in (t.get("interfaces") or []))
        impl = f" implements {' & '.join(ifaces)}" if ifaces else ""
        out.append(f"{keyword} {name}{impl} {{")
        for f in sorted(t.get("fields") or [], key=lambda x: x["name"]):
            out.append(f"  {f['name']}{fmt_args(f.get('args'))}: {type_ref(f['type'])}")
        out.append("}")
        out.append("")
        return

    if kind == "INPUT_OBJECT":
        out.append(f"input {name} {{")
        for f in sorted(t.get("inputFields") or [], key=lambda x: x["name"]):
            line = f"  {f['name']}: {type_ref(f['type'])}"
            if f.get("defaultValue") is not None:
                line += f" = {f['defaultValue']}"
            out.append(line)
        out.append("}")
        out.append("")
        return

    if kind == "ENUM":
        out.append(f"enum {name} {{")
        for v in sorted(t.get("enumValues") or [], key=lambda x: x["name"]):
            out.append(f"  {v['name']}")
        out.append("}")
        out.append("")
        return

    if kind == "UNION":
        members = sorted(p["name"] for p in (t.get("possibleTypes") or []))
        out.append(f"union {name} = {' | '.join(members)}")
        out.append("")


def main():
    raw = json.load(open(sys.argv[1]))
    if "errors" in raw and raw["errors"]:
        sys.stderr.write("GraphQL introspection failed:\n")
        sys.stderr.write(json.dumps(raw["errors"], indent=2) + "\n")
        sys.exit(1)
    schema = raw["data"]["__schema"]

    out = ["# GENERATED FILE - do not edit by hand.",
           "# Regenerate with Scripts/download-schema.sh",
           ""]

    q = (schema.get("queryType") or {}).get("name")
    m = (schema.get("mutationType") or {}).get("name")
    out.append("schema {")
    if q:
        out.append(f"  query: {q}")
    if m:
        out.append(f"  mutation: {m}")
    out.append("}")
    out.append("")

    for t in sorted(schema["types"], key=lambda x: (x["kind"], x["name"])):
        emit(t, out)

    sys.stdout.write("\n".join(out).rstrip() + "\n")


if __name__ == "__main__":
    main()
