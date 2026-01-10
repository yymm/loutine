import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ui/ui/setting/theme_mode_toggle.dart';
import 'package:mobile_ui/ui/shared/app_divider_widget.dart';

class SettingMain extends StatelessWidget {
  const SettingMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back),
          onTap: () {
            context.go('/');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              // >> ThemeMode toggle
              ThemeModeToggle(),
              AppDividerWidget(),
              // >> Tag Management
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Tag Management'),
                trailing: Icon(Icons.subdirectory_arrow_left),
                onTap: () {
                  context.go('/setting/tag');
                },
              ),
              AppDividerWidget(),
              // >> Category Management
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Catagory Management'),
                trailing: Icon(Icons.subdirectory_arrow_left),
                onTap: () {
                  context.go('/setting/category');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
