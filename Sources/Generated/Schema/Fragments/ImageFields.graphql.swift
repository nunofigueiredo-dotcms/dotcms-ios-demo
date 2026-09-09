// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension DotCMSAPI {
  struct ImageFields: DotCMSAPI.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment ImageFields on DotBinary { __typename path idPath versionPath name isImage mime width height }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.DotBinary }
    static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("path", String?.self),
      .field("idPath", String?.self),
      .field("versionPath", String?.self),
      .field("name", String?.self),
      .field("isImage", Bool?.self),
      .field("mime", String?.self),
      .field("width", DotCMSAPI.Long?.self),
      .field("height", DotCMSAPI.Long?.self),
    ] }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      ImageFields.self
    ] }

    var path: String? { __data["path"] }
    var idPath: String? { __data["idPath"] }
    var versionPath: String? { __data["versionPath"] }
    var name: String? { __data["name"] }
    var isImage: Bool? { __data["isImage"] }
    var mime: String? { __data["mime"] }
    var width: DotCMSAPI.Long? { __data["width"] }
    var height: DotCMSAPI.Long? { __data["height"] }
  }

}