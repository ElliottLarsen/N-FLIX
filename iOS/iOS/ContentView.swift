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
    let columns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color.background_color
                .ignoresSafeArea()
            VStack {
                // Movie Picker from the GET /movies endpoint.
                Picker("movie_title", selection: $selected_title) {
                    ForEach(movieList?.titles ?? [""], id: \.self) {
                        Text($0)
                            .foregroundColor(Color.text_color)
                            .fontWeight(.bold)
                    }
                }
                .pickerStyle(.wheel)
                
                
                Button(action: {getRecommendations(selected_title: selected_title)}) {
                    // Calls GET /movies/{title}.
                    Text("Search")
                        .bold()
                        .padding(10)
                        .foregroundColor(Color.background_color)
                        .background(Color.button_color)
                        .cornerRadius(15)
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(recommendations?.images ?? [""], id: \.self) {
                            // Displays the movie posters.
                            AsyncImage(url: URL(string: $0)) { image in image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.background_color
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 500)
                
                
                .onAppear(perform: getMovieList)
            }
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

extension Color {
    static let background_color = Color("BackgroundColor")
    static let text_color = Color("TextColor")
    static let button_color = Color("ButtonColor")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
