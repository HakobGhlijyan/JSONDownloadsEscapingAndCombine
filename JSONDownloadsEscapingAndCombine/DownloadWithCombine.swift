//
//  DownloadWithCombine.swift
//  SwiftUIContinuedIntermediateLevel
//
//  Created by Hakob Ghlijyan on 21.07.2023.
//

import SwiftUI
import Combine

//MARK: - MODEL
struct PostCombineModel: Identifiable, Codable {
    let id: Int
    let userId:Int
    let title:String
    let body:String
}

//MARK: - VIEW MODEL
class DownloadWithCombineViewModel: ObservableObject {
    
    //MARK: - EXAMPLE IS MODEL - ARRAY DATA
    @Published var posts:[PostCombineModel] = []
    
    //MARK: - AnyCancellable - .store
    var cancellables = Set<AnyCancellable>()
    
    //MARK: - INIT
    init() {
        getPost()
    }
    
    //MARK: - FUNC Download Json is URL adress
    func getPost() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        //Combine Methode
        /*
         1. - create the publisher
         2. - subscribe publisher on background thread - //2.1 This is Optional , publisher is atomatic is .background thread
         3. - recieve on main thread - but updating ui is in MAIN THREAD
         4. - typMap ( chack that th datain is good )
         4.1 - //1 check response - Proverka na otvet , est li daniie i vozrochaet DATA
         5. - decode ( decode data into to [PostCombineModel]
         6. - sink ( pink the item into our app ) - sinxronizaciya posle chego budet pochechen v app
         7. - store ( cancel subscription id neede ) - This method in NABOR // var cancellables = Set<AnyCancellable>() // -> &cancellables
         ( Canceling in 2. line )
         */
        
        URLSession.shared.dataTaskPublisher(for: url)                                   //1
            .subscribe(on: DispatchQueue.global(qos: .background))                      //2 + 2.1 - Optional
            .receive(on: DispatchQueue.main)                                            //3
            .tryMap(handleOutput)                                                       //4
            .decode(type: [PostCombineModel].self, decoder: JSONDecoder())              //5
            //1                                                                         //6.1
            /*
             .replaceError(with: [] )
             .sink(receiveValue: { [weak self] (returnedPosts) in
                 self?.posts = returnedPosts
             })
             */
            //2
            .sink { (completion) in                                                     //6.2
                //1
                print("COMPLETION: \(completion)")
                //2 ERRORS - In SWITCH
                switch completion {
                case .finished:
                    print("COMPLETION: \(completion)")
                case .failure(let error):
                    print("COMPLETION ERROR: \(error)")
                }
            } receiveValue: { [weak self] (returnedPosts) in
                self?.posts = returnedPosts
            }
            .store(in: &cancellables)                                                   //7
    }
    
    func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
            guard
                let response = output.response as? HTTPURLResponse,
                response.statusCode >= 200 && response.statusCode < 300 else {
                throw URLError(.badServerResponse)
            }
        return output.data
    }
    
}

struct DownloadWithCombine: View {
    
    //MARK: - EXAMPLE MODEL IS CLASS
    @StateObject var vm = DownloadWithCombineViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.posts) { post in
                    VStack(alignment: .leading, spacing: 10.0) {
                        Text(post.title)
                            .font(.headline)
                            .foregroundColor(.yellow)
                        Divider()
                            .frame(height: 1)
                            .background(Color.gray)
                        Text(post.body)
                            .font(.subheadline)
                            .foregroundColor(.brown)
                    }
                }
            }
            .navigationTitle("JSON Combine")
        }
    }
}

struct DownloadWithCombine_Previews: PreviewProvider {
    static var previews: some View {
        DownloadWithCombine()
    }
}
