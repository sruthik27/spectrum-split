import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final Shader linearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.blue,
      Colors.green,
      Colors.indigo,
      Colors.purple,
      Colors.pink
    ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 130.0));

  Map<String, String> downloadLinks = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(200, 198, 252, 1),
                    Color.fromRGBO(165, 196, 255, 1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 300,
                        child: Image.asset(
                          'images/topbg.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 5),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.6),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        margin: EdgeInsets.only(left: 30, top: 50),
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (Rect bounds) {
                            return linearGradient;
                          },
                          child: const Text(
                            'SPECTRUM\nSPLIT',
                            style: TextStyle(
                              fontSize: 50,
                              fontFamily: 'Jockeyone',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Just upload your\npdf and get as\ntwo - '),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf'],
                          );

                          if (result != null && result.files.isNotEmpty) {
                            final file = File(result.files.single.path!);

                            var request = http.MultipartRequest(
                              'POST',
                              Uri.parse(
                                'https://sruthik2016.pythonanywhere.com/processpdf',
                              ),
                            );
                            request.files.add(
                              http.MultipartFile(
                                'pdf',
                                file.readAsBytes().asStream(),
                                file.lengthSync(),
                                filename: file.path.split('/').last,
                              ),
                            );

                            var response = await request.send();

                            if (response.statusCode == 200) {
                              // var tempDir = await getTemporaryDirectory();

                              var responseJson =
                                  await http.Response.fromStream(response);
                              var downloadLinksMap =
                                  json.decode(responseJson.body);

                              setState(() {
                                downloadLinks =
                                    Map<String, String>.from(downloadLinksMap)
                                        .map((key, value) {
                                  return MapEntry(key,
                                      'https://sruthik2016.pythonanywhere.com$value');
                                });
                              });
                              print(downloadLinks);
                            }
                          }
                        },
                        child: Text('Upload PDF'),
                      ),
                    ],
                  ),
                  if (downloadLinks.isNotEmpty)
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              final Uri url =
                                  Uri.parse(downloadLinks.values.first);
                              if (!await launchUrl(url,
                                  mode: LaunchMode.externalApplication)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                            child: Text('Black and white')),
                        ElevatedButton(
                            onPressed: () async {
                              final Uri url =
                                  Uri.parse(downloadLinks.values.last);
                              if (!await launchUrl(url,
                                  mode: LaunchMode.externalApplication)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                            child: Text('Coloured'))
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
