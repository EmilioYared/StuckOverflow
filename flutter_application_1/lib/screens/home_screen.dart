import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';
import 'posts_screen.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  bool _isConnected = false;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    final connected = await _apiService.testConnection();
    setState(() {
      _isConnected = connected;
      _isLoading = false;
    });
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0:
        return PostsScreen(apiService: _apiService);
      case 1:
        return CreatePostScreen(apiService: _apiService);
      case 2:
        return AuthScreen(apiService: _apiService);
      default:
        return PostsScreen(apiService: _apiService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stack Overflow Clone'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: _isConnected ? Colors.green : Colors.red,
              ),
              onPressed: _testConnection,
              tooltip: _isConnected ? 'Connected' : 'Disconnected',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isConnected
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Cannot connect to backend',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Make sure server is running on http://localhost:5000'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _testConnection,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Connection'),
                      ),
                    ],
                  ),
                )
              : _getScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Auth',
          ),
        ],
      ),
    );
  }
}
