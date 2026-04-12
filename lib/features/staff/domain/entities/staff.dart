import 'package:equatable/equatable.dart';

class Staff extends Equatable {
  final String? staffImage;
  final String? name;
  final String? designation;
  final String? dob;
  final String? contactNumber;
  final String? cdiaryId;
  final String? schoolName;
  final String? address;
  final String? email;
  final String? schoolCode;
  final String? password;

  const Staff({
    this.staffImage,
    this.name,
    this.designation,
    this.dob,
    this.contactNumber,
    this.cdiaryId,
    this.schoolName,
    this.address,
    this.email,
    this.schoolCode,
    this.password,
  });

  @override
  List<Object?> get props => [
        staffImage,
        name,
        designation,
        dob,
        contactNumber,
        cdiaryId,
        schoolName,
        address,
        email,
        schoolCode,
        password,
      ];
}
