import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'register.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}
//class LoginPage adalah sebuah widget stateful yang merupakan halaman login. 
//Widget ini digunakan untuk membuat instance dari _LoginPageState.
// ===========================================================

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan password';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final appState =
                        Provider.of<ApplicationState>(context, listen: false);
                    if (_formKey.currentState!.validate()) {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      final success = await appState.signIn(email, password);
                      if (success) {
                        setState(() {
                          _errorMessage = null;
                        });
                        Navigator.pushNamed(context, '/home');
                      } else {
                        setState(() {
                          _errorMessage = 'Email atau password tidak valid';
                        });
                      }
                    }
                  },
                  child: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: const Text('Register'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//_LoginPageState adalah state dari LoginPage. Di dalamnya, kita mendefinisikan beberapa variabel dan controller yang diperlukan. 
//Dalam metode dispose(), kita membersihkan controller yang digunakan untuk mencegah memory leak. Di dalam build(), 
//mengembalikan sebuah Scaffold yang memiliki tampilan halaman login. Di dalam Scaffold, 
//menggunakan Container sebagai latar belakang dengan warna biru (Colors.blue) dan Padding untuk memberikan jarak di sekitar konten. Di dalam Padding, kita menggunakan Form sebagai wadah untuk validasi input pengguna. 
//Di dalam Form, kita menggunakan beberapa widget seperti TextFormField untuk memasukkan email dan password pengguna, ElevatedButton untuk tombol login, dan TextButton untuk tombol pindah ke halaman registrasi (RegisterPage)
//Terdapat juga Text dan Padding yang digunakan untuk menampilkan pesan kesalahan jika terjadi masalah saat login. Dengan konfigurasi ini, halaman login akan menampilkan input email dan password, serta tombol untuk melakukan login.
//dan pindah ke halaman registrasi. Ketika pengguna menekan tombol login, validasi akan dilakukan dan jika berhasil, 
//pengguna akan diarahkan ke halaman utama ('/home') dan jika gagal, pesan kesalahan akan ditampilkan.
//===============================================================================