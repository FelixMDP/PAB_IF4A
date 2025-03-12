import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pilem/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;

  Future<void> _checkIsFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = prefs.containsKey('movie_${widget.movie.id}');
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (_isFavorite) {
      final String movieJson = jsonEncode(widget.movie.toJson());
      prefs.setString('movie_${widget.movie.id}', movieJson);
      List<String> favoriteMovieIds =
          prefs.getStringList('favoriteMovies') ?? [];
      favoriteMovieIds.add(widget.movie.id.toString());
      prefs.setStringList('favoriteMovies', favoriteMovieIds);
    } else {
      prefs.remove('movie_${widget.movie.id}');
      List<String> favoriteMovieIds =
          prefs.getStringList('favoriteMovies') ?? [];
      favoriteMovieIds.remove(widget.movie.id.toString());
      prefs.setStringList('favoriteMovies', favoriteMovieIds);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIsFavorite();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Background Poster dengan efek blur
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl:
                  'https://image.tmdb.org/t/p/w500${widget.movie.backdropPath}',
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Konten utama
          Column(
            children: [
              SafeArea(
                child: Center(
                  child: Hero(
                    tag: 'movie_${widget.movie.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                        width: 200,
                        height: 300,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image,
                                size: 100, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Container untuk detail film, menggunakan Expanded agar tidak terpotong
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul Film
                        Text(
                          widget.movie.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Rating dan Tanggal Rilis
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.yellow, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  widget.movie.voteAverage.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Text(
                              "Release: ${widget.movie.releaseDate}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          widget.movie.overview.isNotEmpty
                              ? widget.movie.overview
                              : "No description available.",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await _toggleFavorite();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_isFavorite
                                      ? "Added to favorites!"
                                      : "Removed from favorites!"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.favorite,
                              color: _isFavorite ? Colors.red : Colors.white,
                            ),
                            label: Text(
                              _isFavorite
                                  ? "Remove from Favorite"
                                  : "Add to Favorite",
                              style: TextStyle(
                                color: _isFavorite ? Colors.red : Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Tombol Back
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
