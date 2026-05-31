import Foundation
import Moya
import Alamofire

class DefaultAlamofireSession: Alamofire.Session {
    static let shared: DefaultAlamofireSession = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 50 // as seconds, you can set your request timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return DefaultAlamofireSession(configuration: configuration)
    }()
}

protocol Networkable {
    var provider: MoyaProvider<API> { get }
    func showRooms(endpoint: String,parameters : [String:Any],completion : @escaping (Result<ShowRoomM,Error>) -> ())
    func showUserJoinedRooms(endpoint: String,parameters : [String:Any],completion : @escaping (Result<ShowUserJoinedRoomsM,Error>) -> ())
    func joinRoom(endpoint: String,parameters : [String:Any],completion : @escaping (Result<JoinRoomM,Error>) -> ())
    func leaveRoom(endpoint: String,parameters : [String:Any],completion : @escaping (Result<LeaveRoomM,Error>) -> ())
    func showRoomDetail(endpoint: String,parameters : [String:Any],completion : @escaping (Result<ShowRoomDetailM,Error>) -> ())
    func AddRoom(endpoint: String,parameters : [String:Any],completion : @escaping (Result<AddRoomM,Error>) -> ())
    func deleteRoom(endpoint: String,parameters : [String:Any],completion : @escaping (Result<DeleteRoomM,Error>) -> ())
    func assignModerator(endpoint: String,parameters : [String:Any],completion : @escaping (Result<AssignModeratorM,Error>) -> ())
    func showRelatedVideos(endpoint: String,parameters : [String:Any],completion : @escaping (Result<showVideosModel,Error>) -> ())
    func showVideoDetail(endpoint: String,parameters : [String:Any],completion : @escaping (Result<VideoDetailModel,Error>) -> ())
    func showRegisteredContacts(endpoint: String,parameters : [String:Any],completion : @escaping (Result<ShowRegisteredContactsM,Error>) -> ())
    func addPromotion(endpoint: String,parameters : [String:Any],completion : @escaping (Result<AddPromotionM,Error>) -> ())
}

class NetworkManager: Networkable {
    func showRegisteredContacts(endpoint: String, parameters: [String : Any], completion: @escaping (Result<ShowRegisteredContactsM, Error>) -> ()) {
        request(target: .showRegisteredContacts(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func showVideoDetail(endpoint: String, parameters: [String : Any], completion: @escaping (Result<VideoDetailModel, Error>) -> ()) {
        request(target: .showVideoDetail(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func showRelatedVideos(endpoint: String, parameters: [String : Any], completion: @escaping (Result<showVideosModel, Error>) -> ()) {
        request(target: .showRelatedVideos(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func assignModerator(endpoint: String, parameters: [String : Any], completion: @escaping (Result<AssignModeratorM, Error>) -> ()) {
        request(target: .assignModerator(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func deleteRoom(endpoint: String, parameters: [String : Any], completion: @escaping (Result<DeleteRoomM, Error>) -> ()) {
        request(target: .deleteRoom(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func AddRoom(endpoint: String, parameters: [String : Any], completion: @escaping (Result<AddRoomM, Error>) -> ()) {
        request(target: .AddRoom(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func showRoomDetail(endpoint: String, parameters: [String : Any], completion: @escaping (Result<ShowRoomDetailM, Error>) -> ()) {
        request(target: .showRoomDetail(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func leaveRoom(endpoint: String, parameters: [String : Any], completion: @escaping (Result<LeaveRoomM, Error>) -> ()) {
        request(target: .leaveRoom(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func joinRoom(endpoint: String, parameters: [String : Any], completion: @escaping (Result<JoinRoomM, Error>) -> ()) {
        request(target: .joinRoom(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func showUserJoinedRooms(endpoint: String, parameters: [String : Any], completion: @escaping (Result<ShowUserJoinedRoomsM, Error>) -> ()) {
        request(target: .showUserJoinedRooms(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    func showRooms(endpoint: String, parameters: [String : Any], completion: @escaping (Result<ShowRoomM, Error>) -> ()) {
        request(target: .showRooms(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    
    func addPromotion(endpoint: String, parameters: [String : Any], completion: @escaping (Result<AddPromotionM, Error>) -> ()) {
        request(target: .addPromotion(endpoint: endpoint, parameters : parameters), completion: completion)
    }
    
    
    #if DEBUG
    var provider = MoyaProvider<API>(session: DefaultAlamofireSession.shared, plugins: [NetworkLoggerPlugin()])
    #else
    let provider = MoyaProvider<API>(session: DefaultAlamofireSession.shared)
    #endif
    
}

//private extension NetworkManager {
//    private func request<T: Decodable>(target: API, completion: @escaping (Result<T, Error>) -> ()) {
//        provider.request(target) { result in
//            switch result {
//            case let .success(response):
//                do {
//                    let json = try! JSONSerialization.jsonObject(with: response.data, options: [])
////                    if StaticData.singleton.Logs == "ON" {
//                        print(json)
////                    }
//                    
//                    let dic = json as! NSDictionary
//                    let code = dic["code"] as! NSNumber
//                    if(String(describing: code) == "200"){
////                        if let msg = dic["msg"] as? String {
//////                            let msg = dic["msg"] as! String
//////                            let error = NSError(domain: "", code: 201, userInfo: [ NSLocalizedDescriptionKey: msg]) as Error
//////                            completion(.failure(error))
////
////                            let results = try JSONDecoder().decode(T.self, from: response.data)
////                            completion(.success(results))
////                        }else {
//                            let results = try JSONDecoder().decode(T.self, from: response.data)
//                        print(result)
//                            completion(.success(results))
////                        }
//                       
//                    }else{
//                        let msg = dic["msg"] as! String
//                        let error = NSError(domain: "", code: 201, userInfo: [ NSLocalizedDescriptionKey: msg]) as Error
//                        completion(.failure(error))
//                    }
//                    
//                } catch let error {
//                    print(String(describing: error))
//                    completion(.failure(error))
//                }
//            case let .failure(error):
//                completion(.failure(error))
//            }
//        }
//    }
//}
//

private extension NetworkManager {
    private func request<T: Decodable>(target: API, completion: @escaping (Result<T, Error>) -> ()) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode(T.self, from: response.data)
                    completion(.success(results))
                } catch let error {
                    print(String(describing: error))
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}


