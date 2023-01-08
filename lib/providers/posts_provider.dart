import 'posts_reference_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postsProvider = StreamProvider(
  (ref) {
    final postsReference = ref.read(postsReferenceProvider);
    return postsReference.orderBy('createdBy').snapshots();
  },
);


