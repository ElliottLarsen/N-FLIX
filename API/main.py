# Author: Elliott Larsen
# Date:
# Description:

from fastapi import FastAPI
import pickle
from tmdbv3api import Movie, TMDb

movie = Movie()
tmdb = TMDb()
tmdb.api_key = "your_api_key"
movies = pickle.load(open("movies.pickle", "rb"))
cosine_sim = pickle.load(open("cosine_sim.pickle", "rb"))
app = FastAPI()


@app.get("/index")
def index():
    # This endpoint might not be needed.
    pass


@app.get("/movies")
def get_all_movies():
    """
    Returns all movie titles.
    """
    movie_list = movies["title"].values
    movie_list = movie_list.tolist()
    return {"titles": movie_list}


@app.get("/movies/{title}")
def get_movie_recommendation(title):
    """
    Receives a movie title as parameter and returns 10 recommended movies (title and posters).
    """
    images, titles = get_recommendations(title)
    return {"titles": titles, "images": images}


def get_recommendations(title):
    """
    Takes a movie title as parameter and returns two lists - movie poster images and titles of 10 recommended movies.
    """
    # Get the index of the passed movie title.
    idx = movies[movies["title"] == title].index[0]
    # Get corresponding data from cosine_sim() and sort.
    sim_scores = list(enumerate(cosine_sim[idx]))
    sim_scores = sorted(sim_scores, key = lambda x: x[1], reverse = True)
    # Slice 10 recommended movies except for self.
    sim_scores = sim_scores[1:11]
    # Find movie indices of 10 recommended movies.
    movie_indices = [i[0] for i in sim_scores]

    images = []
    titles = []
    for i in movie_indices:
        movie_id = movies["id"].iloc[i]
        details = movie.details(movie_id)

        images.append("https://image.tmdb.org/t/p/w500" + details["poster_path"])
        titles.append(details["title"])

    return images, titles
