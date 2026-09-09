// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension DotCMSAPI {
  struct BlogFields: DotCMSAPI.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment BlogFields on Blog { __typename identifier inode title urlTitle description publishDate urlMap image { __typename ...ImageFields } author { __typename title image { __typename ...ImageFields } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.Blog }
    static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("identifier", DotCMSAPI.ID?.self),
      .field("inode", DotCMSAPI.ID?.self),
      .field("title", String?.self),
      .field("urlTitle", String.self),
      .field("description", String?.self),
      .field("publishDate", String?.self),
      .field("urlMap", String?.self),
      .field("image", Image?.self),
      .field("author", [Author?]?.self),
    ] }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      BlogFields.self
    ] }

    var identifier: DotCMSAPI.ID? { __data["identifier"] }
    var inode: DotCMSAPI.ID? { __data["inode"] }
    var title: String? { __data["title"] }
    var urlTitle: String { __data["urlTitle"] }
    var description: String? { __data["description"] }
    var publishDate: String? { __data["publishDate"] }
    var urlMap: String? { __data["urlMap"] }
    var image: Image? { __data["image"] }
    var author: [Author?]? { __data["author"] }

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
        BlogFields.Image.self,
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

    /// Author
    ///
    /// Parent Type: `Author`
    struct Author: DotCMSAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.Author }
      static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("title", String?.self),
        .field("image", Image?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BlogFields.Author.self
      ] }

      var title: String? { __data["title"] }
      var image: Image? { __data["image"] }

      /// Author.Image
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
          BlogFields.Author.Image.self,
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

}