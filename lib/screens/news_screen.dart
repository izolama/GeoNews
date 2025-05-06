import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'news_details_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: isLightTheme ? Colors.black : Colors.white,
              unselectedLabelColor:
                  isLightTheme ? Colors.black54 : Colors.white70,
              tabs: const [
                Tab(text: 'All News'),
                Tab(text: 'Bookmarks'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All News Tab
                  RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () => newsProvider.fetchNews(),
                    child: _buildNewsList(newsProvider.articles),
                  ),
                  // Bookmarks Tab
                  _buildNewsList(newsProvider.bookmarkedArticles),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewsList(List<NewsArticle> articles) {
    if (articles.isEmpty) {
      return const Center(
        child: Text('No articles available'),
      );
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _NewsCard(article: article);
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;

  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (article.imageUrl.isNotEmpty &&
            Uri.tryParse(article.imageUrl)?.hasAbsolutePath == true)
        ? article.imageUrl
        : 'https://i.pinimg.com/originals/3a/1f/3a/3a1f3a1f3a1f3a1f3a1f3a1f3a1f3a1f.jpg';

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Consumer<NewsProvider>(
                        builder: (context, provider, child) {
                          return IconButton(
                            icon: Icon(
                              article.isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                            onPressed: () => provider.toggleBookmark(article),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Published: ${_formatDate(article.publishedAt)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
  }
}
