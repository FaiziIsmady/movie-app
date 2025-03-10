import 'package:flutter/material.dart';
import 'package:movie_app/utils/navigation_manager.dart';
import 'package:movie_app/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final int currentIndex;
  final VoidCallback? onBackPressed;

  const AppScaffold({
    Key? key,
    required this.body,
    this.title = '',
    this.showBackButton = false,
    this.actions,
    this.currentIndex = 0,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navManager = Provider.of<NavigationManager>(context, listen: false);
    
    return Scaffold(
      appBar: title.isNotEmpty
          ? AppBar(
              backgroundColor: Colors.black,
              centerTitle: true,
              title: Container(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              automaticallyImplyLeading: showBackButton,
              leading: showBackButton 
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  ) 
                : null,
              actions: actions,
            )
          : null,
      body: body,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: currentIndex,
        onItemTapped: (index) {
          navManager.setIndex(index);
        },
      ),
    );
  }
}