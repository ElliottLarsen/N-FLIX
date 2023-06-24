//
//  ContentView.swift
//  iOS
//
//  Created by Elliott Larsen on 6/24/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var movieList: MovieList?
    @State private var recommendations: Recommendations?
    @State private var selected_title = ""
    
    var body: some View {
        VStack {
            Picker("movie_title", selection: $selected_title) {
                ForEach(movieList?.titles ?? [""], id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.wheel)
            
            
            Button(action: {getRecommendations(selected_title: selected_title)}) {
                Text("Search")
                    .bold()
                    .padding(20)
                    .foregroundColor(Color.white)
                    .background(Color.black)
                    .cornerRadius(15)
            }
            
            /*
            ForEach(recommendations?.images ?? [""], id: \.self) {
                 AsyncImage(url: URL(string: $0))
             }
             */

            .onAppear(perform: getMovieList)
        }
    }
    
    
    private func getRecommendations(selected_title: String) {
        // Get 10 recommendations based on the input title.
        let selected_title = selected_title
        let url_title = selected_title.replacingOccurrences(of: " ", with: "%20")
        guard let url = URL(string: "http://127.0.0.1:8000/movies/\(url_title)") else {
            return
        }
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data else {return}
            if let decodedData = try? JSONDecoder().decode(Recommendations.self, from: data) {
                DispatchQueue.main.async {
                    self.recommendations = decodedData
                }
            }
        }
        .resume()
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

struct Recommendations: Decodable {
    var titles: [String]
    var images: [String]
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
