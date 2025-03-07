import 'package:flutter/material.dart';
import 'package:movie_app/widgets/bottom_nav_bar.dart';
import 'package:movie_app/movie/screens/home_screen.dart';
import 'package:movie_app/explore/screens/explore_screen.dart';
import 'package:movie_app/social/screens/social_screen.dart';
import 'package:movie_app/profile/screens/profile_screen.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final int currentIndex;

  const AppScaffold({
    Key? key,
    required this.body,
    this.title = '',
    this.showBackButton = false,
    this.actions,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title.isNotEmpty
          ? AppBar(
              title: Text(title),
              automaticallyImplyLeading: showBackButton,
              actions: actions,
            )
          : null,
      body: body,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: currentIndex,
        onItemTapped: (index) {
          if (index == currentIndex) return;
          
          // Navigate to the selected screen
          Widget screen;
          switch (index) {
            case 0:
              screen = const HomeScreen();
              break;
            case 1:
              screen = const SearchScreen();
              break;
            case 2:
              screen = const FriendActivityScreen();
              break;
            case 3:
              screen = const ProfileScreen();
              break;
            default:
              screen = const HomeScreen();
          }
          
          // Replace the current screen with the selected one
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => screen),
            (route) => false, // Remove all previous routes
          );
        },
      ),
    );
  }
}