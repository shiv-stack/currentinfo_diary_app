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
  final String? enrollNumber;
  final String? password;
  final String? feesoftware;
  final String? doa;

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
    this.enrollNumber,
    this.password,
    this.feesoftware,
    this.doa,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentImage: json['student_image'] as String?,
      thoughtTitle: json['thoughttitle'] as String?,
      thoughtMessage: json['thoughtmessage'] as String?,
      name: json['Name'] as String?,
      className: json['Class'] as String?,
      dob: (json['dob'] ?? json['dateofbirth']) as String?,
      contactNumber: json['Contact number'] as String?,
      cdiaryId: json['cdiaryid'] as String?,
      section: json['section'] as String?,
      session: json['session'] as String?,
      schoolName:
          json['SchoolName'] as String?, // Keep as is if provided elsewhere
      address: json['Address'] as String?,
      email: json['email'] as String?,
      fatherName: json['Father'] as String?,
      motherName: json['Mother'] as String?,
      schoolCode: json['school_code'] as String?,
      enrollNumber: json['enroll_number'] as String?,
      password: json['pass'] as String?,
      feesoftware: json['feesoftware'] as String?,
      doa: json['doa'] as String?,
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
      'section': section,
      'session': session,
      'SchoolName': schoolName,
      'Address': address,
      'email': email,
      'Father': fatherName,
      'Mother': motherName,
      'school_code': schoolCode,
      'enroll_number': enrollNumber,
      'pass': password,
      'feesoftware': feesoftware,
      'doa': doa,
    };
  }
}
