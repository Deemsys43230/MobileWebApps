//
//  GraphQLController.swift
//  NellaiMarts
//
//  Created by admin on 12/07/19.
//  Copyright © 2019 Deemsys. All rights reserved.
//

import Foundation
import GraphQL_Swift



class GraphQLManager: NSObject {
    var defaults : UserDefaults!
    let mockAuth : MockGQLAuthorization!
    let mockAPI : MockAPIDefinition!
    let networkController : GQLNetworkController!
    override init() {
        defaults = UserDefaults.standard
        mockAuth = MockGQLAuthorization(tokenfor: defaults.string(forKey: "token")!)
        mockAPI =  MockAPIDefinition(authorization: mockAuth)
        networkController = GQLNetworkController(apiDefinition: mockAPI)
    }

    /// Function to process GraphQL request
    ///
    /// - Parameters:
    ///   - query: Generic request query object
    ///   - completion: completion handler to handle the response
    func getDataForGraphQLRequest<T:GQLQuery>(withQuery query:T, completion:@escaping (_ result: [String: Any]?, _ error: Error?)-> Void){
        do {
            _ = try networkController.makeGraphQLRequest(query, completion: { (p_results, p_error) in
                if p_error != nil {
                    completion(nil,p_error)
                }else if let results = p_results {
                    do {
                        completion(results,nil)
                    }
                }
            })
        }catch{
            //Any errors that were thrown before the request was made.
            completion(nil,error)
        }
    }
    
}



/// GraphQL Authorization
struct MockGQLAuthorization: GQLAuthorization {
    
    //MARK: Properties
    var clientID: String?
    var apiKey: String?
    var jwt: String?
    
    var authorizationHeader: [String : String] {
        return ["X-Shopify-Storefront-Access-Token": self.apiKey!]
    }
    
    //MARK: init
    init(tokenfor token:String) {
        self.apiKey = token
    }
}

/// GraphQL API Definition
struct MockAPIDefinition: GQLAPIDefinition {
    //MARK: Properties
    var authorization: GQLAuthorization?
    var defaults:UserDefaults!
    var rootRESTURLString: String
    
    var rootWebsocketURLString: String = ""
    
    //MARK: init
    init(authorization: GQLAuthorization? = nil) {
        defaults = UserDefaults.standard
        self.authorization = authorization
        self.rootRESTURLString = defaults.string(forKey: "endpoint")!
        
    }
}



