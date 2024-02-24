import 'package:flutter/material.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<String> _tasks = [];
  List<String> _finishedTasks = [];

  void _showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    TextEditingController userController = TextEditingController();
    TextEditingController serverController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: taskController,
                  decoration: InputDecoration(hintText: "Task Name"),
                ),
                TextField(
                  controller: userController,
                  decoration: InputDecoration(hintText: "Share with user (Optional)"),
                ),
                TextField(
                  controller: serverController,
                  decoration: InputDecoration(hintText: "Share with server (Optional)"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  setState(() {
                    _tasks.add(taskController.text);
                    // Optionally handle user/server sharing here
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTask(int index, bool isFinished) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Task"),
          content: Text("Are you sure you want to delete this task?"),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  if (isFinished) {
                    _finishedTasks.removeAt(index);
                  } else {
                    _tasks.removeAt(index);
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildTaskList(_tasks, false),
          ),
          Divider(height: 2, color: Colors.green[200]),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Finished Tasks:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ),
          Expanded(
            child: _buildTaskList(_finishedTasks, true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskList(List<String> tasks, bool finished) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          color: finished ? Colors.green : Colors.white,
          child: ListTile(
            title: Text(
              tasks[index],
              style: TextStyle(color: finished ? Colors.white : Colors.black),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: finished ? [
                IconButton(
                  icon: Icon(Icons.undo, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _tasks.add(_finishedTasks[index]);
                      _finishedTasks.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteTask(index, true),
                ),
              ] : [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      _finishedTasks.add(_tasks[index]);
                      _tasks.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteTask(index, false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
