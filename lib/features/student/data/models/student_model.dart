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
  final String? schoolName;
  final String? address;
  final String? email;
  final String? fatherName;
  final String? motherName;
  final String? schoolCode;

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
    this.schoolName,
    this.address,
    this.email,
    this.fatherName,
    this.motherName,
    this.schoolCode,
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
      schoolName: json['SchoolName'] as String?,
      address: json['Address'] as String?,
      email: json['Email'] as String?,
      fatherName: json['FatherName'] as String?,
      motherName: json['MotherName'] as String?,
      schoolCode: json['school_code'] as String?,
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
      'SchoolName': schoolName,
      'Address': address,
      'Email': email,
      'FatherName': fatherName,
      'MotherName': motherName,
      'school_code': schoolCode,
    };
  }
}
