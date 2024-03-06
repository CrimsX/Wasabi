//import 'dart:io';

//import 'package:hive/hive.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  //await Hive.initFlutter();
  //final dir = await getApplicationDocumentsDirectory();
  //await Hive.defaultDirectory = dir.path;
  /*
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;
  */


  //final directory = await getApplicationDocumentsDirectory();
  //Hive.defaultDirectory = directory.path;
  
  // this is the working on
  /*
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  */

  //var box = await Hive.openBox('hive');
  //box.put('name', 'Yazan');
  //box.put('numbers', ['1','2','3']);
  //print(box.get('numbers'));

/*
  WidgetsFlutterBinding.ensureInitialized();
    Hive.openBox('myBox');

  Hive.init((await getApplicationDocumentsDirectory()).path);
  var box = Hive.box('myBox');
  String name = box.get('name');
  DateTime birthday = box.get('birthday');
  print('Name: $name');
  await box.close;
  */

  //final directory = await getApplicationDocumentsDirectory();
  //Hive.defaultDirectory = directory.path;

  runApp(BeeApp());
}


class BeeApp extends StatelessWidget {
  //var favoriteBox = await Hive.openBox('favorites');
    WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  //var box = Hive.openBox('hive');
  box.put('name', 'Yazan');
  box.put('numbers', ['1','2','3']);
  print(box.get('numbers'));


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bee Favorites',
      theme: ThemeData(primarySwatch: Colors.yellow),
      home: FavoriteFlowers(),
    );
  }
}

class FavoriteFlowers extends StatefulWidget {
  @override
  _FavoriteFlowersState createState() => _FavoriteFlowersState();
}

class _FavoriteFlowersState extends State<FavoriteFlowers> {
  //favoriteBox.put('name', 'nice');
  //final Box<String> favoriteBox = Hive.box<String>('favorites');

  final List<String> flowers = ['Rose', 'Tulip', 'Daisy', 'Lily', 'Sunflower'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bee Favorites 🐝')),
      body: ListView.builder(
        itemCount: flowers.length,
        itemBuilder: (context, index) {
          final flower = flowers[index];
          return ListTile(
            title: Text(flower),
            trailing: IconButton(
              icon: Icon(Icons.star),
              onPressed: () {
                //favoriteBox.put(flower, flower);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$flower added to favorites! 🌼')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.view_list),
        onPressed: () {
          /*
          showDialog(
            context: context,
            builder: (context) => FavoritesDialog(favorites: favoriteBox.toList()),
          );
          */
        },
      ),
    );
  }
}

class FavoritesDialog extends StatelessWidget {
  final List<String> favorites;

  FavoritesDialog({required this.favorites});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bee Favorites 🌼'),
      content: Container(
        width: 300,
        height: 200,
        child: ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(favorites[index]));
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}


//part 'test.g.dart';

//void//
/*
@HiveType(typeId: 1)
class Person {
  Person({required this.name, required this.age, required this.friends});

  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  List<String> friends;

  @override
  String toString() {
    return '$name: $age';
  }
}

void main() async {
  var path = Directory.current.path;
  Hive
    ..init(path)
    ..registerAdapter(PersonAdapter());

  var box = await Hive.openBox('testBox');

  var person = Person(
    name: 'Dave',
    age: 22,
    friends: ['Linda', 'Marc', 'Anne'],
  );

  await box.put('dave', person);

  print(box.get('dave')); // Dave: 22
}
*/
/*
void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //final dir = await getApplicationDocumentsDirectory();
  //Hive.defaultDirectory = dir.path;
final box = Hive.box('insect');
box.put('danceMoves', 'Waggle Dance');
box.put('wingSpeed', 200);
print(box.get('danceMoves'));
*/
/*
final box = Hive.box('name');
box.put('name', 'David');

final name = box.get('name');
print('Name: $name');
*/
  // ...
//}



