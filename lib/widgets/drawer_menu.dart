import 'package:flutter/material.dart';

class MenuItem {
  const MenuItem({
    this.icon,
    required this.title,
    required this.value,
    this.isSelected = false,
  });
  final String title;
  final dynamic value;
  final IconData? icon;
  final bool isSelected;
}

class DrawerMenu {
  DrawerMenu({
    required this.context,
    required this.menuItems,
    this.drawerWidth = 200,
    required this.onTap,
  });
  final BuildContext context;
  final double drawerWidth;
  final List<MenuItem> menuItems;
  final Function(dynamic value) onTap;

  OverlayEntry? _drawerEntry;
  late final AnimationController _animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 300),
  );

  late final Animation<double> _slideAnimation =
      Tween<double>(begin: -(drawerWidth), end: 0.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

  // 显示抽屉
  void show() {
    final overlayState = Overlay.of(context);
    _drawerEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: dismiss,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) => Positioned(
                  right: _slideAnimation.value,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: drawerWidth,
                    height: double.infinity,
                    color: Colors.black,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (final item in menuItems)
                          Card(
                            color: const Color.fromARGB(255, 36, 37, 37),
                            child: InkWell(
                              child: ListTile(
                                  leading: item.icon == null
                                      ? null
                                      : Icon(item.icon),
                                  title: Text(
                                    item.title,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  onTap: () {
                                    onTap(item.value);
                                    dismiss();
                                  }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlayState.insert(_drawerEntry!);
    _animationController.forward();
  }

  // 关闭抽屉
  void dismiss() async {
    await _animationController.reverse();
    _drawerEntry?.remove();
    _drawerEntry = null;
    _animationController.dispose();
  }
}
