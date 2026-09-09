// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension DotCMSAPI {
  struct WebPageContentFields: DotCMSAPI.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment WebPageContentFields on webPageContent { __typename identifier inode title body { __typename json } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.WebPageContent }
    static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("identifier", DotCMSAPI.ID?.self),
      .field("inode", DotCMSAPI.ID?.self),
      .field("title", String?.self),
      .field("body", Body.self),
    ] }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      WebPageContentFields.self
    ] }

    var identifier: DotCMSAPI.ID? { __data["identifier"] }
    var inode: DotCMSAPI.ID? { __data["inode"] }
    var title: String? { __data["title"] }
    var body: Body { __data["body"] }

    /// Body
    ///
    /// Parent Type: `DotStoryBlock`
    struct Body: DotCMSAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.DotStoryBlock }
      static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("json", DotCMSAPI.JSON?.self),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        WebPageContentFields.Body.self
      ] }

      var json: DotCMSAPI.JSON? { __data["json"] }
    }
  }

}