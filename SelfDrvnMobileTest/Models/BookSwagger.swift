/* 
Copyright (c) 2019 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct BookSwagger : Codable {
	let iSBN : String?
	let languageCode : String?
	let authors : [Authors]?
	let title : String?
	let subtitle : String?
	let description : String?
	let coverThumb : String?
	let subjects : [String]?

	enum CodingKeys: String, CodingKey {

		case iSBN = "ISBN"
		case languageCode = "LanguageCode"
		case authors = "Authors"
		case title = "Title"
		case subtitle = "Subtitle"
		case description = "Description"
		case coverThumb = "CoverThumb"
		case subjects = "Subjects"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
        iSBN = try values.decodeIfPresent(String.self, forKey: .iSBN)
        languageCode = try values.decodeIfPresent(String.self, forKey: .languageCode)
        authors = try values.decodeIfPresent([Authors].self, forKey: .authors)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        coverThumb = try values.decodeIfPresent(String.self, forKey: .coverThumb)
        subjects = try values.decodeIfPresent([String].self, forKey: .subjects)
	}
    
    //MARK:- Init
    init(fromDictionary dictionary: [String:Any]) {
        let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        self = try! JSONDecoder().decode(BookSwagger.self, from: jsonData)
    }

}

//MARK:- API Calls -
extension BookSwagger {
    
    static func search(isbn:String, completion: @escaping (BookSwagger?, APIError?) -> Void) {
        let client = HTTPClient()
        let router = BookRouter(endpoint: .Search(_isbn: isbn))
        
        client.response(router: router) { (response) in
            if let success = response?.result.isSuccess, success {
                if let body = response?.value as? JSONDictionary {
                    let book = BookSwagger.init(fromDictionary: body)
                    completion(book, nil)
                }
            } else if let error = response?.result.error as? APIError {
                completion(nil, error)
            } else {
                completion(nil, nil)
            }
        }
    }
}
