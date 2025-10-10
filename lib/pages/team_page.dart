// lib/pages/team_page.dart
import 'package:flutter/material.dart';

class TeamPage extends StatelessWidget {
  final members = [
    {'name': 'Integrante 1', 'img': 'https://picsum.photos/seed/team1/300/300'},
    {'name': 'Integrante 2', 'img': 'https://picsum.photos/seed/team2/300/300'},
    {'name': 'Integrante 3', 'img': 'https://picsum.photos/seed/team3/300/300'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Integrantes')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: members.length,
          itemBuilder: (ctx, i) {
            final m = members[i];
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(child: Image.network(m['img']!, width: 100, height: 100, fit: BoxFit.cover)),
                  SizedBox(height: 12),
                  Text(m['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home),
        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        tooltip: 'Volver a principal',
      ),
    );
  }
}