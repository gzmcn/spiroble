import 'package:flutter/material.dart';

class NavigationMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavigationMenu({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NavigationBar(
      height: 65,
      backgroundColor: theme.colorScheme.surface,
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: widget.onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home, color: theme.colorScheme.onSurface),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle,
              color: theme.colorScheme.onSurface), // Blog icon
          label: '',
        ),
        NavigationDestination(
          icon:
              Icon(Icons.medical_services, color: theme.colorScheme.onSurface),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.checklist, color: theme.colorScheme.onSurface),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.bluetooth, color: theme.colorScheme.onSurface),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.bluetooth, color: theme.colorScheme.onSurface),
          label: '',
        ),
      ],
      labelBehavior: NavigationDestinationLabelBehavior
          .alwaysHide, // Ensures no label is shown
    );
  }
}
