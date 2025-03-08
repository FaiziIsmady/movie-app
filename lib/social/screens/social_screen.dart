import 'package:flutter/material.dart';
import 'package:movie_app/utils/navigation_manager.dart';
import 'package:movie_app/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class FriendActivityScreen extends StatelessWidget {
  const FriendActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Social',
      currentIndex: Provider.of<NavigationManager>(context).currentIndex,
      body: Center(child: Text('Friend Activity Screen')),
    );
  }
}
