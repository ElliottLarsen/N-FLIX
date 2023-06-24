//
//  ContentView.swift
//  iOS
//
//  Created by Elliott Larsen on 6/24/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var movieList: MovieList?
    @State private var selected_title = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("movie_title", selection: $selected_title) {
                        ForEach(movieList?.titles ?? [""], id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.wheel)
                }
            }
            .navigationTitle("Please select a movie")
            // Testing.
            VStack {
                Button(action: {getRecommendations(selected_title: selected_title)}) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .onAppear(perform: getMovieList)
    }
    
    // Need to make another API call to the backend server.
    private func getRecommendations(selected_title: String) {
        print(selected_title)
    }
    
    private func getMovieList() {
        // Get movie list.
        guard let url = URL(string: "http://127.0.0.1:8000/movies") else {
            return
        }
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data else {return}
            if let decodedData = try? JSONDecoder().decode(MovieList.self, from: data) {
                DispatchQueue.main.async {
                    self.movieList = decodedData
                }
            }
        }
        .resume()
    }
}


struct MovieList: Decodable {
    var titles: [String]
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
