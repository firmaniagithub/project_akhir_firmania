import 'package:flutter/material.dart'; //library untuk menggunakan widget-widget dari Flutter
import 'package:firebase_core/firebase_core.dart'; // library untuk menginisialisasi Firebase,
import 'package:provider/provider.dart';//library untuk menggunakan state management dengan Provider.

import 'login_page.dart';// menginport halaman login
import 'app_state.dart';//menginport halaman app_state
import 'home_page.dart';// menginport halaman home_page
import 'register.dart'; // Tambahkan impor halaman RegisterPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(); // Inisialisasi Firebase dengan agar aplikasi dapat terhubung dengan firebase untuk mengambil data 
  } catch (error) {
    print('Terjadi kesalahan saat menginisialisasi Firebase: $error');
  }

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Meetup',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => MovieListPage(),
        '/register': (context) => RegisterPage(), // Tambahkan rute untuk RegisterPage
      },
    );
  }
}
//class App adalah sebuah widget yang merupakan root widget dari aplikasi. Di dalam build(), menggunakan widget MaterialApp sebagai pengaturan utama aplikasi. 
//memberikan daftar rute yang akan digunakan. Rute utama adalah '/login' yang akan menampilkan halaman LoginPage(). 
//Selain itu, terdapat rute '/home' yang akan menampilkan halaman MovieListPage() dan 
//rute '/register' yang akan menampilkan halaman RegisterPage().