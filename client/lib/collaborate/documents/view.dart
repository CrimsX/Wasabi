import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:async';

class DocumentsScreen extends StatefulWidget {
  final String username;
  final String serverIP;
  final Socket? socket;

  DocumentsScreen({
    Key? key,
    required this.username,
    required this.serverIP,
    required this.socket,
  }) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  TextEditingController titleController =
  TextEditingController(text: "Untitled Document");
  QuillController _controller = QuillController.basic();
  bool editing = false;
  int? documentId;
  Timer? _saveTimer;
  final List<dynamic> _friends = [];
  final List<dynamic>_groups = [];

  @override
  void initState() {
    super.initState();
    // Initialize the socket connection
    initializeSocket();
    _startSaveTimer();
  }

  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  // Method to initialize the socket connection and listeners
  void initializeSocket() {
    if (widget.socket != null) {
      // Listen for socket connection successful
      widget.socket!.on('connect', (_) => print('Connected to the socket server'));

      // Listen for socket connection error
      widget.socket!.on('connect_error', (data) => print('Connection error: $data'));

      // Listen for socket connection timeout
      widget.socket!.on('connect_timeout', (data) => print('Connection timeout: $data'));

      // Listen for any errors
      widget.socket!.on('error', (data) => print('Error: $data'));

      // Listen for socket disconnection
      widget.socket!.on('disconnect', (_) => print('Disconnected from the socket server'));

      // Emit socket events
      widget.socket!.emit('buildfriendscollab', widget.username);
      widget.socket!.emit('buildgroupscollab', widget.username);

      // Listen for responses to build friends collaboration
      widget.socket!.on('buildfriendscollab', (data) {
        if (mounted) {
          setState(() {
            _friends.addAll(data);
          });
        }
      });

      // Listen for responses to build groups collaboration
      widget.socket!.on('buildgroupscollab', (data) {
        if (mounted) {
        setState(() {
          _groups.addAll(data);
        });
      }
      });
    }
  }


  // Create and update //


  void updateDocumentTitle(String newTitle) {
    if (widget.socket != null && documentId != null) {
      // Emit the event to update document title
      widget.socket!.emit('updateDocumentTitle', {
        'documentId': documentId, // Use documentId here
        'newTitle': newTitle,
      });
    }
  }

  void createNewDocument() {
    if (widget.socket != null) {
      // Emit the event to create a new document
      widget.socket!.emit('createNewDocument', {'username': widget.username});

      // Listen for the response from the server
      widget.socket!.on('documentCreated', (data) {
        if (mounted) {
          setState(() {
            // Handle the document creation response
            // For example, you can navigate to the newly created document page
            documentId = data['documentId'];
            print('New document created with ID: ${data['documentId']}');
          });
        }
      });

      // Listen for any error response from the server
      widget.socket!.on('documentCreationFailed', (data) {
        if (mounted) {
          setState(() {
            // Handle the document creation failure
            print('Failed to create document: ${data['error']}');
          });
        }
      });
    }
  }

  // Create and update //

  // Timer auto save //
  void _startSaveTimer() {
    print('timer called');
    _saveTimer = Timer.periodic(Duration(seconds: 2), (_) {
        _saveContent();
        print('save content called');
    });
  }

  // Method to save the content
  void _saveContent() {
    // Get the content from the editor
    if (_controller.document != null) {
      // Get the content from the editor
      String content = _controller.document.toPlainText();
      widget.socket!.emit('saveDocumentContent',
          {'documentId': documentId, 'content': content});
      print('Content saved: $content');
    } else {
      print("null");
    }
  }

  // Timer auto save //

  // share docs //

  void _shareDocument() {
    int selectedOption = 0; // Track the selected radio button option

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Would you like to share this document?"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    RadioListTile(
                      title: Text('Share with Friends'),
                      value: 0,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Share with Collaborators'),
                      value: 1,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Don\'t share'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Next'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _shareSelect(selectedOption);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _shareSelect(int option) {
    List<dynamic> items = [];
    String key = "";
    if (option == 0){
      items = _friends;
      key = 'FriendID';
    } else if (option == 1) {
      items = _groups;
      key = 'ServerName';
    }
    List<bool> checkedItems = List<bool>.filled(items.length, false); // Initialize with false values
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Items'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    items.length,
                        (index) {
                      return CheckboxListTile(
                        title: Text(items[index][key]),
                        value: checkedItems[index],
                        onChanged: (newValue) {
                          setState(() {
                            checkedItems[index] = newValue!;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Perform actions based on the checked items
                    for (int i = 0; i < items.length; i++) {
                      if (checkedItems[i]) {
                        if (option == 0) {
                          // Share with friends logic
                          print('Share with friend: ${items[i][key]}');
                          widget.socket!.emit('shareDocument', {
                            'friendId': items[i][key],
                            'documentTitle': titleController.text,
                            'content': _controller.document.toPlainText(),
                            'documentId': documentId,
                          });
                        } else if (option == 1) {
                          // Share with collaborators logic
                          print('Share with collaborators: ${items[i][key]}');
                          widget.socket!.emit('shareDocumentGroup', {
                            'group': _groups[i][key],
                            'user': widget.username,
                            'documentTitle': titleController.text,
                            'content': _controller.document.toPlainText(),
                            'documentId': documentId,
                          });
                        }
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Share'),
                ),
              ],
            );
          },
        );
      },
    );
  }






  // share docs //



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
                onPressed: () { _shareDocument();
                 // setState(() {
                 //   editing = false;
                //  });
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
                    onChanged: (value) {
                      // Update document title as the user types
                      updateDocumentTitle(value);
                    },
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
            editing = true; // Set editing to true
          });
          createNewDocument(); // Call the function to create a new document
        },
        child: Icon(Icons.add, color: Colors.white),
      )

          : null,
    );
  }
}
