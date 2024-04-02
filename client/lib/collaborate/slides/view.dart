import 'package:flutter/material.dart';

import 'viewModel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:client/services/network.dart';
import 'package:socket_io_client/socket_io_client.dart';
//import 'dart:async';


//import 'package:hive/hive.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:hive_flutter/hive_flutter.dart';


import 'package:flutter_pptx/flutter_pptx.dart';
import 'package:file_saver/file_saver.dart';

import 'dart:typed_data';

//import 'dart:io';
//import 'dart:developer';

//import 'package:flutter/foundation.dart';

// Keyboard input
import 'package:flutter/services.dart';

class SlidesView extends StatefulWidget {

  const SlidesView({super.key});
  _SlidesViewState createState() => _SlidesViewState();
}

class _SlidesViewState extends State<SlidesView> { 
  slidesViewModel viewModel = slidesViewModel();

  @override
  void initState() { 
    super.initState();

    // Receive new slide from server
    viewModel.socket!.on('createppt', (data) {
      if (mounted) {
        setState(() {
          viewModel.model.powerpoints.add(data.last);
        });
      }
    });

    viewModel.socketEvents();
 
    // Delay to allow socket to connect
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String slideType = !viewModel.model.isWebsite ? 'Wasabi Slides' : "Website URL";
    String displayVar = !viewModel.model.isWebsite ? 'Name' : 'PptName';
    List<dynamic> powerPoints = viewModel.model.isWebsite ? viewModel.model.powerpoints : viewModel.model.WasabiSlides;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slides', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),

      body: new Stack(
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/PowerpointImage.webp"),
                colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
              ),
            ),
          ),

          new Column(
            children: [
              const SizedBox(height: 48),
              Expanded(
                child: ListView.builder(
                  itemCount: powerPoints.length,
                  itemBuilder: (context, index) {
                    return FractionallySizedBox(
                      widthFactor: 0.7, // Set width to 70% of the parent width
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        color: Colors.green,
                        child: ListTile(
                          title: Text(
                            powerPoints[index][displayVar],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!viewModel.model.isWebsite) ... {
                                IconButton(
                                  icon: Icon(Icons.open_in_browser_outlined, color: Colors.white),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WasabiSlidesView(
                                          socket: viewModel.socket,
                                          slideName: powerPoints[index]['Name'],
                                          newSlide: false
                                        ),
                                      ),
                                    );
                                  },
                                  tooltip: "Open",
                                ),

                                IconButton(
                                  icon: Icon(Icons.group_add_outlined, color: Colors.white),
                                    onPressed:() {
                                      viewModel.shareForm(context, powerPoints[index], viewModel.model.isWebsite);
                                    },
                                    tooltip: "Share",
                                ),

                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Delete Slide"),
                                          content: Text("Are you sure you want to delete this slide?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                viewModel.socket!.emit('deleteSlide', {'name': powerPoints[index]['Name'], 'user': NetworkService.instance.getusername});
                                                setState(() {
                                                  viewModel.model.WasabiSlides.removeAt(index);
                                                });

                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  tooltip: "Delete",
                                ),
                              } else ... {
                                IconButton(
                                  icon: Icon(Icons.open_in_browser_outlined, color: Colors.white),
                                  onPressed: () {
                                    launchUrl(Uri.parse(powerPoints[index]['Ppturl']));
                                  },
                                  tooltip: "Open",
                                ),

                                IconButton(
                                  icon: Icon(Icons.group_add_outlined, color: Colors.white),
                                  onPressed:() {
                                    viewModel.shareForm(context, powerPoints[index], viewModel.model.isWebsite);
                                  },
                                  tooltip: "Share",
                                ),

                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Delete Slide"),
                                          content: Text("Are you sure you want to delete this slide?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),

                                            TextButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                viewModel.socket!.emit('deleteppt', {'PptID': powerPoints[index]['PptID'], 'user': NetworkService.instance.getusername, 'index': index});
                                                setState(() {
                                                  viewModel.model.powerpoints.removeAt(index);
                                                });

                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  tooltip: "Delete",
                                ),
                              }
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ), 
            ],
          ),

          Positioned(
            top: 8,
            left: 8,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: ColoredBox(
                color: Colors.green,
                child:  TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    viewModel.toggleIsWebsite();
                    setState(() {});
                  },
                  child: Text(slideType),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          if (viewModel.model.isWebsite) {
            viewModel.createPowerpoint(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WasabiSlidesView(socket: viewModel.socket, slideName: "", newSlide: true),
              ),
            );
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class WasabiSlidesView extends StatefulWidget {
  String slideName = '';
  Socket? socket;
  bool newSlide = true;

  WasabiSlidesView({required this.socket, required this.slideName, required this.newSlide});
  State<WasabiSlidesView> createState() => _WasabiSlidesViewState();
}

class _WasabiSlidesViewState extends State<WasabiSlidesView> {
  String username = NetworkService.instance.getusername;
  final List<dynamic> _friends = [];
  final List<dynamic>_groups = [];
  TextEditingController titleController = TextEditingController(text: "Untitled Powerpoint");
  bool presenting = false;


  void initState() {
    super.initState();
    //saveSlide(slideIndex, headingController, bulletController);

    if (widget.slideName != '') {
      titleController.text = widget.slideName;
    } else {
      widget.slideName = titleController.text;
      }
 
    widget.socket!.emit('buildfriendscollab', username);
    widget.socket!.emit('buildgroupscollab', username);
    if (!widget.newSlide) {
      widget.socket!.emit('getSlide',{'name': widget.slideName, 'username': username, 'slideNum': slideIndex.value});
      widget.socket!.emit('getTotalSlides', {'name': widget.slideName, 'username': username});
    }

    widget.socket!.on('buildfriendscollab', (data) {
      _friends.addAll(data);
    });

    widget.socket!.on('buildgroupscollab', (data) {
      _groups.addAll(data);
    });


    widget.socket!.on('getSlide', (data) {
      print(data);
      //print(slideIndex.value);
      //print(data);
      //print(data[0]['SlideHeader']);
      if (mounted) {
      setState(() {
      //_powerpoints.add(data[0]);
      headingController.text = data[0]['SlideHeader'];
      //print(data['header']);
      //headingController.text = data['header'];
      bulletController.text = data[0]['SlideContent'];
          });}

      //setState(() {});
          
    });

    widget.socket!.on('getTotalSlides', (data) {
        print(data[0]['COUNT(*)']);
        slideLength = (data[0]['COUNT(*)']);
    print (slideLength);
        //slideLength = data[0]['COUNT(*)'];
    });

/*
    widget.socket!.on('onChanges', (data) {
                                    widget.socket!.emit('getSlide',{'name': widget.slideName, 'username': username, 'slideNum': slideIndex.value});
setState(() {headingController.text = data[0]['SlideHeader'];
bulletController.text = data[0]['SlideContent'];
});
      })
    */

  widget.socket!.on('exportSlides', (data) {
           final pres = FlutterPowerPoint();

    //print(data);
    for (var i = 0; i < slideLength; i++) {
    if (i == 0) {
      print(data[i]['SlideHeader']);
      String title = data[i]['SlideHeader'];
    pres.addTitleSlide(title: title.toTextValue(),);
    //print(data[i]['SlideHeader']);
    } else {
      String title = data[i]['SlideHeader'];
      List<String> splitBullet = data[i]['SlideContent'].split('\n');
      //print(splitBullet);
      //for (var j = 0; j < splitBullet.length; j++) {
        //print(splitBullet[j]);
      //}

      pres.addTitleAndBulletsSlide(
        title: title.toTextValue(),
        bullets: splitBullet.map((e) => e.toTextValue()).toList(),

        //data[i]['SlideContent'].toTextValue(),
      );

      
          
    }

      //widget.socket!.emit('getSlide',{'name': widget.slideName, 'username': username, 'slideNum': i});
    }
    downloadPresentation(pres);
  });

widget.newSlide = false;
    
  }
  /*
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  var box = Hive.openBox('hive');
  box.put('name', 'Yazan');
  box.put('numbers', ['1','2','3']);
  print(box.get('numbers'));
  */

  final TextEditingController headingController = TextEditingController();
  final TextEditingController bulletController = TextEditingController();

  int slideLength = 1;

  final ValueNotifier<int> slideIndex = ValueNotifier(1);

  void nextSlide(BuildContext context) {
  }

  void prevSlide(BuildContext context) {
    slideIndex.value--;
  }

  void saveSlide(ValueNotifier<int> slideIndex, TextEditingController headingController, TextEditingController bulletController) {
    widget.socket?.emit('createSlide', {
      'userID': NetworkService.instance.getusername,
      'title': titleController.text,
      'num': slideIndex.value,
      'header': headingController.text,
      'content': bulletController.text,
    });
  }

  Future<void> downloadFile(String name, Uint8List bytes) async {
    }

Future<void> downloadPresentation(FlutterPowerPoint pres) async {
    //final bytes = await pres.save();
    //if (bytes == null) return;
    //final file = File("presentation2.pptx");
    //await file.writeAsBytes(bytes);
    //downloadFile('presentation', bytes);      
    await FileSaver.instance.saveFile(
      name: widget.slideName,
      bytes: await pres.save(),
      //file: file,
      //String? filePath,
      ext: ".ppt",
      //MimeType mimeType = MimeType.other,
      //mimeType: application/vnd.openxmlformats-officedocument.presentationml.presentation,
      //custommimeType: "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      //mimeType: MimeType.microsoftPresentation,
      );

  }

  
  void createPresentation() {
     //downloadPresentation(pres);
}

  @override
  Widget build(BuildContext context) {
    if (!presenting) {
    return Scaffold(
    appBar: AppBar(
    backgroundColor: Colors.green,

    title: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      contentPadding: EdgeInsets.only(left: 10),
                    ),
                  ),
                ),
                const Icon(Icons.edit),
              ],
            ),
            actions: [
                ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    saveSlide(slideIndex, headingController, bulletController);

                    slideIndex.value = 1;
                    widget.socket!.emit('getSlide',{'name': titleController.text, 'username': username, 'slideNum': slideIndex.value});
                    presenting = true;
                  });
                },
                icon: const Icon(Icons.arrow_right_outlined, size: 32, color: Colors.black),
                label: const Text('Present', style: TextStyle(color: Colors.black)),
              ),
                            const SizedBox(width: 24),

              //const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  //createPresentation();
                  widget.socket!.emit('exportSlides', {'name': widget.slideName, 'username': username});
                },
                icon: const Icon(Icons.save, color: Colors.black),
                label: const Text('Export', style: TextStyle(color: Colors.black)),
              ),        
                            const SizedBox(width: 24),

            
            ],
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
                            SizedBox(height: 64),
                            TextFormField(
                              controller: headingController,
                              decoration: const InputDecoration(
                                labelText: 'Heading',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            SizedBox(height: 48),
                            if (slideIndex.value != 1) ... {
                            TextFormField(
                              controller: bulletController,
                              decoration: const InputDecoration(
                                labelText: 'Bullet point',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 24,
                            ),
                            }
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: ClipRRect(
                borderRadius:
                  const BorderRadius.all(Radius.circular(10)),
                  child: ColoredBox(
                    color: Colors.green,
                    child: Row(
                      children: [
                      const SizedBox(width: 16),
                        if (slideIndex.value != 1) ... {
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.navigate_before_rounded),
                            onPressed: () {
                              saveSlide(slideIndex, headingController, bulletController);
                              //prevSlide(context);
                              slideIndex.value--;
                                    widget.socket!.emit('getSlide',{'name': titleController.text, 'username': username, 'slideNum': slideIndex.value});
                            }
                          ),
} else ... {
    const SizedBox(width: 56),
  },
                        //SizedBox(width: slideIndex.value == 0 ? 24 : 24),
                      const SizedBox(width: 16),
                        if (slideIndex.value < slideLength)
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.navigate_next_rounded),
                            onPressed: () {
                                                            saveSlide(slideIndex, headingController, bulletController);
                              //nextSlide(context);
                                  slideIndex.value++;
                                  print(widget.slideName);
                                  print(username);
                                  print(slideIndex.value);

                                    widget.socket!.emit('getSlide',{'name': titleController.text, 'username': username, 'slideNum': slideIndex.value});
                            }
                          ),
                        const SizedBox(width: 50),
                        if (slideIndex.value == slideLength)
                        IconButton(
                          iconSize: 40,
                          icon: const Icon(Icons.plus_one),
                          onPressed: () {
                            saveSlide(slideIndex, headingController, bulletController);
                            slideLength++;
                            //saveSlide(slideIndex + 1);
                            widget.socket?.emit('createSlide', {
      'userID': NetworkService.instance.getusername,
      'title': titleController.text,
      'num': (slideIndex.value + 1),
      'header': '',
      'content': '',
    });
                            widget.newSlide = false;

                            setState(() {});
                          }
                        ),
                        const SizedBox(width: 16),
                                              
                      ],
                    ),
                  ),
                ),
              ), 

              Positioned(
                right: 8,
                bottom: 8,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: ColoredBox(
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        '${slideIndex.value}',
                        style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: ColoredBox(
                    color: Colors.green,
                    child:  TextButton(
                      style: TextButton.styleFrom(
                    //foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                    //padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                          saveSlide(slideIndex, headingController, bulletController);
                        },
                      child: const Text('Save', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    } else {
      return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): () {
            slideIndex.value = 1;
              presenting = false;
            widget.socket!.emit('getSlide',{'name': titleController.text, 'username': username, 'slideNum': slideIndex.value});
              setState(() {});
            },
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
              if (slideIndex.value > 1) {
              //prevSlide(context);
              slideIndex.value--;
                                                  widget.socket!.emit('getSlide',{'name': titleController.text, 'username': username, 'slideNum': slideIndex.value});

            }
                          
                          
            },
            const SingleActivator(LogicalKeyboardKey.arrowRight): () {
              print(slideIndex.value);
              if (slideIndex.value < slideLength) {
              nextSlide(context);
              slideIndex.value++;
                                                  widget.socket!.emit('getSlide',{'name': titleController.text, 'username': username, 'slideNum': slideIndex.value});
                                                  print('xdd');
                                                  print(slideLength);
              //print(bulletController.text.split('\n'));
              print('xdddd');
              }
            },
        },
        child: Focus(
        autofocus: true,
      
        child: Scaffold(
      appBar: AppBar(
       
        automaticallyImplyLeading: false,
      ),
      
      body: Center(
        child: Column(
        children: <Widget> [
        Expanded(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
         
          children: [
            Text(headingController.text, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            Text(bulletController.text, style: const TextStyle(fontSize: 36)),
          ],
          
          ),
        ),
                ],
        )
      ),

        )
        )
        
      );
        
      }
  }
}
