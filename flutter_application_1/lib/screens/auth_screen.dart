import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  final ApiService apiService;

  const AuthScreen({super.key, required this.apiService});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  String? _message;
  Color _messageColor = Colors.red;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    Map<String, dynamic> result;

    if (_isLogin) {
      result = await widget.apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      result = await widget.apiService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    setState(() {
      _isLoading = false;
      _message = result['success'] 
          ? '${_isLogin ? "Login" : "Registration"} successful!'
          : '${result['message']}';
      _messageColor = result['success'] ? Colors.green : Colors.red;
    });

    if (result['success']) {
      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.account_circle,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              _isLogin ? 'Login' : 'Register',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!_isLogin)
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (!_isLogin) return null;
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
            if (!_isLogin) const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isLogin ? 'Login' : 'Register'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _message = null;
                });
              },
              child: Text(
                _isLogin
                    ? "Don't have an account? Register"
                    : 'Already have an account? Login',
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _messageColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _messageColor),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(color: _messageColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auth Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          widget.apiService.isAuthenticated
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: widget.apiService.isAuthenticated
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.apiService.isAuthenticated
                              ? 'Authenticated'
                              : 'Not Authenticated',
                        ),
                      ],
                    ),
                    if (widget.apiService.isAuthenticated) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.apiService.logout();
                          setState(() {
                            _message = 'Logged out successfully';
                            _messageColor = Colors.blue;
                          });
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
