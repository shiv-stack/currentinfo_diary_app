class StudentModel {
  final String? studentImage;
  final String? thoughtTitle;
  final String? thoughtMessage;
  final String? name;
  final String? className;
  final String? dob;
  final String? contactNumber;

  StudentModel({
    this.studentImage,
    this.thoughtTitle,
    this.thoughtMessage,
    this.name,
    this.className,
    this.dob,
    this.contactNumber,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentImage: json['student_image'] as String?,
      thoughtTitle: json['thoughttitle'] as String?,
      thoughtMessage: json['thoughtmessage'] as String?,
      name: json['Name'] as String?,
      className: json['Class'] as String?,
      dob: json['dob'] as String?,
      contactNumber: json['Contact number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_image': studentImage,
      'thoughttitle': thoughtTitle,
      'thoughtmessage': thoughtMessage,
      'Name': name,
      'Class': className,
      'dob': dob,
      'Contact number': contactNumber,
    };
  }
}
