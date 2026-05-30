import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../pages/home_page.dart';
import '../pages/shop_page.dart';
import '../pages/inventory_page.dart';
import '../pages/battle_page.dart';
import '../pages/profile_page.dart';
import '../pages/admin/admin_dashboard.dart';
import '../pages/admin/admin_enemy_page.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/battle_provider.dart';
import '../providers/theme_provider.dart';

class AppScaffold extends StatefulWidget {
  final int initialIndex;
  const AppScaffold({super.key, this.initialIndex = 0});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late int _currentIndex;

  static const _userNavItems = <_NavItem>[
    _NavItem(icon: CupertinoIcons.house,                selectedIcon: CupertinoIcons.house_fill,              label: 'Home'),
    _NavItem(icon: CupertinoIcons.bag,                  selectedIcon: CupertinoIcons.bag_fill,                label: 'Shop'),
    _NavItem(icon: CupertinoIcons.archivebox,           selectedIcon: CupertinoIcons.archivebox_fill,         label: 'Inventory'),
    _NavItem(icon: CupertinoIcons.shield,               selectedIcon: CupertinoIcons.shield_fill,             label: 'Battle'),
    _NavItem(icon: CupertinoIcons.person_crop_circle,   selectedIcon: CupertinoIcons.person_crop_circle_fill, label: 'Profile'),
  ];

  static const _adminNavItems = <_NavItem>[
    _NavItem(icon: CupertinoIcons.cube_box,             selectedIcon: CupertinoIcons.cube_box_fill,           label: 'Items'),
    _NavItem(icon: CupertinoIcons.flame,                selectedIcon: CupertinoIcons.flame_fill,              label: 'Enemies'),
    _NavItem(icon: CupertinoIcons.person_crop_circle,   selectedIcon: CupertinoIcons.person_crop_circle_fill, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadPlayerStats();
      context.read<ShopProvider>().loadItems();
      context.read<BattleProvider>().loadEnemies(force: true);
    });
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Watch ThemeProvider so this State rebuilds on theme change,
    // which propagates fresh AppColors values to all child page States.
    context.watch<ThemeProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    // Non-const instances so Flutter calls didUpdateWidget + build()
    // on each page's State when the theme changes.
    final userPages = <Widget>[
      HomePage(), ShopPage(), InventoryPage(), BattlePage(), ProfilePage(),
    ];
    final adminPages = <Widget>[
      AdminDashboard(), AdminEnemyPage(), ProfilePage(),
    ];

    final pages = isAdmin ? adminPages : userPages;
    final navItems = isAdmin ? _adminNavItems : _userNavItems;

    // Clamp index so switching roles never causes an out-of-bounds page
    final safeIndex = _currentIndex.clamp(0, pages.length - 1);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: List.generate(pages.length, (i) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            opacity: i == safeIndex ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: i != safeIndex,
              child: pages[i],
            ),
          );
        }),
      ),
      bottomNavigationBar: _AnimatedNavBar(
        currentIndex: safeIndex,
        items: navItems,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem({required this.icon, required this.selectedIcon, required this.label});
}

class _AnimatedNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _AnimatedNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(items.length, (i) {
              return Expanded(
                child: _NavBarButton(
                  item: items[i],
                  isSelected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarButton extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavBarButton> createState() => _NavBarButtonState();
}

class _NavBarButtonState extends State<_NavBarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(_NavBarButton old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      if (widget.isSelected) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          // Read AppColors live so theme changes are reflected immediately
          final color = Color.lerp(AppColors.textMuted, AppColors.primary, _ctrl.value) ?? AppColors.textMuted;
          final isHigh = _ctrl.value > 0.5;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    width: widget.isSelected ? 44 : 0,
                    height: widget.isSelected ? 26 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  Transform.scale(
                    scale: _scale.value,
                    child: Icon(
                      isHigh ? widget.item.selectedIcon : widget.item.icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
                child: Text(widget.item.label),
              ),
            ],
          );
        },
      ),
    );
  }
}
