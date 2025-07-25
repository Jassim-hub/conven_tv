/// Conven TV Main Entry Point
/// -------------------------------------------------------------
/// This file initializes the Conven TV app, sets up the theme,
/// navigation, and integrates Supabase and Riverpod for state
/// management and backend connectivity. It also prepares the
/// registration flow, including local language selection for
/// personalized recommendations. All code is thoroughly commented
/// for clarity and maintainability.
/// -------------------------------------------------------------

// ignore_for_file: dangling_library_doc_comments

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // State management
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase integration
import 'package:logger/logger.dart';
import 'screens/registration_screen.dart';

final logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(
      'Flutter Error',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };
  // Catch all uncaught errors
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('Uncaught Error', error: error, stackTrace: stack);
    return true;
  };
  // Initialize Supabase (replace with your actual keys in production)
  await Supabase.initialize(
    url: 'https://doqgjwpipqpnlnmrlvcp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvcWdqd3BpcHFwbmxubXJsdmNwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI3NTQxNTMsImV4cCI6MjA2ODMzMDE1M30.6MjQ9faumdO4fAxUSbXje0SeXKU9bqKNAjj-Hylxf64',
  );
  // Run the app with Riverpod for global state management
  runApp(const ProviderScope(child: ConvenTVApp()));
}

/// Root widget for Conven TV
class ConvenTVApp extends StatelessWidget {
  const ConvenTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conven TV',
      theme: ThemeData(
        // Futuristic orange color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Modern font
      ),
      debugShowCheckedModeBanner: false,
      // Initial route: Registration or Home depending on auth state
      home: const AuthGate(),
    );
  }
}

/// AuthGate checks authentication and routes to registration or home
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      // Not logged in: show registration/login screen
      return const RegistrationScreen();
    } else {
      // Logged in: show home screen
      return const HomeScreen();
    }
  }
}

/// Helper function to fetch recommended movies from Supabase based on user language
Future<List<Map<String, dynamic>>> fetchRecommendedMovies() async {
  final client = Supabase.instance.client;
  final session = client.auth.currentSession;
  if (session == null) return [];
  // Get user language from user metadata
  final user = session.user;
  final language = user.userMetadata?['local_language'] ?? 'Luganda';
  // Fetch movies from Supabase table 'movies' filtered by language
  final response = await client
      .from('movies')
      .select()
      .eq('language', language)
      .limit(20)
      .then((data) => data as List? ?? []);
  // Always treat response as a List and cast each item
  return response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

/// HomeScreen: Main movie browsing and recommendations
class HomeScreen extends StatelessWidget {
  // Removed misplaced logger call outside of class body
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch movies from Supabase and recommend based on user language
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchRecommendedMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }
        if (snapshot.hasError) {
          logger.e('Error loading movies', error: snapshot.error);
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Error loading movies: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        final movies = snapshot.data ?? [];
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Conven TV'),
            backgroundColor: Colors.orange,
          ),
          body: movies.isEmpty
              ? Center(
                  child: Text(
                    'No movies found for your language.',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          movie['title'] ?? 'Untitled',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          movie['description'] ?? '',
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Text(
                          movie['language'] ?? '',
                          style: TextStyle(color: Colors.orangeAccent),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
