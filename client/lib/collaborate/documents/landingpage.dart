import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class DocumentsMenu extends StatefulWidget {
  final String username;
  final String serverIP;
  final Socket? socket;

  const DocumentsMenu({
    Key? key,
    required this.username,
    required this.serverIP,
    required this.socket,
  }) : super(key: key);

  @override
  State<DocumentsMenu> createState() => _DocumentsMenuState();
}


class _DocumentsMenuState extends State<DocumentsMenu> {
  List<dynamic> _documents = [];

  @override
  void initState() {
    super.initState();
    initializeSocket();
    fetchDocuments();
  }


  void initializeSocket() {
    if (widget.socket != null) {
      widget.socket!.on('connect', (_) => print('Connected to the socket server'));
      widget.socket!.on('connect_error', (data) => print('Connection error: $data'));
      widget.socket!.on('connect_timeout', (data) => print('Connection timeout: $data'));
      widget.socket!.on('error', (data) => print('Error: $data'));
      widget.socket!.on('disconnect', (_) => print('Disconnected from the socket server'));
    }
  }

  void fetchDocuments() {
    if (widget.socket != null) {
      widget.socket!.emit('fetchDocuments', widget.username);
      widget.socket!.on('documents', (data) {
        if (data != null && data is Map<String, dynamic> && data['documents'] is List) {
          setState(() {
            _documents = List.from(data['documents']);
          });
        } else {
          print("Invalid or null data received for documents");
        }
      });
      widget.socket!.on('error', (data) {
        print('Error fetching documents: ${data['message']}');
      });
    }
  }



  void createNewDocument() {
    if (widget.socket != null) {
      widget.socket!.emit('createNewDocument', {'username': widget.username});
      widget.socket!.on('documentCreated', (data) {
        if (mounted) {
          setState(() {
            print('New document created with ID: ${data['documentId']}');
          });
        }
      });
      widget.socket!.on('documentCreationFailed', (data) {
        if (mounted) {
          print('Failed to create document: ${data['error']}');
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/FileEdit.webp"),
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), BlendMode.dstATop),
              ),
            ),
          ),
          ListView.builder(
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              final document = _documents[index];
              return ListTile(
                title: Text(document['DocumentTitle'] ?? 'Untitled Document'),
                onTap: () {
                  // Implement navigation to document editing/viewing
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: createNewDocument,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}