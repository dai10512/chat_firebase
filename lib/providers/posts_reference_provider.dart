import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../post.dart';
import 'firestore_provider.dart';

final postsReferenceProvider = Provider(
  (ref) {
    final firestore = ref.read(firestoreProvider);
    return firestore.collection('posts').withConverter<Post>(
        fromFirestore: ((snapshot, options) => Post.fromFirestore(snapshot)),
        toFirestore: ((value, options) => value.toMap()));
  },
);
