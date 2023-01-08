import 'package:chat_firebase/providers/posts_reference_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postsProvider = StreamProvider(
  (ref) {
    final postsReference = ref.read(postsReferenceProvider);
    return postsReference.orderBy('createdBy').snapshots();
  },
);

final firestoreProvider = Provider(
  ((ref) => FirebaseFirestore.instance),
);
