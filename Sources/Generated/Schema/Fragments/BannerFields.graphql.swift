// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension DotCMSAPI {
  struct BannerFields: DotCMSAPI.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment BannerFields on Banner { __typename identifier inode title caption buttonText link image { __typename ...ImageFields } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.Banner }
    static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("identifier", DotCMSAPI.ID?.self),
      .field("inode", DotCMSAPI.ID?.self),
      .field("title", String?.self),
      .field("caption", String?.self),
      .field("buttonText", String?.self),
      .field("link", String?.self),
      .field("image", Image.self),
    ] }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      BannerFields.self
    ] }

    var identifier: DotCMSAPI.ID? { __data["identifier"] }
    var inode: DotCMSAPI.ID? { __data["inode"] }
    var title: String? { __data["title"] }
    var caption: String? { __data["caption"] }
    var buttonText: String? { __data["buttonText"] }
    var link: String? { __data["link"] }
    var image: Image { __data["image"] }

    /// Image
    ///
    /// Parent Type: `DotBinary`
    struct Image: DotCMSAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.DotBinary }
      static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .fragment(ImageFields.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BannerFields.Image.self,
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

      struct Fragments: FragmentContainer {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        var imageFields: ImageFields { _toFragment() }
      }
    }
  }

}