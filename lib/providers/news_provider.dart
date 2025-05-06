import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String publishedAt;
  bool isBookmarked;

  NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    this.isBookmarked = false,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['urlToImage'] ??
          'https://i.pinimg.com/originals/3a/1f/3a/3a1f3a1f3a1f3a1f3a1f3a1f3a1f3a1f.jpg',
      publishedAt: json['publishedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt,
      'isBookmarked': isBookmarked,
    };
  }
}

class NewsProvider with ChangeNotifier {
  List<NewsArticle> _articles = [];
  List<NewsArticle> _bookmarkedArticles = [];
  bool _isLoading = false;
  String _error = '';

  List<NewsArticle> get articles => _articles;
  List<NewsArticle> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;
  String get error => _error;

  final Dio _dio = Dio();

  NewsProvider() {
    _loadBookmarkedArticles();
    fetchNews();
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Using JSONPlaceholder as a demo API
      final response =
          await _dio.get('https://jsonplaceholder.typicode.com/posts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // List of sample Pinterest image URLs to assign randomly
        final List<String> pinterestImages = [
          'https://i.pinimg.com/736x/c1/87/66/c1876613b570f40e044b1ea1a70cbab1.jpg',
          'https://i.pinimg.com/736x/b8/a8/bd/b8a8bdc4a47234445c83e2d4c0c30c1b.jpg',
          'https://i.pinimg.com/736x/9d/75/2d/9d752d8dbee0dce69d0a2401ee5605e1.jpg',
          'https://i.pinimg.com/736x/df/82/e5/df82e50a43a7b13a37eb837b6a4f6add.jpg',
          'https://i.pinimg.com/736x/76/63/de/7663de8fcb3acf99f57cf7a8631348ef.jpg',
        ];

        _articles = data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final imageUrl = pinterestImages[index % pinterestImages.length];
          return NewsArticle(
            id: item['id'].toString(),
            title: item['title'],
            description: item['body'],
            content: item['body'],
            imageUrl: imageUrl,
            publishedAt: DateTime.now().toIso8601String(),
          );
        }).toList();

        // Update bookmarked status
        _updateBookmarkedStatus();
      } else {
        _error = 'Failed to load news';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(NewsArticle article) async {
    article.isBookmarked = !article.isBookmarked;

    if (article.isBookmarked) {
      _bookmarkedArticles.add(article);
    } else {
      _bookmarkedArticles.removeWhere((a) => a.id == article.id);
    }

    await _saveBookmarkedArticles();
    notifyListeners();
  }

  Future<void> _loadBookmarkedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedJson = prefs.getString('bookmarkedArticles');

    if (bookmarkedJson != null) {
      final List<dynamic> bookmarkedData = json.decode(bookmarkedJson);
      _bookmarkedArticles =
          bookmarkedData.map((item) => NewsArticle.fromJson(item)).toList();

      // Set bookmarked status to true for all loaded articles
      for (var article in _bookmarkedArticles) {
        article.isBookmarked = true;
      }

      _updateBookmarkedStatus();
    }
  }

  Future<void> _saveBookmarkedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedJson = json.encode(
      _bookmarkedArticles.map((article) => article.toJson()).toList(),
    );
    await prefs.setString('bookmarkedArticles', bookmarkedJson);
  }

  void _updateBookmarkedStatus() {
    for (var article in _articles) {
      article.isBookmarked =
          _bookmarkedArticles.any((bookmarked) => bookmarked.id == article.id);
    }
  }
}
