import 'package:chat_firebase/main.dart';
import 'package:chat_firebase/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
      ),
      body: Center(
        child: TextFormField(
          onFieldSubmitted: (text) {
            final user = FirebaseAuth.instance.currentUser!;
            final posterId = user.uid;
            final posterName = user.displayName!;
            final posterImageUrl = user.photoURL!;

            final newDocumentReference = postReference.doc();

            final newPost = Post(
              text: text,
              posterName: posterName,
              posterImageUrl: posterImageUrl,
              posterId: posterId,
              reference: newDocumentReference,
            );

            newDocumentReference.set(newPost);
          },
        ),
      ),
    );
  }
}
