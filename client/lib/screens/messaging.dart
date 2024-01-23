import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    setState(() {
      _messages.add({
        'sender': 'Sender',
        'message': _controller.text,
      });
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double drawerWidth = MediaQuery.of(context).size.width * 0.16;

    return Scaffold(
      backgroundColor: Color(0xFF031003),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/WasabiIcon.png',
                width: 40,
                height: 40,
              ),
            ),
            Spacer(),
            Spacer(),
            IconButton(
              icon: Icon(Icons.face_sharp),
              onPressed: () {
                // Handle My Profile tap
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.message),
              onPressed: () {
                // Handle Direct Message tap
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.groups_2_rounded),
              onPressed: () {
                // Handle Group Message tap
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.folder_copy_rounded),
              onPressed: () {
                // Handle Collaborate tap
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Handle Settings tap
              },
              color: Colors.white,
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app_rounded),
              onPressed: () {
                // Handle Logout tap
              },
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Container(
            width: drawerWidth,
            decoration: BoxDecoration(
              color: Colors.white, // Set the desired color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Contacts',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                // Populate the contact information
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 8.0,
                              bottom: 8.0,
                              left: 80.0,
                              right: 8.0,
                            ),
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(0.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_messages[index]['sender']}:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6.0),
                                Text(
                                  _messages[index]['message'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Set the background color for the entire bottomNavigationBar
        ),
        child: SizedBox(
          height: 80,
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    // Handle image button tap
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.green,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

