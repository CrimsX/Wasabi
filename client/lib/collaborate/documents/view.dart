import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:client/collaborate/documents/landingpage.dart';



class DocumentsScreen extends StatefulWidget {
  final String username;
  final String serverIP;
  final Socket? socket;
  final int? documentId;
  String? documentTitle;
  String? documentContent;

  DocumentsScreen({
    Key? key,
    required this.username,
    required this.serverIP,
    this.socket,
    this.documentId,
    this.documentTitle,
    this.documentContent,
  }) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  TextEditingController titleController =
  TextEditingController(text: "Untitled Document");
  QuillController _controller = QuillController.basic();
  bool editing = false;
  Timer? _saveTimer;
  final List<dynamic> _friends = [];
  final List<dynamic>_groups = [];


  @override
  void initState() {
    super.initState();
    initializeSocket();
    _startSaveTimer();

    if (widget.documentId != null) {
      widget.socket!.emit('joinRoom', {'roomId': widget.documentId});
      print('${widget.username} joined the room ${widget.documentId}');
    }


    if (widget.documentTitle != null) {
      titleController.text = widget.documentTitle!;
      titleController = TextEditingController(
          text: widget.documentTitle ?? "Untitled Document");


      // Check if documentContent is not null and not empty
      if (widget.documentContent != null &&
          widget.documentContent!.trim().isNotEmpty) {
        try {
          // Parse the JSON string into a Dart object
          final content = jsonDecode(widget.documentContent!);
          // Initialize the Document with parsed content
          final document = Document.fromJson(content);
          // Use the Document to initialize the QuillController
          _controller = QuillController(document: document,
              selection: TextSelection.collapsed(offset: 0));
        } catch (e) {
          // If JSON parsing fails, log the error and initialize with a basic controller
          print("Error parsing document content: $e");
          _controller = QuillController.basic();
        }
      } else {
        // If there's no document content, start with a basic controller
        _controller = QuillController.basic();
      }
    }
    _controller.document.changes.listen((event) {
      String content = jsonEncode(_controller.document.toDelta().toJson());
      _saveContent();
      print(content);
      widget.socket!.emit('fetchDocumentContent', {
        'documentId': widget.documentId,
        'content': content,
      });
    });
  }
  void _handleControllerChanges() {
    // Handle changes to the controller here
    // For example, you can access the current content of the editor using _controller.document.toPlainText()
    print('Controller content changed: ${_controller.document.toPlainText()}');
  }

  void leaveRooms() {
    //  titleController.dispose();
    _saveTimer?.cancel();

    // for the room
    if (widget.documentId != null) {
      widget.socket!.emit('leaveRoom', {'roomId': widget.documentId});
      print('${widget.username} left the room ${widget.documentId}');
    }
    //  super.dispose();
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


      // BroadcastContent is called,
      widget.socket!.on('BroadcastContent', (data) {
        print('Received data: $data'); // This print statement is printing the right data,
        if (mounted) {
          setState(() {
            // This should update the content.
            String receivedContent = data['content'];
            // Update the QuillController with the received content and decode the json
            _controller = QuillController(
              document: Document.fromJson(jsonDecode(receivedContent)),
              selection: TextSelection.collapsed(offset: 0),
            );
          });
          _controller.document.changes.listen((event) {
            String content = jsonEncode(_controller.document.toDelta().toJson());
            _saveContent();
            print(content);
            widget.socket!.emit('fetchDocumentContent', {
              'documentId': widget.documentId,
              'content': content,
            });
          });
        }
      });
    }
  }




  // Create and update //


  void updateDocumentTitle(String newTitle) {

    widget.documentTitle = newTitle;



    //print(widget.documentTitle);
    //print(widget.documentId);
    // Emit the event to update document title
    widget.socket!.emit('updateDocumentTitle', {
      'documentId': widget.documentId, // Use documentId here
      'newTitle': newTitle,
    });
  }


  // Create and update //

  void _startSaveTimer() {
    //print('timer called');
    _saveTimer = Timer.periodic(Duration(seconds: 2), (_) {
      _saveContent();
      //  print('save content called');
    });
  }

  // Method to save the content
  void _saveContent() {
    // Get the content from the editor
    if (_controller.document != null) {
      // Get the content from the editor
      final String content = jsonEncode(_controller.document.toDelta().toJson());
      widget.socket!.emit('saveDocumentContent', {
        'documentId': widget.documentId,
        'content': content,
      });

      // print(widget.documentId);
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
                            'friend': items[i][key],
                            'documentTitle': widget.documentTitle,
                            'content': _controller.document.toPlainText(),
                            'documentId': widget.documentId,
                          });
                        } else if (option == 1) {
                          // Share with collaborators logic
                          print('Share with group: ${items[i][key]}');
                          var id  = 'g' + _groups[i]['ServerID'].toString();
                          widget.socket!.emit('shareDocumentGroup', {
                            'group': id,
                            'user': widget.username,
                            'documentTitle': widget.documentTitle,
                            'content': _controller.document.toPlainText(),
                            'documentId': widget.documentId,
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
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            leaveRooms();
            Navigator.pop(context, true);
          },
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              _shareDocument();
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
                  // print('calling update Title');
                },
              ),
            ),
          ],
        ),
      ),

       // Quill editor
      body: QuillProvider(
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

    );
  }
}
