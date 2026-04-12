import '../../domain/entities/staff.dart';

class StaffModel extends Staff {
  const StaffModel({
    super.staffImage,
    super.name,
    super.designation,
    super.dob,
    super.contactNumber,
    super.cdiaryId,
    super.schoolName,
    super.address,
    super.email,
    super.schoolCode,
    super.password,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      staffImage: json['student_image'] as String?, // API often uses same keys
      name: json['Name'] as String?,
      designation: json['Designation'] as String?,
      dob: (json['dob'] ?? json['dateofbirth']) as String?,
      contactNumber: json['Contact number'] as String?,
      cdiaryId: json['cdiaryid'] as String?,
      schoolName: json['SchoolName'] as String?,
      address: json['Address'] as String?,
      email: json['email'] as String?,
      schoolCode: json['school_code'] as String?,
      password: json['pass'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_image': staffImage,
      'Name': name,
      'Designation': designation,
      'dob': dob,
      'Contact number': contactNumber,
      'cdiaryid': cdiaryId,
      'SchoolName': schoolName,
      'Address': address,
      'email': email,
      'school_code': schoolCode,
      'pass': password,
    };
  }

  Staff toEntity() => this;
}
