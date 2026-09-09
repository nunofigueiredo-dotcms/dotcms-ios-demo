// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol DotCMSAPI_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == DotCMSAPI.SchemaMetadata {}

protocol DotCMSAPI_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == DotCMSAPI.SchemaMetadata {}

protocol DotCMSAPI_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == DotCMSAPI.SchemaMetadata {}

protocol DotCMSAPI_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == DotCMSAPI.SchemaMetadata {}

extension DotCMSAPI {
  typealias SelectionSet = DotCMSAPI_SelectionSet

  typealias InlineFragment = DotCMSAPI_InlineFragment

  typealias MutableSelectionSet = DotCMSAPI_MutableSelectionSet

  typealias MutableInlineFragment = DotCMSAPI_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    private static let objectTypeMap: [String: ApolloAPI.Object] = [
      "Author": DotCMSAPI.Objects.Author,
      "Banner": DotCMSAPI.Objects.Banner,
      "BannerCarousel": DotCMSAPI.Objects.BannerCarousel,
      "Blog": DotCMSAPI.Objects.Blog,
      "BlogList": DotCMSAPI.Objects.BlogList,
      "CallToAction": DotCMSAPI.Objects.CallToAction,
      "Doctor": DotCMSAPI.Objects.Doctor,
      "DotAsset": DotCMSAPI.Objects.DotAsset,
      "DotBinary": DotCMSAPI.Objects.DotBinary,
      "DotStoryBlock": DotCMSAPI.Objects.DotStoryBlock,
      "FileAsset": DotCMSAPI.Objects.FileAsset,
      "HealthTip": DotCMSAPI.Objects.HealthTip,
      "Host": DotCMSAPI.Objects.Host,
      "Languagevariable": DotCMSAPI.Objects.Languagevariable,
      "Location": DotCMSAPI.Objects.Location,
      "Product": DotCMSAPI.Objects.Product,
      "Query": DotCMSAPI.Objects.Query,
      "Service": DotCMSAPI.Objects.Service,
      "Vanityurl": DotCMSAPI.Objects.Vanityurl,
      "VtlFile": DotCMSAPI.Objects.VtlFile,
      "dotFavoritePage": DotCMSAPI.Objects.DotFavoritePage,
      "forms": DotCMSAPI.Objects.Forms,
      "htmlpageasset": DotCMSAPI.Objects.Htmlpageasset,
      "persona": DotCMSAPI.Objects.Persona,
      "webPageContent": DotCMSAPI.Objects.WebPageContent
    ]

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      objectTypeMap[typename]
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}