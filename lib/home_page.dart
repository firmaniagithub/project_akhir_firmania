import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'details_page.dart';

final String apiKey = 'f5d001a469fdfd78fabdb2c8ccbe6ca8';
final String readAccessToken =
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmNWQwMDFhNDY5ZmRmZDc4ZmFiZGIyYzhjY2JlNmNhOCIsInN1YiI6IjY0OTdmOTJjYjM0NDA5MDExYzdiYzE3NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.xmGHyLmOPpNUxxuYiexcfY2BTKS5Uvk524SWn4tEtMk';
//class movie awal
class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final double rating;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.rating,
  });
}

//Movie adalah sebuah class yang merepresentasikan data film. Class ini memiliki beberapa properti seperti id, title, posterPath, 
//overview, dan rating yang digunakan untuk menyimpan informasi film.
//clas mpvie akhir 



class MovieListPage extends StatefulWidget {
  @override
  _MovieListPageState createState() => _MovieListPageState();
}
//MovieListPage adalah sebuah StatefulWidget yang akan menampilkan daftar film.

class _MovieListPageState extends State<MovieListPage> {
  List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }
//_MovieListPageState adalah state dari MovieListPage. Di dalamnya terdapat sebuah list movies yang akan menyimpan daftar film.

  Future<void> fetchMovies() async {
    final response = await http.get(
      Uri.https('api.themoviedb.org', '/3/movie/popular', {'api_key': apiKey}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $readAccessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Movie> fetchedMovies = [];

      for (var movieData in data['results']) {
        Movie movie = Movie(
          id: movieData['id'] as int,
          title: movieData['title'],
          posterPath: movieData['poster_path'],
          overview: movieData['overview'],
          rating: movieData['vote_average'].toDouble(),
        );
        fetchedMovies.add(movie);
      }

      setState(() {
        movies = fetchedMovies;
      });
    } else {
      throw Exception('Gagal mengambil daftar film');
    }
  }

  // fetchMovies() adalah fungsi asynchronous yang digunakan untuk mengambil data daftar film dari API menggunakan HTTP GET request. 
  //Fungsi ini mengirim permintaan ke URL https://api.themoviedb.org/3/movie/popular dengan parameter api_key dan header Authorization yang berisi token akses.
  // Jika respon berhasil dengan kode status 200, data JSON yang diterima akan di-decode menjadi objek Movie dan disimpan dalam list fetchedMovies. 
  //Setelah itu, state movies akan diperbarui menggunakan setState() sehingga daftar film akan ditampilkan di UI. Jika terjadi kesalahan, akan dilempar Exception dengan pesan 'Gagal mengambil daftar film'.

  void navigateToMovieDetailPage(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(movie: movie),
      ),
    );
  }
  //navigateToMovieDetailPage() adalah fungsi yang digunakan untuk berpindah ke halaman detail film (MovieDetailPage) ketika salah satu film di daftar diklik.
  // Fungsi ini memanfaatkan Navigator.push() untuk menavigasi ke halaman baru dengan menggunakan MovieDetailPage sebagai builder.

  Widget buildMovieCard(Movie movie) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              movie.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  //buildMovieCard() adalah fungsi yang mengembalikan widget Card yang menampilkan informasi film. 
  //Di dalam Card, terdapat widget Image.network yang menampilkan poster film dengan menggunakan URL yang diperoleh dari properti posterPath. 
  //Selain itu, terdapat juga widget Text untuk menampilkan judul film di bagian bawah poster.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Film'),
      ),
      body: GridView.builder(
        itemCount: movies.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () => navigateToMovieDetailPage(context, movie),
            child: buildMovieCard(movie),
          );
        },
      ),
    );
  }
}
// Fungsi build() akan membangun tampilan halaman daftar film. Di dalamnya, terdapat Scaffold dengan AppBar yang menampilkan judul 'Daftar Film'. 
//Bagian body menggunakan GridView.builder untuk menampilkan daftar film dalam bentuk grid dengan menggunakan buildMovieCard() sebagai item grid. 
//Setiap item grid dapat diklik dan akan menjalankan navigateToMovieDetailPage() untuk pindah ke halaman detail film dengan memberikan data film yang sesuai.