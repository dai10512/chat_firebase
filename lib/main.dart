import 'package:chat_firebase/chat_page.dart';
import 'package:chat_firebase/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';

Future<void> main() async {
  // main 関数でも async が使えます
  WidgetsFlutterBinding.ensureInitialized(); // runApp 前に何かを実行したいときはこれが必要です。
  await Firebase.initializeApp(
    // これが Firebase の初期化処理です。
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final isLogin = FirebaseAuth.instance.currentUser == null;

    return MaterialApp(
      theme: ThemeData(),
      home: isLogin ? const ChatPage() : const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> signInWithGoogle() async {
    // GoogleSignIn をして得られた情報を Firebase と関連づけることをやっています。
    final googleUser =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoogleSignIn'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('GoogleSignIn'),
          onPressed: () async {
            await signInWithGoogle();
            // ログインが成功すると FirebaseAuth.instance.currentUser にログイン中のユーザーの情報が入ります
            print(FirebaseAuth.instance.currentUser?.displayName);
            // print(FirebaseAuth.instance.currentUser?.displayName);
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: (context) {
                  return const ChatPage();
                },
              ), (route) => false);
            }
          },
        ),
      ),
    );
  }
}

final postsReferenceWithConverter =
    FirebaseFirestore.instance.collection('posts').withConverter<Post>(
  fromFirestore: ((snapshot, _) {
    return Post.fromFirestore(snapshot); //取得したデータを自動でPostインスタンスにしてくれ
  }),
  toFirestore: ((value, _) {
    return value.toMap(); //Postインスタンスで受けると自動でMapにしてくれる
  }),
);
