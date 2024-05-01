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
  List<Reference> _imageReferences = [];

  @override
  void initState() {
    super.initState();
    getUserImages();
  }

  Future<void> getUserImages() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String uid = user.uid;
      ListResult result =
          await FirebaseStorage.instance.ref('user_images/$uid').listAll();
      setState(() {
        _imageReferences = result.items;
      });
    }
    return Future.value();
  }

  Future<void> deleteImage(Reference ref) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    String imageUrl = await ref.getDownloadURL();
    await ref.delete();
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('potholes')
        .where('imageUrl', isEqualTo: imageUrl)
        .get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
    await getUserImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getUserImages,
        child: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: _imageReferences.length,
          itemBuilder: (context, index) {
            final Reference reference = _imageReferences[index];
            return GestureDetector(
              onTap: () => {},
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
                    padding: const EdgeInsets.all(4),
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
                            style: const TextStyle(fontSize: 10),
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
