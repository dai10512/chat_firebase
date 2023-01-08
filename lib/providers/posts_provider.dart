import 'package:chat_firebase/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postsProvider1 = StreamProvider((ref) {
  return postsReferenceWithConverter.orderBy('createdBy').snapshots();
});

final cc = 0;
