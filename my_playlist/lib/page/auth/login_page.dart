
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_playlist/page/main_page.dart';

// ตรวจสอบสถานะล็อกอินและนำทางไปยังหน้าที่เหมาะสม
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const MainPage();
        }

        return const LoginPage();
      },
    );
  }
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
        await LoginPage.auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await LoginPage.auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
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
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.queue_music,
                  size: 80,
                  color: Colors.indigo,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'อีเมล',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'รหัสผ่าน',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Text(_isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก'),
                  ),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _error = '';
                          });
                        },
                  child: Text(
                    _isLogin
                        ? 'ยังไม่มีบัญชี? สมัครสมาชิก'
                        : 'มีบัญชีแล้ว? เข้าสู่ระบบ',
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
