class TaskDetails {
  final String title;
  final String description;
  bool isDone;

  TaskDetails({
    required this.title,
    required this.description,
    this.isDone = false,
  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) => TaskDetails(
        title: json["title"],
        description: json["description"],
        isDone: json["isDone"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "isDone": isDone,
      };
}
