import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            SizedBox(height: 60),
                            TextFormField(
                              controller: passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
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
