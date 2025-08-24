import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoeasy/models/task_details.dart';
import 'package:todoeasy/utils/app_constants.dart';
import 'package:todoeasy/utils/firestore_collections.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<TaskDetails> _tasks = [];
  bool isLoading = false;
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final uuid = const Uuid();

  Future<void> fetchAllTasksOptimised() async {
    setState(() {
      isLoading = true;
    });

    final todoSnap = await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .where('isDone', isEqualTo: false)
        .get();

    final todos = todoSnap.docs;

    todos
        .map((element) => _tasks.add(TaskDetails.fromJson(element.data())))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isNotEmpty) {
                final newTask = TaskDetails(
                  title: title,
                  description: desc,
                  id: uuid.v1(),
                );
                setState(() {
                  _tasks.add(newTask);
                });
                Navigator.pop(context);
                await createNewTask(newTask);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> markAsCompleted(TaskDetails task) async {
    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .doc(task.id)
        .update({
      "isDone": true,
    }).then((value) {
      AppConstans.showSnackBar(
        context,
        isSuccess: true,
        message: 'Voila, your task is marked as done !',
      );
    });
  }

  Future<void> createNewTask(TaskDetails task) async {
    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .doc(task.id)
        .set(task.toJson());
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showTaskDetails(TaskDetails task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Text(task.description.isEmpty
            ? 'No description provided.'
            : task.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    fetchAllTasksOptimised();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _tasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks yet.\nTap + to add your first task!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (value) async {
                              await markAsCompleted(task);
                              setState(() {
                                _tasks.remove(task);
                              });
                            },
                          ),
                          title: Text(
                            task.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: task.description.isNotEmpty
                              ? Text(task.description)
                              : null,
                          onTap: () => _showTaskDetails(task),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _deleteTask(index),
                            tooltip: 'Delete',
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
