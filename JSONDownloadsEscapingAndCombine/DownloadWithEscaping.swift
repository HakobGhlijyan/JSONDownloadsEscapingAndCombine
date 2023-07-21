//
//  DownloadWithEscaping.swift
//  SwiftUIContinuedIntermediateLevel
//
//  Created by Hakob Ghlijyan on 20.07.2023.
//

import SwiftUI

//MARK: - MODEL
struct PostModel: Identifiable, Codable {
    let id: Int
    let userId:Int
    let title:String
    let body:String
}

//MARK: - VIEW MODEL
class DownloadWithEscapingViewModel: ObservableObject {
    
    //MARK: - EXAMPLE IS MODEL - ARRAY DATA
    @Published var posts: [PostModel] = []
    
    //MARK: - INIT
    init() {
        getPost()
    }
    
    //MARK: - FUNC Download Json is URL adress
    func getPost() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        downloadData(fromURL: url) { returnedData in
            if let data = returnedData {
                // ADD NEW DOWNLOADED DATA IN ARRAY - JSON DECODER
                guard let newPosts = try? JSONDecoder().decode([PostModel].self, from: data) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.posts = newPosts
                }
            } else {
                print("No data returned")
            }
        }
    }
    
    // FUNC DOWNLOAD - in url , and completionHandler - load data - UNIVERSAL FUNC
    func downloadData(fromURL url: URL, completionHandler: @escaping (_ data: Data?) -> () ) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                print("Error Downloading Data.")
                // if no load , make completion nil
                completionHandler(nil)
                return
            }
            completionHandler(data)
        }.resume()
    }
}

struct DownloadWithEscaping: View {
    
    //MARK: - EXAMPLE MODEL IS CLASS
    @StateObject var vm = DownloadWithEscapingViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.posts) { post in
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text(post.title)
                            .font(.headline)
                            .foregroundColor(.red)
                        Divider()
                            .frame(height: 1)
                            .background(Color.gray)
                        Text(post.body)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("JSON Downloading")
        }
    }
}

struct DownloadWithEscaping_Previews: PreviewProvider {
    static var previews: some View {
        DownloadWithEscaping()
    }
}
