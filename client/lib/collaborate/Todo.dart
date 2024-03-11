import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class Task {
  final int id;
  String name;
  bool isFinished;

  Task({required this.id, required this.name, required this.isFinished});
}

class TodoScreen extends StatefulWidget {
  String username = '';
  String serverIP = '';
  Socket? socket;

  TodoScreen({Key? key, required this.username, required this.serverIP, required this.socket}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _connectSocket();
    widget.socket!.emit('getTasks', widget.username);
  }

  void _connectSocket() {
    widget.socket!.on('tasks', (data) {
      retrieveTasks(data);
    });

    widget.socket!.on('taskStatusUpdated', (data) {
      markAsComplete(data);
    });

    widget.socket!.on('taskStatusUndone', (data) {
      undoCompletedTask(data);
    });

    widget.socket!.on('taskCreated', (data) {
      if (mounted) {
        setState(() {
          Task task = Task(id: data['result'][0]['taskID'], name: data['result'][0]['taskName'], isFinished: data['result'][0]['taskStatus'] != 0);
          _tasks.add(task);
        });
      }
    });

  }

  retrieveTasks(data) {
    if (mounted) {
      setState(() {
        for (var task in data) {
          _tasks.add(Task(id: task['TaskID'], name: task['TaskName'], isFinished: (task['TaskStatus'] != 0)));
        }
      });
    }
  }

  markAsComplete(data) {
    if (mounted) {
      setState(() {
        for (Task task in _tasks) {
          if (task.id == data['ID']) {
            task.isFinished = true;
            return;
          }
        }
      });
    }
  }

  undoCompletedTask(data) {
    if (mounted) {
      setState(() {
        for (Task task in _tasks) {
          if (task.id == data['ID']) {
            task.isFinished = false;
            return;
          }
        }
      });
    }
  }

  deleteTask(data) {
    if (mounted) {
      setState(() {
        for (Task task in _tasks) {
          if (task.id == data.id) {
            _tasks.remove(task);
            return;
          }
        }
        print(data);
      });
    }
  }

  void _showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();
    TextEditingController userController = TextEditingController();
    TextEditingController serverController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: taskController,
                  decoration: const InputDecoration(hintText: "Task Name"),
                ),
                TextField(
                  controller: userController,
                  decoration: const InputDecoration(
                      hintText: "Share with user (Optional)"),
                ),
                TextField(
                  controller: serverController,
                  decoration: const InputDecoration(
                      hintText: "Share with server (Optional)"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  // createTask
                  widget.socket!.emit('createTask', {
                    'taskName': taskController.text,
                    'userID': widget.username,
                  });
                  Navigator.of(context).pop();
                }
              },
            )
          ],
        );
      },
    );
  }

  void _confirmDeleteTask(Task task, bool isFinished) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                // Emit a socket event to delete the task
                widget.socket!.emit('deleteTask', task.id);
                // Update the UI to reflect the deletion
                setState(() {
                    deleteTask(task);
                  }
                );
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
            child: _buildTaskList(
                _tasks.where((task) => task.isFinished == false).toList(),
                false),
          ),
          Divider(height: 2, color: Colors.green[200]),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Finished Tasks:',
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ),
          ),
          Expanded(
            child: _buildTaskList(
                _tasks.where((task) => task.isFinished == true).toList(), true),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  Widget _buildTaskList(List<Task> tasks, bool finished) {
    return Column(
      children: [
        if (!finished) // Show only if tasks are unfinished
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.white, // Unfinished tasks color
                  child: ListTile(
                    title: Text(
                      tasks[index].name,
                      style: const TextStyle(
                          color: Colors.black), // Unfinished tasks text color
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            int taskID = tasks[index].id;
                            widget.socket!.emit('updateTaskStatus', taskID);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteTask(tasks[index], false),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        Divider(height: 2, color: Colors.green[200]),
        if (finished) // Show only if tasks are finished
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.green, // Finished tasks color
                  child: ListTile(
                    title: Text(
                      tasks[index].name,
                      style: const TextStyle(
                          color: Colors.white), // Finished tasks text color
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.undo, color: Colors.white),
                          onPressed: () {
                            int taskID = tasks[index].id;
                            widget.socket!.emit('undoTaskStatus', taskID);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _confirmDeleteTask(tasks[index], true),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
