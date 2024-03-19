import 'package:flutter/material.dart';

import 'package:flutter_quill/flutter_quill.dart';

class DocumentsScreen extends StatefulWidget {

  DocumentsScreen({super.key});
  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  TextEditingController titleController = TextEditingController(text: "Untitled Document");
  QuillController _controller = QuillController.basic();
  bool editing = false;

  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !editing
        ? AppBar(
            title: const Text('Documents'),
            backgroundColor: Colors.green,
          )

        : AppBar(
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  editing = false;
                });
              },
            ),

            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    editing = false;
                  });
                },
                icon: const Icon(Icons.lock),
                label: const Text('Share'),
              ),         
            ],

            title: Row(
              children: [
                const Icon(Icons.edit),
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
              ],
            ),
          ),

      // Background image
      body: !editing 
        // Background image
        ? new Stack(
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/FileEdit.webp"),
                  colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
                ),
              ),
            ),
          ],
        )

        // Quill editor
        : QuillProvider(
          configurations: QuillConfigurations(
            controller: _controller,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const QuillToolbar(),
              Expanded(
                child: SizedBox(
                  width: 750,
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: QuillEditor.basic(
                        configurations: const QuillEditorConfigurations(
                          readOnly: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // New document button
      floatingActionButton: !editing 
        ? FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () {  
            setState(() {
            editing = true;
            });
          },
          child: Icon(Icons.add, color: Colors.white),
        )

        : null,      
    );
  }
}
