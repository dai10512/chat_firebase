import 'package:chat_firebase/post.dart';
import 'package:chat_firebase/providers/posts_provider.dart';
import 'package:chat_firebase/providers/posts_reference_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'my_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  Future<void> sendPost(String text) async {
    final user = FirebaseAuth.instance.currentUser!;

    final posterId = user.uid;
    final posterName = user.displayName!;
    final posterImageUrl = user.photoURL!;

    // final newDocumentReference = postsReferenceWithConverter.doc();

    final newPost = Post(
      text: text,
      createdAt: Timestamp.now(),
      posterName: posterName,
      posterImageUrl: posterImageUrl,
      posterId: posterId,
      reference: ref.read(postsReferenceProvider).doc(),
    );

    newPost.reference.set(newPost);
  }

  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チャット'),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const MyPage();
                    },
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  FirebaseAuth.instance.currentUser!.photoURL!,
                ),
              ),
            )
          ],
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ref.watch(postsProvider).when(
                  data: (data) {
                    /// 値が取得できた場合に呼ばれる。
                    return ListView.builder(
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        print(data.docs.length);
                        final post = data.docs[index].data();
                        return PostWidget(post: post);
                      },
                    );
                  },
                  error: (_, __) {
                    /// 読み込み中にErrorが発生した場合に呼ばれる。
                    return const Center(
                      child: Text('不具合が発生しました。'),
                    );
                  },
                  loading: () {
                    /// 読み込み中の場合に呼ばれる。
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    // 未選択時の枠線
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                    // 選択時の枠線
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.amber,
                        width: 2,
                      ),
                    ),
                    // 中を塗りつぶす色
                    fillColor: Colors.amber[50],
                    // 中を塗りつぶすかどうか
                    filled: true,
                  ),
                  onFieldSubmitted: (text) {
                    sendPost(text);
                    controller.clear();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        FirebaseAuth.instance.currentUser!.uid == post.posterId;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              post.posterImageUrl,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post.posterName,
                    ),
                    Text(
                      // toDate() で Timestamp から DateTime に変換できます。
                      DateFormat('MM/dd HH:mm').format(post.createdAt.toDate()),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isCurrentUser
                            ? Colors.amber[100]
                            : Colors.blue[100],
                      ),
                      child: Text(post.text),
                    ),
                    if (isCurrentUser)
                      Row(
                        verticalDirection: VerticalDirection.up,
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: TextFormField(
                                      initialValue: post.text,
                                      autofocus: true,
                                      onFieldSubmitted: ((newText) {
                                        post.reference
                                            .update({'text': newText});
                                        Navigator.of(context).pop();
                                      }),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => post.reference.delete(),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
