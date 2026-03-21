class AssignmentModel {
  final String? id;
  final String? subject;
  final String? date;
  final String? assignment;
  final String? file;
  final String? className;
  final String? section;

  AssignmentModel({
    this.id,
    this.subject,
    this.date,
    this.assignment,
    this.file,
    this.className,
    this.section,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: (json['id'] ?? json['aid'] ?? json['changeid'])?.toString(),
      subject: json['subject']?.toString(),
      date: json['date']?.toString(),
      assignment: json['assignment']?.toString(),
      file: json['file']?.toString(),
      className: json['class']?.toString(),
      section: json['section']?.toString(),
    );
  }
}
