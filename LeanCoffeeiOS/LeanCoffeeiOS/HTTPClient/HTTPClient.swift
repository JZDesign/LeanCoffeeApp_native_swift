import Foundation

let rootURL = "https://lean-coffee-service.herokuapp.com/api"

class HttpClient {


    // MARK: - Setup


    func createURL(from string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw HTTPClientError.invalidURL
        }
        
        return url
    }
    
    func createRequest<T: Codable>(
        fromURL url: URL,
        withBody body: T?,
        withHeaders headers: [String : String] = [:],
        withMethod method: HTTPMethod
    ) throws -> URLRequest {
        
        var request = URLRequest(url: url)
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        request.httpMethod = method.allCaps
        
        if method == .post {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }


    // MARK: - Make Request


    func makeRequest(
        _ request: URLRequest,
        acceptedStatusCodes: Range<Int> = (200..<300)
    ) async throws -> Data {
        let (data, res) = try await URLSession.shared.data(for: request)
        guard let response = res as? HTTPURLResponse else {
            throw HTTPClientError.couldNotParseServerResponse
        }
        
        guard acceptedStatusCodes.contains(response.statusCode) else {
            throw HTTPClientError.requestError(code: response.statusCode, data: data, response: res)
        }
        
        return data
    }
    
    func makeRequest<Body: Codable>(
        url: String,
        body: Body?,
        method: HTTPMethod,
        withHeaders headers: [String : String] = [:]
    ) async throws -> Data {
        let url = try createURL(from: url)
        let request = try createRequest(
            fromURL: url,
            withBody: body,
            withHeaders: headers,
            withMethod: method
        )
        
        return try await makeRequest(request)
    }
    
    func makeRequestAndDecode<Body: Codable, Response: Codable>(
        decodeReponse type: Response.Type,
        method: HTTPMethod,
        url: String,
        body: Body? = nil,
        withHeaders headers: [String : String] = [:]
    ) async throws -> Response {
        let data = try await makeRequest(url: url, body: body, method: method, withHeaders: headers)
        return try JSONDecoder().decode(type.self, from: data)
        
    }


    // MARK: - Post



    func post<Body: Codable>(
        body: Body?,
        url: String,
        withHeaders headers: [String : String] = [:]
    ) async throws {
        _ = try await makeRequest(
            url: url,
            body: body,
            method: .post,
            withHeaders: headers
        )
    }
    
    func post<Body: Codable, Response: Codable>(
        decodeReponse type: Response.Type,
        body: Body? = nil,
        url: String,
        withHeaders headers: [String : String] = [:]
    ) async throws -> Response {
        try await makeRequestAndDecode(
            decodeReponse: Response.self,
            method: .post,
            url: url,
            body: body,
            withHeaders: headers
        )
    }

    
    func post<Response: Codable>(
        decodeReponse type: Response.Type,
        url: String,
        withHeaders headers: [String : String] = [:]
    ) async throws -> Response {
        try await post(
            decodeReponse: Response.self,
            body: nil as String?,
            url: url,
            withHeaders: headers
        )
    }
    
    func post(
        url: String,
        withHeaders headers: [String : String] = [:]
    ) async throws {
        try await post(
            body: nil as String?,
            url: url,
            withHeaders: headers
        )
    }


    // MARK: - Get


    func get<Response: Codable>(
        decodeReponse type: Response.Type,
        url: String,
        withHeaders headers: [String : String] = [:]
    ) async throws -> Response {
        try await makeRequestAndDecode(
            decodeReponse: Response.self,
            method: .get,
            url: url,
            body: nil as String?,
            withHeaders: headers
        )
    }
    
}

enum HTTPClientError: Error {
    case invalidURL
    case requestError(code: Int, data: Data?, response: URLResponse?)
    case couldNotParseServerResponse
}
