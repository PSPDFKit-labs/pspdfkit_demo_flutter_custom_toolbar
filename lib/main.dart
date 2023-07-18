import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget.dart';
import 'package:pspdfkit_flutter/widgets/pspdfkit_widget_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: extractAsset(context, 'PDFs/Document.pdf'),
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.hasData) {
            return PspdfkitWidget(
              documentPath: snapshot.data!.path,
              configuration: const {
                scrollDirection: "vertical",
                pageTransition: "scrollContinuous",
              },
              onPspdfkitWidgetCreated:
                  (PspdfkitWidgetController controller) async {
                controller.enterAnnotationCreationMode("ink");
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Future<File> extractAsset(BuildContext context, String assetPath,
    {bool shouldOverwrite = true, String prefix = ''}) async {
  final bytes = await DefaultAssetBundle.of(context).load(assetPath);
  final list = bytes.buffer.asUint8List();

  final tempDir = await Pspdfkit.getTemporaryDirectory();
  final tempDocumentPath = '${tempDir.path}/$prefix$assetPath';
  final file = File(tempDocumentPath);

  if (shouldOverwrite || !file.existsSync()) {
    await file.create(recursive: true);
    file.writeAsBytesSync(list);
  }
  return file;
}
