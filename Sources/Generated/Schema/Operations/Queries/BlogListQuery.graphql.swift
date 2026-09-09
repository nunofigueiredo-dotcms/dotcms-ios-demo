// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension DotCMSAPI {
  class BlogListQuery: GraphQLQuery {
    static let operationName: String = "BlogList"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query BlogList($limit: Int!, $offset: Int!, $query: String!) { BlogCollection( limit: $limit offset: $offset query: $query sortBy: "Blog.publishDate desc" ) { __typename ...BlogFields } }"#,
        fragments: [BlogFields.self, ImageFields.self]
      ))

    public var limit: Int
    public var offset: Int
    public var query: String

    public init(
      limit: Int,
      offset: Int,
      query: String
    ) {
      self.limit = limit
      self.offset = offset
      self.query = query
    }

    public var __variables: Variables? { [
      "limit": limit,
      "offset": offset,
      "query": query
    ] }

    struct Data: DotCMSAPI.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { DotCMSAPI.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("BlogCollection", [BlogCollection?]?.self, arguments: [
          "limit": .variable("limit"),
          "offset": .variable("offset"),
          "query": .variable("query"),
          "sortBy": "Blog.publishDate desc"
        ]),
      ] }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BlogListQuery.Data.self
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
          .fragment(BlogFields.self),
        ] }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BlogListQuery.Data.BlogCollection.self,
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

        struct Fragments: FragmentContainer {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          var blogFields: BlogFields { _toFragment() }
        }

        typealias Image = BlogFields.Image

        typealias Author = BlogFields.Author
      }
    }
  }

}