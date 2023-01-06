import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String text;
  final String posterName;
  final String posterImageUrl;
  final String posterId;
  final DocumentReference reference;

  const Post({
    required this.text,
    required this.posterName,
    required this.posterImageUrl,
    required this.posterId,
    required this.reference,
  });

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final map = snapshot.data()!;
    return Post(
      text: map['text'],
      posterName: map['posterName'],
      posterImageUrl: map['posterImageUrl'],
      posterId: map['posterId'],
      reference: snapshot.reference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'posterName': posterName,
      'posterImageUrl': posterImageUrl,
      'posterId': posterId,
      'reference': reference,
    };
  }
}
