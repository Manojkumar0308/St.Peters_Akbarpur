import 'package:flutter/material.dart';

class HomeworkContentPreview extends StatefulWidget {
  const HomeworkContentPreview({super.key});

  @override
  State<HomeworkContentPreview> createState() => _HomeworkContentPreviewState();
}

class _HomeworkContentPreviewState extends State<HomeworkContentPreview> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Homework Preview'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Image.asset(
              'assets/images/logo_bg.png',
              height: size.height * 0.07,
              width: size.width * 0.07,
            ),
          )
        ],
      ),
    );
  }
}
