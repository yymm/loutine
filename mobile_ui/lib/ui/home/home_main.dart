import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ui/ui/home/home_calendar.dart';
import 'package:mobile_ui/ui/home/home_calendar_event_list.dart';

class HomeMain extends StatelessWidget {
  const HomeMain({ super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loutine App'),
        leading: Icon(Icons.calendar_month),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              context.go('/setting');
            },
            icon: const Icon(Icons.settings),
          )
        ]
      ),
      body: SafeArea(
        child: Column(
          children: [
            HomeCalendarWidget(),
            SizedBox(height: 20),
            Expanded(
              child: HomeCalendarEventList(),
            )
          ]
        )
      )
    );
  }
}
