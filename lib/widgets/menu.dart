import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode
        ? theme.colorScheme.onBackground
        : theme.colorScheme.onSurface;
    final iconColor =
        isDarkMode ? theme.colorScheme.onBackground : theme.colorScheme.primary;
    final tileColor =
        isDarkMode ? theme.colorScheme.surface : theme.colorScheme.background;

    return Drawer(
      backgroundColor: theme.colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 25)),
          ListTile(
            tileColor: tileColor,
            leading: Icon(Icons.settings, color: iconColor),
            title: Text(
              'Ayarlar',
              style: TextStyle(
                fontSize: 20,
                color: textColor,
              ),
            ),
            onTap: () {
             
            },
          ),
          ListTile(
            tileColor: tileColor,
            leading: Icon(Icons.contact_mail_rounded, color: iconColor),
            title: Text(
              'iletisim',
              style: TextStyle(
                fontSize: 20,
                color: textColor,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            tileColor: tileColor,
            leading: Icon(Icons.all_inbox_outlined, color: iconColor),
            title: Text(
              'Hakkımızda',
              style: TextStyle(
                fontSize: 20,
                color: textColor,
              ),
            ),
            onTap: () {},
          ),
          ListTile(
            tileColor: tileColor,
            leading: Icon(Icons.logout_sharp, color: iconColor),
            title: Text(
              'Çıkıs yap',
              style: TextStyle(
                fontSize: 20,
                color: textColor,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Çıkış yap ?'),
                  content:
                      const Text('Çıkış yapmak istediğinize emin misiniz ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                        child: const Text('Evet'))
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
