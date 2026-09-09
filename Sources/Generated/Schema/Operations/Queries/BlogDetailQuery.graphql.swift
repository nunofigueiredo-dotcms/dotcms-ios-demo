// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension DotCMSAPI {
  class BlogDetailQuery: GraphQLQuery {
    static let operationName: String = "BlogDetail"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query BlogDetail($query: String!) { BlogCollection(limit: 1, query: $query) { __typename ...BlogFields body { __typename json } } }"#,
        fragments: [BlogFields.self, ImageFields.self]
      ))

    public var query: String

    public init(query: String) {
      self.query = query
    }

    public var __variables: Variables? { ["query": query] }

    struct Data: DotCMSAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("BlogCollection", [BlogCollection?]?.self, arguments: [
          "limit": 1,
          "query": .variable("query")
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BlogDetailQuery.Data.self
      ] }

      var blogCollection: [BlogCollection?]? { __data["BlogCollection"] }

      /// BlogCollection
      ///
      /// Parent Type: `Blog`
      struct BlogCollection: DotCMSAPI.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.Blog }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("body", Body?.self),
          .fragment(BlogFields.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BlogDetailQuery.Data.BlogCollection.self,
          BlogFields.self
        ] }

        var body: Body? { __data["body"] }
        var identifier: DotCMSAPI.ID? { __data["identifier"] }
        var inode: DotCMSAPI.ID? { __data["inode"] }
        var title: String? { __data["title"] }
        var urlTitle: String { __data["urlTitle"] }
        var description: String? { __data["description"] }
        var publishDate: String? { __data["publishDate"] }
        var urlMap: String? { __data["urlMap"] }
        var image: Image? { __data["image"] }
        var author: [Author?]? { __data["author"] }

        struct Fragments: FragmentContainer {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          var blogFields: BlogFields { _toFragment() }
        }

        /// BlogCollection.Body
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
            BlogDetailQuery.Data.BlogCollection.Body.self
          ] }

          var json: DotCMSAPI.JSON? { __data["json"] }
        }

        typealias Image = BlogFields.Image

        typealias Author = BlogFields.Author
      }
    }
  }

}