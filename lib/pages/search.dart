import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/liked_images.dart';
import 'package:myapp/pages/liked_images.dart';
import 'package:myapp/pages/settings.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ImageSearch extends StatefulWidget {
  const ImageSearch({super.key});

  @override
  ImageSearchState createState() => ImageSearchState();
}

class ImageSearchState extends State<ImageSearch> {
  static const String apiKey = 'AIzaSyA9PvdEH9Q64Z2v3KwD24WLDbZicC29XfY';
  static const String cx = '516f7fa3ae4374b8c';
  static const int maxLoadTime = 1;

  final TextEditingController _searchController = TextEditingController();
  List<String> _allImages = [];
  List<String> _images = [];

  Future<void> _searchImages(String query) async {
    final likedImagesProvider =
        Provider.of<LikedImages>(context, listen: false);

    final safeSearchParam =
        likedImagesProvider.appSettings.enableSafeSearch ? 'high' : 'off';
    final imageSizeParam = likedImagesProvider.appSettings.selectedImageSize
        .toString()
        .split('.')
        .last
        .toLowerCase();

    final String apiUrl =
        'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&imgSize=$imageSizeParam&safe=$safeSearchParam&searchType=image&key=$apiKey';

    print(apiUrl);
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final allImages = List<String>.from(data['items']
          .where(
              (item) => item['link'] is String) // Filter out non-string values
          .map((item) => item['link'] as String));

      List<String> validImages = [];

      for (final imageUrl in allImages) {
        try {
          final resp = await http
              .get(Uri.parse(imageUrl))
              .timeout(const Duration(seconds: maxLoadTime));
          print(resp);
          if (resp.statusCode != 404) validImages.add(imageUrl);
        } catch (e) {
          // Handle network errors or other issues (optional)
          print('Error checking image URL: $e');
        }
      }

      setState(() {
        _allImages = allImages;
        _images = validImages;
      });
    } else {
      print('Google API error - Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load images');
    }
  }

  Future<void> _loadMoreImages() async {
    String query = _searchController.text;

    final likedImagesProvider =
        Provider.of<LikedImages>(context, listen: false);

    final safeSearchParam =
        likedImagesProvider.appSettings.enableSafeSearch ? 'high' : 'off';
    final imageSizeParam = likedImagesProvider.appSettings.selectedImageSize
        .toString()
        .split('.')
        .last
        .toLowerCase();
    final startIndex = _allImages.length;

    final String apiUrl =
        'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&imgSize=$imageSizeParam&safe=$safeSearchParam&start=$startIndex&searchType=image&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final allImages = List<String>.from(data['items']
          .where(
              (item) => item['link'] is String) // Filter out non-string values
          .map((item) => item['link'] as String));

      List<String> validImages = [];

      for (final imageUrl in allImages) {
        try {
          final resp = await http
              .get(Uri.parse(imageUrl))
              .timeout(const Duration(seconds: maxLoadTime));
          print(resp);
          if (resp.statusCode != 404) validImages.add(imageUrl);
        } catch (e) {
          // Handle network errors or other issues (optional)
          print('Error checking image URL: $e');
        }
      }

      setState(() {
        _allImages.addAll(allImages);
        _images.addAll(validImages);
      });
    } else {
      print('Google API error - Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    int itemsCount = _images.length;
    if (itemsCount > 0) itemsCount += 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LikedImagesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigator.pushNamed(context, '/settings');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter your search request',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchImages(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            // child: ListView.builder(
            //     itemCount: 5,
            //     itemBuilder: (context, index) {
            //       return Container(
            //         width: 100,
            //         height: 100,
            //         decoration: BoxDecoration(
            //           border: Border.all(
            //             color:
            //                 Colors.black, // You can customize the border color
            //             width: 2.0, // You can customize the border width
            //           ),
            //         ),
            //         child: Center(
            //           child: Text(
            //             'Box with Border',
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //       );
            //     }),
            child: ListView.builder(
              itemCount: _images.length + (_images.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (_images.isNotEmpty && index == _images.length) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: ElevatedButton(
                      onPressed: () {
                        // Fetch and add 10 more images
                        _loadMoreImages();
                      },
                      child: const Text('Load More'),
                    ),
                  );
                }

                return ImageWithLikeButton(imageLink: _images[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImageWithLikeButton extends StatelessWidget {
  final String imageLink;

  const ImageWithLikeButton({Key? key, required this.imageLink})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        child: Image.network(
          fit: BoxFit.cover,
          imageLink,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      ),
      trailing: LikeButton(imageLink: imageLink),
    );
  }
}

class LikeButton extends StatelessWidget {
  final String imageLink;

  const LikeButton({Key? key, required this.imageLink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LikedImages>(
      builder: (context, likedImagesProvider, child) {
        // Check if the image is already liked
        final bool isLiked =
            likedImagesProvider.likedImageLinks.contains(imageLink);

        return IconButton(
          icon: Icon(
            Icons.favorite,
            color: isLiked ? Colors.red : null,
          ),
          onPressed: () {
            if (isLiked) {
              // Remove from liked images if it's already liked
              likedImagesProvider.removeLikedImage(imageLink);
            } else {
              // Add to liked images if it's not already liked
              likedImagesProvider.addLikedImage(imageLink);
            }
          },
        );
      },
    );
  }
}
