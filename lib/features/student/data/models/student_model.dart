class StudentModel {
  final String? studentImage;
  final String? thoughtTitle;
  final String? thoughtMessage;
  final String? name;
  final String? className;
  final String? dob;
  final String? contactNumber;
  final String? cdiaryId;
  final String? section;
  final String? session;

  StudentModel({
    this.studentImage,
    this.thoughtTitle,
    this.thoughtMessage,
    this.name,
    this.className,
    this.dob,
    this.contactNumber,
    this.cdiaryId,
    this.section,
    this.session,
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
      cdiaryId: json['cdiaryid'] as String?,
      section: json['Section'] as String?,
      session: json['session'] as String?,
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
      'cdiaryid': cdiaryId,
      'Section': section,
      'session': session,
    };
  }
}
