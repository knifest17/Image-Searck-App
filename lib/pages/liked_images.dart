import 'package:flutter/material.dart';
import 'package:myapp/liked_images.dart';
import 'package:provider/provider.dart';

class LikedImagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final likedImagesProvider = Provider.of<LikedImages>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Images'),
      ),
      body: ListView.builder(
        itemCount: likedImagesProvider.likedImageLinks.length,
        itemBuilder: (context, index) {
          final likedImageLink = likedImagesProvider.likedImageLinks[index];
          return ListTile(
            title: Image.network(
              fit: BoxFit.cover,
              likedImageLink,
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                likedImagesProvider.removeLikedImage(likedImageLink);
              },
            ),
          );
        },
      ),
    );
  }
}
