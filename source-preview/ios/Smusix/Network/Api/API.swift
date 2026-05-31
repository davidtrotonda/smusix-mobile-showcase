import Foundation
import Moya

enum API {
    case showRooms(endpoint:String, parameters : [String:Any])
    case joinRoom(endpoint:String, parameters : [String:Any])
    case leaveRoom(endpoint:String, parameters : [String:Any])
    case deleteRoom(endpoint:String, parameters : [String:Any])
    case showUserJoinedRooms(endpoint:String, parameters : [String:Any])
    case showRoomDetail(endpoint:String, parameters : [String:Any])
    case AddRoom(endpoint:String, parameters : [String:Any])
    case assignModerator(endpoint:String, parameters : [String:Any])
    // Home screen apis
    case showRelatedVideos(endpoint:String, parameters : [String:Any])
    case showVideoDetail(endpoint:String, parameters : [String:Any])
    case showRegisteredContacts(endpoint:String, parameters : [String:Any])
    case addPromotion(endpoint:String, parameters : [String:Any])
    
}

extension API: TargetType {
    //    1
    var baseURL: URL {
        guard let url = URL(string: BASE_URL) else { fatalError() }
        return url
    }
    
    var headers: [String : String]? {
        return ["Api-Key": API_KEY]
    }
    //    2
    var path: String {
        switch self {
        case .showRooms(endpoint: let endpoint, parameters: _):
            return endpoint
        case .joinRoom(endpoint: let endpoint, parameters: _):
            return endpoint
        case .leaveRoom(endpoint: let endpoint, parameters: _):
            return endpoint
        case .showUserJoinedRooms(endpoint: let endpoint, parameters: _):
            return endpoint
        case .showRoomDetail(endpoint: let endpoint, parameters: _):
            return endpoint
        case .AddRoom(endpoint: let endpoint, parameters: _):
            return endpoint
        case .deleteRoom(endpoint: let endpoint, parameters: _):
            return endpoint
        case .assignModerator(endpoint: let endpoint, parameters: _):
            return endpoint
            // Home screen apis
        case .showRelatedVideos(endpoint: let endpoint, parameters: _):
            return endpoint
        case .showVideoDetail(endpoint: let endpoint, parameters: _):
            return endpoint
        case .showRegisteredContacts(endpoint: let endpoint, parameters: _):
            return endpoint
        case .addPromotion(endpoint: let endpoint, parameters: _):
            return endpoint
        }
    }
    //    3
    var method : Moya.Method {
        switch self {
      
        case .showRooms(endpoint: _, parameters: _):
            return .post
        case .joinRoom(endpoint: _, parameters: _):
            return .post
        case .leaveRoom(endpoint: _, parameters: _):
            return .post
        case .showUserJoinedRooms(endpoint: _, parameters: _):
            return .post
        case .showRoomDetail(endpoint: _, parameters: _):
            return .post
        case .AddRoom(endpoint: _, parameters: _):
            return .post
        case .deleteRoom(endpoint: _, parameters: _):
            return .post
        case .assignModerator(endpoint: _, parameters: _):
            return .post
            // Home screen apis
        case .showRelatedVideos(endpoint: _, parameters: _):
            return .post
        case .showVideoDetail(endpoint: _, parameters: _):
            return .post
        case .showRegisteredContacts(endpoint: _, parameters: _):
            return .post
        case .addPromotion(endpoint: _, parameters: _):
            return .post
        }
    }
    //    4
    public var parameterEncoding: ParameterEncoding {
        switch self {
      
        case .showRooms(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .joinRoom(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .leaveRoom(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .showUserJoinedRooms(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .showRoomDetail(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .AddRoom(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .deleteRoom(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .assignModerator(endpoint: _, parameters: _):
            return JSONEncoding.default
            // Home screen apis
        case .showRelatedVideos(endpoint:_, parameters: _):
            return JSONEncoding.default
        case .showVideoDetail(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .showRegisteredContacts(endpoint: _, parameters: _):
            return JSONEncoding.default
        case .addPromotion(endpoint: _, parameters: _):
            return JSONEncoding.default
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    //    6_
    var task: Task {
        switch self {
       
        case .showRooms(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .joinRoom(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .leaveRoom(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .showUserJoinedRooms(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .showRoomDetail(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .AddRoom(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .deleteRoom(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .assignModerator(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
            // Home screen apis
        case .showRelatedVideos(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .showVideoDetail(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .showRegisteredContacts(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        case .addPromotion(endpoint: _, parameters: let parameters):
            return .requestParameters(parameters: parameters , encoding: parameterEncoding)
        }
    }
    //    7
    
}
