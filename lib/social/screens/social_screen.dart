import 'package:flutter/material.dart';
import 'package:movie_app/widgets/app_scaffold.dart';

class FriendActivityScreen extends StatelessWidget {
  const FriendActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Social',
      currentIndex: 2, // 2 for Social tab
      body: Center(child: Text('Friend Activity Screen')),
    );
  }
}
