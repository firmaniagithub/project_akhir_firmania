import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'home_page.dart'; // Ubah impor ini menjadi home_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_state.dart'; // Tambahkan impor ini

final String apiKey = 'f5d001a469fdfd78fabdb2c8ccbe6ca8';
final String readAccessToken =
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmNWQwMDFhNDY5ZmRmZDc4ZmFiZGIyYzhjY2JlNmNhOCIsInN1YiI6IjY0OTdmOTJjYjM0NDA5MDExYzdiYzE3NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.xmGHyLmOPpNUxxuYiexcfY2BTKS5Uvk524SWn4tEtMk';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  MovieDetailPage({required this.movie});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}
//MovieDetailPage adalah sebuah class yang merupakan turunan dari StatefulWidget dan berfungsi sebagai halaman detail film. 
//Pada constructor MovieDetailPage({required this.movie}), 
//menerima argumen movie yang digunakan untuk menampilkan detail film pada halaman ini.

class _MovieDetailPageState extends State<MovieDetailPage> {
  String? movieDetails;
  List<String> movieReviews = [];
  TextEditingController _reviewController = TextEditingController();
  int reviewCounter = 1;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
    fetchMovieReviews();
  }
//MovieDetailPageState adalah sebuah class yang merupakan turunan dari State dan digunakan untuk mengelola state halaman detail film. 
//Pada inisialisasi state (initState()), dilakukan pemanggilan fungsi fetchMovieDetails() dan fetchMovieReviews() untuk mengambil detail film dan ulasan film dari sumber data.
  Future<void> fetchMovieDetails() async {
    final response = await http.get(
      Uri.https('api.themoviedb.org', '/3/movie/${widget.movie.id}',
          {'api_key': apiKey}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $readAccessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final details = data['overview'];

      setState(() {
        movieDetails = details;
      });
    } else {
      throw Exception('Gagal mengambil detail film');
    }
  }
  //fetchMovieDetails() adalah fungsi asynchronous yang digunakan untuk mengambil detail film dari API menggunakan HTTP GET request. Detail film diambil dari respons yang diterima dan disimpan dalam variabel movieDetails. 
  //Jika permintaan berhasil,fungsi ini akan memperbarui state dengan setState() dan mengubah nilai movieDetails. 
  //Jika terjadi kesalahan, akan dilempar Exception dengan pesan 'Gagal mengambil detail film'.

  Future<void> fetchMovieReviews() async {
    final response = await FirebaseFirestore.instance
        .collection('ulasan')
        .doc(widget.movie.id.toString())
        .collection('reviews')
        .get();

    List<String> reviews = [];

    if (response.docs.isNotEmpty) {
      // Terdapat ulasan yang tersimpan
      for (var doc in response.docs) {
        String review = doc.data()['ulasan'];
        reviews.add(review);
      }
    }

    setState(() {
      movieReviews = reviews;
    });
  }
//fetchMovieReviews() adalah fungsi asynchronous yang digunakan untuk mengambil ulasan film dari Cloud Firestore.
//Fungsi ini mengakses koleksi 'ulasan' di dalam dokumen dengan ID sesuai widget.movie.id dan kemudian mengambil data dari subkoleksi 'reviews'. 
  void addReview() async {
    String reviewText = _reviewController.text.trim();
    if (reviewText.isNotEmpty) {
      // Membuat objek Ulasan
      Map<String, dynamic> reviewData = {
        'ulasan': 'Ulasan $reviewCounter: $reviewText',
      };

      // Menyimpan ulasan ke Firebase Cloud Firestore
      await FirebaseFirestore.instance
          .collection('ulasan')
          .doc(widget.movie.id.toString())
          .collection('reviews')
          .add(reviewData);

      setState(() {
        _reviewController.clear();
        reviewCounter++;
      });
    }
  }

  void deleteReview(int index) async {
    // Menghapus ulasan dari Firebase Cloud Firestore
    await FirebaseFirestore.instance
        .collection('ulasan')
        .doc(widget.movie.id.toString())
        .collection('reviews')
        .where('ulasan', isEqualTo: movieReviews[index])
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.delete();
    });

    setState(() {
      movieReviews.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Film'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Image.network(
              'https://image.tmdb.org/t/p/w500/${widget.movie.posterPath}',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Deskripsi:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(8.0),
              child: Text(
                movieDetails ?? 'Memuat deskripsi...',
                textAlign: TextAlign.justify,
              ),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Ulasan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: movieReviews.length,
              itemBuilder: (context, index) {
                final review = movieReviews[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          review,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Hapus Ulasan'),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus ulasan ini?',
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      deleteReview(index);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Hapus'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                hintText: 'Tambahkan ulasan',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: addReview,
            child: Text('Tambah Ulasan'),
          ),
        ],
      ),
    );
  }
}
