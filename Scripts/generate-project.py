#!/usr/bin/env python3
"""Generate DotCMSDemo.xcodeproj deterministically.

Written rather than using XcodeGen/Tuist so the project needs no extra
toolchain: `python3 Scripts/generate-project.py` is enough.
"""
import hashlib
import os
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
PROJECT = ROOT / "DotCMSDemo.xcodeproj"
APP = "DotCMSDemo"
BUNDLE_ID = "com.dotcms.demo.ios"
DEPLOYMENT = "17.0"


def uid(*parts):
    """Stable 24-hex-char id derived from the path, so regeneration is a no-op."""
    h = hashlib.sha256("::".join(parts).encode()).hexdigest()[:24]
    return h.upper()


def swift_sources():
    out = []
    for base in ["Sources"]:
        for p in sorted((ROOT / base).rglob("*.swift")):
            out.append(str(p.relative_to(ROOT)))
    return out


def resources():
    out = []
    for name in ["Config.plist", "Assets.xcassets"]:
        if (ROOT / name).exists():
            out.append(name)
    return out


def main():
    sources = swift_sources()
    res = resources()

    # --- object ids -------------------------------------------------------
    proj_id = uid("project")
    target_id = uid("target", APP)
    group_root = uid("group", "root")
    group_products = uid("group", "products")
    product_id = uid("product", APP)
    cfg_list_proj = uid("cfglist", "project")
    cfg_list_target = uid("cfglist", "target")
    cfg_debug_p = uid("cfg", "project", "Debug")
    cfg_release_p = uid("cfg", "project", "Release")
    cfg_debug_t = uid("cfg", "target", "Debug")
    cfg_release_t = uid("cfg", "target", "Release")
    phase_sources = uid("phase", "sources")
    phase_resources = uid("phase", "resources")
    phase_frameworks = uid("phase", "frameworks")
    pkg_apollo = uid("pkg", "apollo")
    pkgprod_apollo = uid("pkgprod", "Apollo")
    build_apollo = uid("build", "Apollo")

    file_refs = {}
    build_files = {}
    for s in sources + res:
        file_refs[s] = uid("fileref", s)
        build_files[s] = uid("buildfile", s)

    L = []
    a = L.append
    a("// !$*UTF8*$!")
    a("{")
    a("\tarchiveVersion = 1;")
    a("\tclasses = {};")
    a("\tobjectVersion = 56;")
    a("\tobjects = {")

    # PBXBuildFile
    a("\n/* Begin PBXBuildFile section */")
    for s in sources:
        a(f'\t\t{build_files[s]} /* {os.path.basename(s)} in Sources */ = '
          f'{{isa = PBXBuildFile; fileRef = {file_refs[s]}; }};')
    for s in res:
        a(f'\t\t{build_files[s]} /* {s} in Resources */ = '
          f'{{isa = PBXBuildFile; fileRef = {file_refs[s]}; }};')
    a(f'\t\t{build_apollo} /* Apollo in Frameworks */ = {{isa = PBXBuildFile; '
      f'productRef = {pkgprod_apollo}; }};')
    a("/* End PBXBuildFile section */")

    # PBXFileReference
    a("\n/* Begin PBXFileReference section */")
    a(f'\t\t{product_id} /* {APP}.app */ = {{isa = PBXFileReference; '
      f'explicitFileType = wrapper.application; includeInIndex = 0; '
      f'path = {APP}.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
    for s in sources:
        a(f'\t\t{file_refs[s]} /* {os.path.basename(s)} */ = {{isa = PBXFileReference; '
          f'lastKnownFileType = sourcecode.swift; name = "{os.path.basename(s)}"; '
          f'path = "{s}"; sourceTree = "<group>"; }};')
    for s in res:
        ftype = ("folder.assetcatalog" if s.endswith("xcassets") else "text.plist.xml")
        a(f'\t\t{file_refs[s]} /* {s} */ = {{isa = PBXFileReference; '
          f'lastKnownFileType = {ftype}; path = "{s}"; sourceTree = "<group>"; }};')
    a("/* End PBXFileReference section */")

    # PBXGroup
    a("\n/* Begin PBXGroup section */")
    children = "\n".join(
        f'\t\t\t\t{file_refs[s]} /* {os.path.basename(s)} */,' for s in sources + res
    )
    a(f'\t\t{group_root} = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n{children}\n'
      f'\t\t\t\t{group_products} /* Products */,\n\t\t\t);\n\t\t\tsourceTree = "<group>";\n\t\t}};')
    a(f'\t\t{group_products} /* Products */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n'
      f'\t\t\t\t{product_id} /* {APP}.app */,\n\t\t\t);\n\t\t\tname = Products;\n'
      f'\t\t\tsourceTree = "<group>";\n\t\t}};')
    a("/* End PBXGroup section */")

    # PBXNativeTarget
    a("\n/* Begin PBXNativeTarget section */")
    a(f'''\t\t{target_id} /* {APP} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {cfg_list_target};
\t\t\tbuildPhases = (
\t\t\t\t{phase_sources},
\t\t\t\t{phase_frameworks},
\t\t\t\t{phase_resources},
\t\t\t);
\t\t\tbuildRules = ();
\t\t\tdependencies = ();
\t\t\tname = {APP};
\t\t\tpackageProductDependencies = (
\t\t\t\t{pkgprod_apollo},
\t\t\t);
\t\t\tproductName = {APP};
\t\t\tproductReference = {product_id};
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};''')
    a("/* End PBXNativeTarget section */")

    # PBXProject
    a("\n/* Begin PBXProject section */")
    a(f'''\t\t{proj_id} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1600;
\t\t\t\tLastUpgradeCheck = 1600;
\t\t\t\tTargetAttributes = {{ {target_id} = {{ CreatedOnToolsVersion = 16.0; }}; }};
\t\t\t}};
\t\t\tbuildConfigurationList = {cfg_list_proj};
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = ( en, Base );
\t\t\tmainGroup = {group_root};
\t\t\tpackageReferences = (
\t\t\t\t{pkg_apollo},
\t\t\t);
\t\t\tproductRefGroup = {group_products};
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{target_id},
\t\t\t);
\t\t}};''')
    a("/* End PBXProject section */")

    # Phases
    a("\n/* Begin PBXSourcesBuildPhase section */")
    src_files = "\n".join(f'\t\t\t\t{build_files[s]},' for s in sources)
    a(f'\t\t{phase_sources} = {{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n'
      f'\t\t\tfiles = (\n{src_files}\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};')
    a("/* End PBXSourcesBuildPhase section */")

    a("\n/* Begin PBXResourcesBuildPhase section */")
    res_files = "\n".join(f'\t\t\t\t{build_files[s]},' for s in res)
    a(f'\t\t{phase_resources} = {{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n'
      f'\t\t\tfiles = (\n{res_files}\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};')
    a("/* End PBXResourcesBuildPhase section */")

    a("\n/* Begin PBXFrameworksBuildPhase section */")
    a(f'\t\t{phase_frameworks} = {{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n'
      f'\t\t\tfiles = (\n\t\t\t\t{build_apollo},\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};')
    a("/* End PBXFrameworksBuildPhase section */")

    # Build configurations
    common = f'''\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = {DEPLOYMENT};
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tSWIFT_VERSION = 5.0;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;'''

    a("\n/* Begin XCBuildConfiguration section */")
    for cid, name, extra in [
        (cfg_debug_p, "Debug",
         "\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;\n"
         "\t\t\t\tENABLE_TESTABILITY = YES;\n"
         "\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;\n"
         '\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";\n'
         "\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = \"-Onone\";\n"
         "\t\t\t\tONLY_ACTIVE_ARCH = YES;"),
        (cfg_release_p, "Release",
         '\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";\n'
         "\t\t\t\tENABLE_NS_ASSERTIONS = NO;\n"
         '\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;'),
    ]:
        a(f'\t\t{cid} /* {name} */ = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n'
          f'{common}\n{extra}\n\t\t\t}};\n\t\t\tname = {name};\n\t\t}};')

    target_common = f'''\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCODE_SIGN_IDENTITY = "-";
\t\t\t\tCODE_SIGN_ENTITLEMENTS = DotCMSDemo.entitlements;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
\t\t\t\tINFOPLIST_KEY_NSAppTransportSecurity_NSAllowsLocalNetworking = YES;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";'''

    for cid, name in [(cfg_debug_t, "Debug"), (cfg_release_t, "Release")]:
        a(f'\t\t{cid} /* {name} */ = {{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = {{\n'
          f'{target_common}\n\t\t\t}};\n\t\t\tname = {name};\n\t\t}};')
    a("/* End XCBuildConfiguration section */")

    a("\n/* Begin XCConfigurationList section */")
    a(f'\t\t{cfg_list_proj} = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n'
      f'\t\t\t\t{cfg_debug_p},\n\t\t\t\t{cfg_release_p},\n\t\t\t);\n'
      f'\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};')
    a(f'\t\t{cfg_list_target} = {{\n\t\t\tisa = XCConfigurationList;\n\t\t\tbuildConfigurations = (\n'
      f'\t\t\t\t{cfg_debug_t},\n\t\t\t\t{cfg_release_t},\n\t\t\t);\n'
      f'\t\t\tdefaultConfigurationIsVisible = 0;\n\t\t\tdefaultConfigurationName = Release;\n\t\t}};')
    a("/* End XCConfigurationList section */")

    # SPM
    a("\n/* Begin XCRemoteSwiftPackageReference section */")
    a(f'''\t\t{pkg_apollo} /* XCRemoteSwiftPackageReference "apollo-ios" */ = {{
\t\t\tisa = XCRemoteSwiftPackageReference;
\t\t\trepositoryURL = "https://github.com/apollographql/apollo-ios.git";
\t\t\trequirement = {{
\t\t\t\tkind = upToNextMajorVersion;
\t\t\t\tminimumVersion = 1.9.0;
\t\t\t}};
\t\t}};''')
    a("/* End XCRemoteSwiftPackageReference section */")

    a("\n/* Begin XCSwiftPackageProductDependency section */")
    a(f'\t\t{pkgprod_apollo} /* Apollo */ = {{\n\t\t\tisa = XCSwiftPackageProductDependency;\n'
      f'\t\t\tpackage = {pkg_apollo};\n\t\t\tproductName = Apollo;\n\t\t}};')
    a("/* End XCSwiftPackageProductDependency section */")

    a("\t};")
    a(f"\trootObject = {proj_id};")
    a("}")

    PROJECT.mkdir(exist_ok=True)
    (PROJECT / "project.pbxproj").write_text("\n".join(L) + "\n")

    shared = PROJECT / "xcshareddata" / "xcschemes"
    shared.mkdir(parents=True, exist_ok=True)
    (shared / f"{APP}.xcscheme").write_text(SCHEME.format(
        target_id=target_id, app=APP,
        blueprint=f"{APP}.xcodeproj"))
    print(f"generated {PROJECT.relative_to(ROOT)} ({len(sources)} sources, {len(res)} resources)")


SCHEME = '''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion = "1600" version = "1.7">
   <BuildAction parallelizeBuildables = "YES" buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting = "YES" buildForRunning = "YES"
                           buildForProfiling = "YES" buildForArchiving = "YES"
                           buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{target_id}"
               BuildableName = "{app}.app"
               BlueprintName = "{app}"
               ReferencedContainer = "container:{blueprint}">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
               selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables></Testables>
   </TestAction>
   <LaunchAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
                 selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
                 launchStyle = "0" useCustomWorkingDirectory = "NO" ignoresPersistentStateOnLaunch = "NO"
                 debugDocumentVersioning = "YES" debugServiceExtension = "internal" allowLocationSimulation = "YES">
      <BuildableProductRunnable runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{target_id}"
            BuildableName = "{app}.app"
            BlueprintName = "{app}"
            ReferencedContainer = "container:{blueprint}">
         </BuildableReference>
      </BuildableProductRunnable>
      <EnvironmentVariables>
         <!-- Reads DOTCMS_AUTH_TOKEN from the environment Xcode was launched
              with, so no secret is stored in this tracked file. Either launch
              Xcode from a shell that exports it, or replace $(DOTCMS_AUTH_TOKEN)
              with the literal token here (this file is tracked - do not commit
              that change). -->
         <EnvironmentVariable key = "DOTCMS_AUTH_TOKEN" value = "$(DOTCMS_AUTH_TOKEN)" isEnabled = "YES">
         </EnvironmentVariable>
      </EnvironmentVariables>
   </LaunchAction>
   <ProfileAction buildConfiguration = "Release" shouldUseLaunchSchemeArgsEnv = "YES" savedToolIdentifier = ""
                  useCustomWorkingDirectory = "NO" debugDocumentVersioning = "YES">
   </ProfileAction>
   <AnalyzeAction buildConfiguration = "Debug"></AnalyzeAction>
   <ArchiveAction buildConfiguration = "Release" revealArchiveInOrganizer = "YES"></ArchiveAction>
</Scheme>
'''

if __name__ == "__main__":
    main()
