import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-Assisted Music Production',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          bodyText1: TextStyle(fontSize: 16.0, color: Colors.grey[800]),
        ),
      ),
      home: LyricsGenerator(),
    );
  }
}

class LyricsGenerator extends StatefulWidget {
  @override
  _LyricsGeneratorState createState() => _LyricsGeneratorState();
}

class _LyricsGeneratorState extends State<LyricsGenerator> {
  String language = 'English';
  String genre = 'Pop';
  String description = '';
  String lyrics = '';
  String error = '';

  final _descriptionController = TextEditingController();

  // Function to generate lyrics by making a POST request to the API
  Future<void> generateLyrics() async {
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a song description.')),
      );
      return;
    }

    final payload = {
      'description': description,
      'language': language,
      'genre': genre,
    };

    try {
      final response = await http.post(
        Uri.parse('https://lyrics-api-2.onrender.com/generate_lyrics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to generate lyrics');
      }

      final data = jsonDecode(response.body);
      if (data['detail'] != null) {
        setState(() {
          error = data['detail'];
        });
      } else {
        setState(() {
          lyrics = data['lyrics'].replaceAll('*', '');
          error = '';
        });
      }
    } catch (err) {
      setState(() {
        error = 'Error generating lyrics';
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI-Assisted Music Production',
            style: Theme.of(context).textTheme.headline1),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20.0),
              Text(
                'Language',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextField(
                onChanged: (value) => setState(() {
                  language = value;
                }),
                decoration: InputDecoration(
                  hintText: 'Enter song language (e.g., English)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Genre',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: genre,
                  onChanged: (String? newValue) {
                    setState(() {
                      genre = newValue!;
                    });
                  },
                  isExpanded: true,
                  items: <String>[
                    'Pop',
                    'Rock',
                    'Hip-Hop',
                    'Jazz',
                    'Classical',
                    'Country',
                    'R&B',
                    'Electronic',
                    'Reggae',
                    'Blues',
                    'Folk',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  underline: SizedBox(),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Describe the Song',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                onChanged: (value) => setState(() {
                  description = value;
                }),
                decoration: InputDecoration(
                  hintText: 'Enter a brief description of the song...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 30.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: generateLyrics,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text(
                    'Create/Update Lyrics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 30.0),
              if (error.isNotEmpty)
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              if (lyrics.isNotEmpty)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.8, // Centers the lyrics and makes it responsive
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      lyrics,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign
                          .left, // You can change this to center if needed
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
