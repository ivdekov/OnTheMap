//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Iavor Dekov on 7/22/16.
//  Copyright © 2016 Iavor Dekov. All rights reserved.
//

import Foundation

// MARK: - UdacityClient

class UdacityClient: NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // authentication state
    var sessionID: String? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(method: String, jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: method)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
			
			func sendError(error: String) {
				print(error)
				let userInfo = [NSLocalizedDescriptionKey : error]
				completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
			}
			
			// Was there an error?
			guard error == nil else {
				sendError("There was an error with your request: \(error)")
				return
			}
			
			// Did the response have a successfull status code?
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
				sendError("Request returned wrong statusCode")
				return
			}
			
			// Was there any data returned?
			guard let data = data else {
				sendError("No data was returned by the request!")
				return
			}
			
			// NEED TO SKIP THE FIRST 5 CHARACTERS FOR ALL RESPONSES FROM THE UDACITY API
			let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
			
			// Parse the data and use the data (happens in completion handler)
			self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
		}
		
		task.resume()
    }
	
	// given raw JSON, return a usable Foundation object
	// Method taken from TheMovieManager app from the Udacity course iOS Networking With Swift
	private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
		
		var parsedResult: AnyObject!
		do {
			parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
		} catch {
			let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
			completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
		}
		
		completionHandlerForConvertData(result: parsedResult, error: nil)
	}
	
    // MARK: Shared Instance
	
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}