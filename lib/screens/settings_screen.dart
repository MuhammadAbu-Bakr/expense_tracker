import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'USD',
                        label: Text('USD'),
                        icon: Text('\$'),
                      ),
                      ButtonSegment<String>(
                        value: 'GBP',
                        label: Text('GBP'),
                        icon: Text('£'),
                      ),
                      ButtonSegment<String>(
                        value: 'PKR',
                        label: Text('PKR'),
                        icon: Text('₨'),
                      ),
                    ],
                    selected: {settingsProvider.currency},
                    onSelectionChanged: (newSelection) {
                      settingsProvider.setCurrency(newSelection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: settingsProvider.isDarkMode,
                    onChanged: (value) {
                      settingsProvider.toggleDarkMode();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
