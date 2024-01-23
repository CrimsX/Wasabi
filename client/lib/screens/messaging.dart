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

  Widget _buildHoverableTile({
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.green : Colors.grey,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: selected ? Colors.grey.withOpacity(0.5) : Color(0xFF0a3107),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF031003),
      appBar: AppBar(
        title: Text(
          'Wasabi',
          style: TextStyle(
            color: Colors.green,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Color(0xFF0a3107),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF0a3107),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHoverableTile(
                title: 'My Profile',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Direct Message',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Group Message',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Collaborate',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildHoverableTile(
                title: 'Logout',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Color(0xFF031003),
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
                        color: Color(0xFF0a3107),
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
                                color: Colors.green,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            _messages[index]['message'] ?? '',
                            style:
                            TextStyle(color: Colors.grey, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            color: Color(0xFF0a3107),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey),
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
        ],
      ),
    );
  }
}
