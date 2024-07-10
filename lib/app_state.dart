import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'dart:async';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);
  }
  //ApplicationState adalah sebuah class yang merupakan turunan dari ChangeNotifier dan berfungsi untuk menyimpan dan mengelola state aplikasi. 
  //Pada constructor ApplicationState(), terdapat pemanggilan fungsi init() untuk menginisialisasi Firebase menggunakan Firebase.initializeApp() 
  //dengan menggunakan DefaultFirebaseOptions.currentPlatform. Kemudian, melalui FirebaseUIAuth.configureProviders(), 
  //konfigurasi provider otentikasi email (dalam hal ini EmailAuthProvider()) disiapkan.

  Future<bool> signIn(String email, String password) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return auth.currentUser != null;
    } catch (error) {
      print('Terjadi kesalahan saat proses otentikasi: $error');
      return false;
    }
  }
  //signIn() adalah fungsi asynchronous yang digunakan untuk melakukan proses otentikasi pengguna dengan Firebase Authentication menggunakan email dan password. 
  //Dalam fungsi ini, instance dari FirebaseAuth diakses dan signInWithEmailAndPassword() digunakan untuk melakukan otentikasi. Jika proses otentikasi berhasil, 
  //fungsi ini akan mengembalikan nilai true, dan jika terjadi kesalahan, pesan kesalahan akan dicetak dan nilai false akan dikembalikan.

  Future<void> register(String email, String password) async {
    bool isValidEmail(String email) {
      final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
      return emailRegex.hasMatch(email);
    }

    if (!isValidEmail(email)) {
      print('Format alamat email tidak valid');
      return;
    }

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      final UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      print('Terjadi kesalahan saat proses pendaftaran: $error');
    }
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<List<String>> fetchMovieReviews(int movieId) async {
    final response = await FirebaseFirestore.instance
        .collection('ulasan')
        .doc(movieId.toString())
        .get();

    if (response.exists) {
      final data = response.data();
      List<String> reviews = [];

      if (data != null) {
        for (var reviewData in data.values) {
          String review = reviewData['ulasan'];
          reviews.add(review);
        }
      }

      // Mengembalikan ulasan
      return reviews;
    } else {
      throw Exception('Gagal mengambil ulasan film');
    }
  }
}
//fetchMovieReviews() adalah fungsi asynchronous yang digunakan untuk mengambil ulasan film dari Cloud Firestore berdasarkan movieId. 
//Fungsi ini melakukan get() pada dokumen dengan ID movieId yang ada di koleksi 'ulasan'. Jika dokumen tersebut ada, 
//data ulasan akan diambil dan dimasukkan ke dalam list reviews. Jika dokumen tidak ada, akan dilempar Exception dengan pesan 'Gagal mengambil ulasan film'.