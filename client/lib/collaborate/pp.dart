import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';


//import 'package:flutter_pptx/flutter_pptx.dart';
import 'package:file_saver/file_saver.dart';

import 'dart:typed_data';

import 'dart:io';
import 'dart:developer';

import 'package:flutter/foundation.dart';
/*
Future<void> downloadFile(String name, Uint8List bytes) async {
  await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      //file: file,
      //String? filePath,
      ext: ".pptx",
      //MimeType mimeType = MimeType.other,
      //mimeType: application/vnd.openxmlformats-officedocument.presentationml.presentation,
      //custommimeType: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      //mimeType: MimeType.microsoftPresentation,
      );
  }

Future<void> downloadPresentation(FlutterPowerPoint pres) async {
    final bytes = await pres.save();
    if (bytes == null) return;
    //final file = File("presentation2.pptx");
    //await file.writeAsBytes(bytes);
    downloadFile('presentation.pptx', bytes);      
  }
*/
class PowerPointScreen2 extends StatefulWidget {
  //HomeScreen({required this.username, required this.serverIP});
  State<PowerPointScreen2> createState() => _PowerPointScreen2State();
}

class _PowerPointScreen2State extends State<PowerPointScreen2> {
  /*
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  var box = Hive.openBox('hive');
  box.put('name', 'Yazan');
  box.put('numbers', ['1','2','3']);
  print(box.get('numbers'));
  */

/*
Future<FlutterPowerPoint> createPresentation() async {
  final pres = FlutterPowerPoint();
    pres.addBlankSlide();
}
final pres = await createPresentation();
            await downloadPresentation(pres);
*/
  final TextEditingController headingController = TextEditingController();
  final TextEditingController bulletController = TextEditingController();

  int slideLength = 0;

  final ValueNotifier<int> slideIndex = ValueNotifier(0);

  void nextSlide(BuildContext context) {
    slideIndex.value++;
  }

  void prevSlide(BuildContext context) {
    slideIndex.value--;
  }

  void firstSlide(BuildContext context) {
    slideIndex.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
    title: const Text('PowerPoint'),
    backgroundColor: Colors.green,
    ),
      body: ValueListenableBuilder(
        valueListenable: slideIndex,
        builder: (BuildContext context, int value, Widget? child) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                            SizedBox(height: 60),
                            TextFormField(
                              controller: headingController,
                              decoration: const InputDecoration(
                                labelText: 'Heading',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            SizedBox(height: 60),
                            TextFormField(
                              controller: bulletController,
                              decoration: const InputDecoration(
                                labelText: 'Bullet point',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius:
                  const BorderRadius.only(topRight: Radius.circular(10)),
                  child: ColoredBox(
                    color: Colors.black12,
                    child: Row(
                      children: [
                        if (slideIndex.value != 0)
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.navigate_before_rounded),
                            onPressed: () {
                              prevSlide(context);
                            }
                          ),

                        SizedBox(width: slideIndex.value == 0 ? 90 : 50),
                        if (slideIndex.value < slideLength)
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.navigate_next_rounded),
                            onPressed: () {
                              nextSlide(context);
                            }
                          ),

                        const SizedBox(width: 50),
                        if (slideIndex.value != 0)
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.first_page),
                            onPressed: () {
                              firstSlide(context);
                            }
                          ),

                        const SizedBox(width: 50),
                        if (slideIndex.value == slideLength)
                        IconButton(
                          iconSize: 40,
                          icon: const Icon(Icons.plus_one),
                          onPressed: () {
                            slideLength++;
                            setState(() {});
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                  ),
                  child: ColoredBox(
                    color: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        '${slideIndex.value + 1}',
                        style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 0,
                top: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                  ),
                  child: ColoredBox(
                    color: Colors.black12,
                    child:  TextButton(
                      style: TextButton.styleFrom(
                    //foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                    //padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {},
                      child: const Text('Export'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
