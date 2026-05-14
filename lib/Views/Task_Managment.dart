import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskManagement extends StatefulWidget {
  const TaskManagement({super.key});

  @override
  State<TaskManagement> createState() => _TaskManagementState();
}

class _TaskManagementState extends State<TaskManagement> {
  List<String> tasks = [];
  List<String> completedTasks = [];
  final TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Load tasks
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedTasks = prefs.getStringList('tasks');
    final List<String>? savedCompleted = prefs.getStringList('completed');

    if (savedTasks != null) {
      tasks = savedTasks;
    }

    if (savedCompleted != null) {
      completedTasks = savedCompleted;
    }

    setState(() {});
  }

  // Save tasks
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', tasks);
    await prefs.setStringList('completed', completedTasks);
  }

  // Add task
  void addTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(
              hintText: 'Enter your task...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                taskController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (taskController.text.trim().isNotEmpty) {
                  tasks.add(taskController.text.trim());
                  saveTasks();
                  setState(() {});
                }
                Navigator.pop(context);
                taskController.clear();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Delete task
  void deleteTask(int index) {
    tasks.removeAt(index);
    saveTasks();
    setState(() {});
  }

  // Mark as complete
  void markComplete(int index) {
    String task = tasks[index];

    if (completedTasks.contains(task)) {
      completedTasks.remove(task);
    } else {
      completedTasks.add(task);
    }

    saveTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addTask,
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
        child: Text('No tasks. Tap + to add a task'),
      )
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          String task = tasks[index];
          bool isCompleted = completedTasks.contains(task);

          return ListTile(
            leading: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
            title: Text(task),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => deleteTask(index),
            ),
            onTap: () => markComplete(index),
          );
        },
      ),
    );
  }
}