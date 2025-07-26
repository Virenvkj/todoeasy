class TaskDetails {
  final String title;
  final String description;
  bool isDone;

  TaskDetails({
    required this.title,
    required this.description,
    this.isDone = false,
  });
}
