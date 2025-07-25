import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common/bottom_nav_bar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location == '/') return 0;
    if (location.startsWith('/shared')) return 1;
    if (location.startsWith('/personal')) return 2;
    if (location.startsWith('/settings')) return 3;

    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/shared');
        break;
      case 2:
        context.go('/personal');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}
