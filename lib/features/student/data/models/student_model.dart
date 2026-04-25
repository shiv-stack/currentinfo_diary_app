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
  final String? alternateNumber;
  
  // New Fields
  final String? gender;
  final String? category;
  final String? religion;
  final String? nationality;
  final String? bloodgroup;
  final String? stream;
  final String? adharNumber;
  final String? rfid;
  final String? profession;
  final String? transport;
  final Map<String, dynamic>? rawJson;

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
    this.alternateNumber,
    this.gender,
    this.category,
    this.religion,
    this.nationality,
    this.bloodgroup,
    this.stream,
    this.adharNumber,
    this.rfid,
    this.profession,
    this.transport,
    this.rawJson,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentImage: json['student_image'] as String?,
      thoughtTitle: json['thoughttitle'] as String?,
      thoughtMessage: json['thoughtmessage'] as String?,
      name: json['Name'] as String?,
      className: (json['Class'] ?? json['class']) as String?,
      dob: (json['dob'] ?? json['dateofbirth']) as String?,
      contactNumber: (json['Contact number'] ?? json['contact_number']) as String?,
      cdiaryId: json['cdiaryid'] as String?,
      section: json['section'] as String?,
      session: json['session'] as String?,
      schoolName: json['SchoolName'] as String?,
      address: (json['Address'] ?? json['address']) as String?,
      email: json['email'] as String?,
      fatherName: json['Father'] as String?,
      motherName: json['Mother'] as String?,
      schoolCode: json['school_code'] as String?,
      enrollNumber: json['enroll_number'] as String?,
      password: (json['pass'] ?? json['password']) as String?,
      feesoftware: json['feesoftware'] as String?,
      doa: json['doa'] as String?,
      alternateNumber: json['alternatenumber'] as String?,
      gender: json['gender'] as String?,
      category: json['category'] as String?,
      religion: json['religion'] as String?,
      nationality: json['nationality'] as String?,
      bloodgroup: json['bloodgroup'] as String?,
      stream: json['stream'] as String?,
      adharNumber: (json['adhar_number'] ?? json['adharcard']) as String?,
      rfid: json['rfid'] as String?,
      profession: json['Profession'] as String?,
      transport: json['transport'] as String?,
      rawJson: json,
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
      'alternatenumber': alternateNumber,
      'gender': gender,
      'category': category,
      'religion': religion,
      'nationality': nationality,
      'bloodgroup': bloodgroup,
      'stream': stream,
      'adhar_number': adharNumber,
      'rfid': rfid,
      'Profession': profession,
      'transport': transport,
      ...?rawJson,
    };
  }
}
