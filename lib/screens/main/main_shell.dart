import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/cart_service.dart';
import '../cart/cart_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import '../wishlist/wishlist_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  final List<NavigationDestination> _mobileDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search_rounded),
      label: 'Search',
    ),
    NavigationDestination(
      icon: Icon(Icons.favorite_border_rounded),
      selectedIcon: Icon(Icons.favorite_rounded),
      label: 'Wishlist',
    ),
    NavigationDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart_rounded),
      label: 'Cart',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartService.instance,
      builder: (context, _) {
        final width = MediaQuery.of(context).size.width;
        final isDesktop = width >= 1024;

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: Row(
            children: [
              if (isDesktop) _buildDesktopNavigation(),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar:
              isDesktop ? null : _buildMobileNavigation(),
        );
      },
    );
  }

  Widget _buildMobileNavigation() {
    final cartCount = CartService.instance.itemCount;

    final destinations = List<Widget>.from(
      _mobileDestinations,
    );

    destinations[3] = NavigationDestination(
      icon: _CartIcon(
        count: cartCount,
      ),
      selectedIcon: _CartIcon(
        count: cartCount,
        selected: true,
      ),
      label: 'Cart',
    );

    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.burgundy.withValues(
        alpha: 0.10,
      ),
      elevation: 0,
      destinations: destinations.cast<NavigationDestination>(),
    );
  }

  Widget _buildDesktopNavigation() {
    final cartCount = CartService.instance.itemCount;

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 18,
          ),
          child: Column(
            children: [
              _buildBrandHeader(),

              const SizedBox(height: 30),

              _DesktopNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                title: 'Home',
                selected: _currentIndex == 0,
                onTap: () {
                  _selectPage(0);
                },
              ),

              _DesktopNavItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search_rounded,
                title: 'Search',
                selected: _currentIndex == 1,
                onTap: () {
                  _selectPage(1);
                },
              ),

              _DesktopNavItem(
                icon: Icons.favorite_border_rounded,
                selectedIcon: Icons.favorite_rounded,
                title: 'Wishlist',
                selected: _currentIndex == 2,
                onTap: () {
                  _selectPage(2);
                },
              ),

              _DesktopNavItem(
                icon: Icons.shopping_cart_outlined,
                selectedIcon: Icons.shopping_cart_rounded,
                title: 'Cart',
                selected: _currentIndex == 3,
                badge: cartCount,
                onTap: () {
                  _selectPage(3);
                },
              ),

              _DesktopNavItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                title: 'Profile',
                selected: _currentIndex == 4,
                onTap: () {
                  _selectPage(4);
                },
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: AppColors.burgundy,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your World of Books',
                        style: TextStyle(
                          color: AppColors.burgundy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.burgundy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/ShelfSpace.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.cream,
                size: 23,
              ),
            ),
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SHELFSPACE',
                style: TextStyle(
                  color: AppColors.burgundy,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Your World of Books',
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class _DesktopNavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;

  const _DesktopNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 6,
      ),
      child: Material(
        color: selected
            ? AppColors.burgundy.withValues(
                alpha: 0.08,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                      ? AppColors.burgundy
                      : AppColors.mutedText,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? AppColors.burgundy
                          : AppColors.dark,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (badge != null && badge! > 0)
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.burgundy,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge! > 99 ? '99+' : '$badge',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  final int count;
  final bool selected;

  const _CartIcon({
    required this.count,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          selected
              ? Icons.shopping_cart_rounded
              : Icons.shopping_cart_outlined,
        ),
        if (count > 0)
          Positioned(
            right: -9,
            top: -8,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 17,
                minHeight: 17,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              decoration: const BoxDecoration(
                color: AppColors.burgundy,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
