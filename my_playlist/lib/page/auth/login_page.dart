import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_playlist/page/main_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          backgroundColor: Color(0xFF080808),
          body: Center(child: CircularProgressIndicator(color: Color(0xFF818CF8))),
        );
      }
      return snapshot.hasData ? const MainPage() : const LoginPage();
    },
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String _error = '';

  static const _background = Color(0xFF080808);
  static const _surface = Color(0xFF1B1B1B);
  static const _primary = Color(0xFF818CF8);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'กรุณากรอกอีเมลและรหัสผ่าน');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      if (_isLogin) {
        await LoginPage.auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await LoginPage.auth.createUserWithEmailAndPassword(email: email, password: password);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.code) {
          case 'weak-password':
            _error = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
            break;
          case 'email-already-in-use':
            _error = 'อีเมลนี้มีบัญชีอยู่แล้ว';
            break;
          case 'invalid-email':
            _error = 'รูปแบบอีเมลไม่ถูกต้อง';
            break;
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            _error = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
            break;
          case 'operation-not-allowed':
            _error = 'กรุณาเปิด Email/Password ใน Firebase';
            break;
          case 'network-request-failed':
            _error = 'เชื่อมต่ออินเทอร์เน็ตไม่ได้';
            break;
          default:
            _error = '${e.code}: ${e.message ?? "เกิดข้อผิดพลาด"}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: _surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary)),
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIconColor: Colors.white54,
    );

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: Text(_isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.queue_music, size: 72, color: _primary),
              const SizedBox(height: 12),
              const Text('MyPlaylist', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 28),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration.copyWith(labelText: 'อีเมล', prefixIcon: const Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration.copyWith(labelText: 'รหัสผ่าน', prefixIcon: const Icon(Icons.lock_outline)),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_error, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text(_isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก'),
                ),
              ),
              TextButton(
                onPressed: _loading ? null : () => setState(() {
                  _isLogin = !_isLogin;
                  _error = '';
                }),
                child: Text(_isLogin ? 'ยังไม่มีบัญชี? สมัครสมาชิก' : 'มีบัญชีแล้ว? เข้าสู่ระบบ', style: const TextStyle(color: _primary)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}