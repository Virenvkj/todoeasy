import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoeasy/models/task_details.dart';
import 'package:todoeasy/utils/app_constants.dart';
import 'package:todoeasy/utils/firestore_collections.dart';

class CompletedTaskScreen extends StatefulWidget {
  const CompletedTaskScreen({super.key});

  @override
  State<CompletedTaskScreen> createState() => _CompletedTaskScreenState();
}

class _CompletedTaskScreenState extends State<CompletedTaskScreen> {
  bool isLoading = false;
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  // ignore: prefer_final_fields
  List<TaskDetails> _tasks = [];

  Future<void> fetchCompletedTasks() async {
    setState(() {
      isLoading = true;
    });

    final completedTodoSnap = await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .where('isDone', isEqualTo: true)
        .get();

    final completedTodos = completedTodoSnap.docs;

    completedTodos
        .map((element) => _tasks.add(TaskDetails.fromJson(element.data())))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteTask({
    required int index,
    required String taskId,
  }) async {
    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .doc(taskId)
        .delete();

    setState(() {
      _tasks.removeAt(index);
    });
  }

  Future<void> markAsCompleted(TaskDetails task) async {
    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .doc(task.id)
        .update({
      "isDone": false,
    }).then((value) {
      AppConstans.showSnackBar(
        context,
        isSuccess: true,
        message: 'Your task is marked as incomplete !',
      );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks();
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
                      'No completed tasks yet.\nComplete your todos from Todos section.',
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _deleteTask(
                              index: index,
                              taskId: task.id,
                            ),
                            tooltip: 'Delete',
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
