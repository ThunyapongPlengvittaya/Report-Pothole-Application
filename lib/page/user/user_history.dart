import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserHistory extends StatefulWidget {
  const UserHistory({super.key});

  @override
  State<UserHistory> createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  List<Reference> _imageReferences = [];

  @override
  void initState() {
    super.initState();
    getUserImages();
  }

  Future<void> getUserImages() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final String uid = user.uid;
      ListResult result = await _storage.ref('user_images/$uid').listAll();
      setState(() {
        _imageReferences = result.items;
      });
    }
    // This will return a future that completes after setState is called
    return Future.value();
  }

  Future<void> deleteImage(Reference ref) async {
    try {
      // Get the user's UID. This assumes you have it stored or can retrieve it.
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      String imageUrl = await ref.getDownloadURL();

      // Extract the pothole document ID from the Reference
      // This assumes your Reference's full path is in the format:
      // "potholes/{uid}/{potholeId}.jpg"
      // final List<String> pathSegments = ref.fullPath.split('/');
      // final String potholeId = pathSegments[2].split('.').first;

      // Delete the image from Firebase Storage
      await ref.delete();

      // Delete the corresponding pothole document from Firestore
      final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('potholes')
        .where('imageUrl', isEqualTo: imageUrl)
        .get();

      // If the document exists, delete it
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('Firestore document deleted.');
      }
      
      // Refresh the UI
      await getUserImages();
    } catch (e) {
      print('Error when deleting image: $e');
      // Handle the error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getUserImages, // Called when the user pulls down the list
        child: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  2, // Consider reducing to 1 for larger, full-width images
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio:
                  0.75 // Adjust based on your images' aspect ratio; closer to 1 might be more suitable for square images
              ),
          itemCount: _imageReferences.length,
          itemBuilder: (context, index) {
            final Reference reference = _imageReferences[index];
            return GestureDetector(
              onTap: () => {/* Handle your onTap action here */},
              child: FutureBuilder<String>(
                future: reference.getDownloadURL(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Error loading image'));
                  }

                  return Padding(
                    padding: EdgeInsets.all(4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'Photo ${index + 1}',
                            style: TextStyle(
                                fontSize:
                                    10), // Consider reducing the font size
                          ),
                        ),
                        IconButton(
                          color: Colors.amber,
                          icon: const Icon(Icons.delete,
                              color: Color.fromRGBO(244, 67, 54, 1)),
                          onPressed: () => deleteImage(reference),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
