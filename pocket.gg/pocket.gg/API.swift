//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// Represents the source of a stream
public enum StreamSource: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Stream is on twitch.tv channel
  case twitch
  /// Stream is on smashcast.tv channel
  case hitbox
  /// Stream is on a stream.me channel
  case streamme
  /// Stream is on a mixer.com channel
  case mixer
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "TWITCH": self = .twitch
      case "HITBOX": self = .hitbox
      case "STREAMME": self = .streamme
      case "MIXER": self = .mixer
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .twitch: return "TWITCH"
      case .hitbox: return "HITBOX"
      case .streamme: return "STREAMME"
      case .mixer: return "MIXER"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: StreamSource, rhs: StreamSource) -> Bool {
    switch (lhs, rhs) {
      case (.twitch, .twitch): return true
      case (.hitbox, .hitbox): return true
      case (.streamme, .streamme): return true
      case (.mixer, .mixer): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [StreamSource] {
    return [
      .twitch,
      .hitbox,
      .streamme,
      .mixer,
    ]
  }
}

public final class TournamentsByVideogamesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition =
    """
    query TournamentsByVideogames($perPage: Int, $pageNum: Int, $videogameIds: [ID], $featured: Boolean, $upcoming: Boolean) {
      tournaments(query: {perPage: $perPage, page: $pageNum, sortBy: "startAt asc", filter: {upcoming: $upcoming, videogameIds: $videogameIds, isFeatured: $featured}}) {
        __typename
        nodes {
          __typename
          name
          id
          startAt
          endAt
          images {
            __typename
            url
            ratio
          }
        }
      }
    }
    """

  public let operationName = "TournamentsByVideogames"

  public var perPage: Int?
  public var pageNum: Int?
  public var videogameIds: [GraphQLID?]?
  public var featured: Bool?
  public var upcoming: Bool?

  public init(perPage: Int? = nil, pageNum: Int? = nil, videogameIds: [GraphQLID?]? = nil, featured: Bool? = nil, upcoming: Bool? = nil) {
    self.perPage = perPage
    self.pageNum = pageNum
    self.videogameIds = videogameIds
    self.featured = featured
    self.upcoming = upcoming
  }

  public var variables: GraphQLMap? {
    return ["perPage": perPage, "pageNum": pageNum, "videogameIds": videogameIds, "featured": featured, "upcoming": upcoming]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("tournaments", arguments: ["query": ["perPage": GraphQLVariable("perPage"), "page": GraphQLVariable("pageNum"), "sortBy": "startAt asc", "filter": ["upcoming": GraphQLVariable("upcoming"), "videogameIds": GraphQLVariable("videogameIds"), "isFeatured": GraphQLVariable("featured")]]], type: .object(Tournament.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(tournaments: Tournament? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "tournaments": tournaments.flatMap { (value: Tournament) -> ResultMap in value.resultMap }])
    }

    /// Paginated, filterable list of tournaments
    public var tournaments: Tournament? {
      get {
        return (resultMap["tournaments"] as? ResultMap).flatMap { Tournament(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "tournaments")
      }
    }

    public struct Tournament: GraphQLSelectionSet {
      public static let possibleTypes = ["TournamentConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("nodes", type: .list(.object(Node.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(nodes: [Node?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "TournamentConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var nodes: [Node?]? {
        get {
          return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
        }
      }

      public struct Node: GraphQLSelectionSet {
        public static let possibleTypes = ["Tournament"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .scalar(String.self)),
          GraphQLField("id", type: .scalar(GraphQLID.self)),
          GraphQLField("startAt", type: .scalar(String.self)),
          GraphQLField("endAt", type: .scalar(String.self)),
          GraphQLField("images", type: .list(.object(Image.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String? = nil, id: GraphQLID? = nil, startAt: String? = nil, endAt: String? = nil, images: [Image?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Tournament", "name": name, "id": id, "startAt": startAt, "endAt": endAt, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The tournament name
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var id: GraphQLID? {
          get {
            return resultMap["id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// When the tournament Starts
        public var startAt: String? {
          get {
            return resultMap["startAt"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "startAt")
          }
        }

        /// When the tournament ends
        public var endAt: String? {
          get {
            return resultMap["endAt"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endAt")
          }
        }

        public var images: [Image?]? {
          get {
            return (resultMap["images"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Image?] in value.map { (value: ResultMap?) -> Image? in value.flatMap { (value: ResultMap) -> Image in Image(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }, forKey: "images")
          }
        }

        public struct Image: GraphQLSelectionSet {
          public static let possibleTypes = ["Image"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("url", type: .scalar(String.self)),
            GraphQLField("ratio", type: .scalar(Double.self)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(url: String? = nil, ratio: Double? = nil) {
            self.init(unsafeResultMap: ["__typename": "Image", "url": url, "ratio": ratio])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var url: String? {
            get {
              return resultMap["url"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "url")
            }
          }

          public var ratio: Double? {
            get {
              return resultMap["ratio"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "ratio")
            }
          }
        }
      }
    }
  }
}

public final class TournamentByIdQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition =
    """
    query TournamentById($id: ID) {
      tournament(id: $id) {
        __typename
        venueAddress
        lng
        lat
        primaryContact
        primaryContactType
        events {
          __typename
          name
          videogameId
        }
        streams {
          __typename
          id
          streamId
          streamType
          streamName
          streamGame
          streamLogo
          streamSource
          streamTypeId
          streamStatus
          isOnline
          numSetups
          removesTasks
          parentStreamId
        }
      }
    }
    """

  public let operationName = "TournamentById"

  public var id: GraphQLID?

  public init(id: GraphQLID? = nil) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("tournament", arguments: ["id": GraphQLVariable("id")], type: .object(Tournament.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(tournament: Tournament? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "tournament": tournament.flatMap { (value: Tournament) -> ResultMap in value.resultMap }])
    }

    /// Returns a tournament given its id or slug
    public var tournament: Tournament? {
      get {
        return (resultMap["tournament"] as? ResultMap).flatMap { Tournament(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "tournament")
      }
    }

    public struct Tournament: GraphQLSelectionSet {
      public static let possibleTypes = ["Tournament"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("venueAddress", type: .scalar(String.self)),
        GraphQLField("lng", type: .scalar(Double.self)),
        GraphQLField("lat", type: .scalar(Double.self)),
        GraphQLField("primaryContact", type: .scalar(String.self)),
        GraphQLField("primaryContactType", type: .scalar(String.self)),
        GraphQLField("events", type: .list(.object(Event.selections))),
        GraphQLField("streams", type: .list(.object(Stream.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(venueAddress: String? = nil, lng: Double? = nil, lat: Double? = nil, primaryContact: String? = nil, primaryContactType: String? = nil, events: [Event?]? = nil, streams: [Stream?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Tournament", "venueAddress": venueAddress, "lng": lng, "lat": lat, "primaryContact": primaryContact, "primaryContactType": primaryContactType, "events": events.flatMap { (value: [Event?]) -> [ResultMap?] in value.map { (value: Event?) -> ResultMap? in value.flatMap { (value: Event) -> ResultMap in value.resultMap } } }, "streams": streams.flatMap { (value: [Stream?]) -> [ResultMap?] in value.map { (value: Stream?) -> ResultMap? in value.flatMap { (value: Stream) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var venueAddress: String? {
        get {
          return resultMap["venueAddress"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "venueAddress")
        }
      }

      public var lng: Double? {
        get {
          return resultMap["lng"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "lng")
        }
      }

      public var lat: Double? {
        get {
          return resultMap["lat"] as? Double
        }
        set {
          resultMap.updateValue(newValue, forKey: "lat")
        }
      }

      public var primaryContact: String? {
        get {
          return resultMap["primaryContact"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "primaryContact")
        }
      }

      public var primaryContactType: String? {
        get {
          return resultMap["primaryContactType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "primaryContactType")
        }
      }

      public var events: [Event?]? {
        get {
          return (resultMap["events"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Event?] in value.map { (value: ResultMap?) -> Event? in value.flatMap { (value: ResultMap) -> Event in Event(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Event?]) -> [ResultMap?] in value.map { (value: Event?) -> ResultMap? in value.flatMap { (value: Event) -> ResultMap in value.resultMap } } }, forKey: "events")
        }
      }

      public var streams: [Stream?]? {
        get {
          return (resultMap["streams"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Stream?] in value.map { (value: ResultMap?) -> Stream? in value.flatMap { (value: ResultMap) -> Stream in Stream(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Stream?]) -> [ResultMap?] in value.map { (value: Stream?) -> ResultMap? in value.flatMap { (value: Stream) -> ResultMap in value.resultMap } } }, forKey: "streams")
        }
      }

      public struct Event: GraphQLSelectionSet {
        public static let possibleTypes = ["Event"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .scalar(String.self)),
          GraphQLField("videogameId", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String? = nil, videogameId: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "Event", "name": name, "videogameId": videogameId])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Title of event set by organizer
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// Id of the videogame associated with this event
        public var videogameId: Int? {
          get {
            return resultMap["videogameId"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "videogameId")
          }
        }
      }

      public struct Stream: GraphQLSelectionSet {
        public static let possibleTypes = ["Streams"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .scalar(GraphQLID.self)),
          GraphQLField("streamId", type: .scalar(String.self)),
          GraphQLField("streamType", type: .scalar(Int.self)),
          GraphQLField("streamName", type: .scalar(String.self)),
          GraphQLField("streamGame", type: .scalar(String.self)),
          GraphQLField("streamLogo", type: .scalar(String.self)),
          GraphQLField("streamSource", type: .scalar(StreamSource.self)),
          GraphQLField("streamTypeId", type: .scalar(Int.self)),
          GraphQLField("streamStatus", type: .scalar(String.self)),
          GraphQLField("isOnline", type: .scalar(Bool.self)),
          GraphQLField("numSetups", type: .scalar(Int.self)),
          GraphQLField("removesTasks", type: .scalar(Bool.self)),
          GraphQLField("parentStreamId", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil, streamId: String? = nil, streamType: Int? = nil, streamName: String? = nil, streamGame: String? = nil, streamLogo: String? = nil, streamSource: StreamSource? = nil, streamTypeId: Int? = nil, streamStatus: String? = nil, isOnline: Bool? = nil, numSetups: Int? = nil, removesTasks: Bool? = nil, parentStreamId: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "Streams", "id": id, "streamId": streamId, "streamType": streamType, "streamName": streamName, "streamGame": streamGame, "streamLogo": streamLogo, "streamSource": streamSource, "streamTypeId": streamTypeId, "streamStatus": streamStatus, "isOnline": isOnline, "numSetups": numSetups, "removesTasks": removesTasks, "parentStreamId": parentStreamId])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID? {
          get {
            return resultMap["id"] as? GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var streamId: String? {
          get {
            return resultMap["streamId"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "streamId")
          }
        }

        public var streamType: Int? {
          get {
            return resultMap["streamType"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "streamType")
          }
        }

        public var streamName: String? {
          get {
            return resultMap["streamName"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "streamName")
          }
        }

        public var streamGame: String? {
          get {
            return resultMap["streamGame"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "streamGame")
          }
        }

        public var streamLogo: String? {
          get {
            return resultMap["streamLogo"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "streamLogo")
          }
        }

        public var streamSource: StreamSource? {
          get {
            return resultMap["streamSource"] as? StreamSource
          }
          set {
            resultMap.updateValue(newValue, forKey: "streamSource")
          }
        }

        public var streamTypeId: Int? {
          get {
            return resultMap["streamTypeId"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "streamTypeId")
          }
        }

        public var streamStatus: String? {
          get {
            return resultMap["streamStatus"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "streamStatus")
          }
        }

        public var isOnline: Bool? {
          get {
            return resultMap["isOnline"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isOnline")
          }
        }

        public var numSetups: Int? {
          get {
            return resultMap["numSetups"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "numSetups")
          }
        }

        public var removesTasks: Bool? {
          get {
            return resultMap["removesTasks"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "removesTasks")
          }
        }

        public var parentStreamId: Int? {
          get {
            return resultMap["parentStreamId"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "parentStreamId")
          }
        }
      }
    }
  }
}
