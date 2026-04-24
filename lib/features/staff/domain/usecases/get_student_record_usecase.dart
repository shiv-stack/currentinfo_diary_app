import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../student/data/models/student_model.dart';
import '../repositories/staff_repository.dart';

class GetStudentRecordUseCase {
  final StaffRepository repository;

  GetStudentRecordUseCase(this.repository);

  Future<Either<Failure, List<StudentModel>>> call({
    required String schoolCode,
    required String teaname,
    required String tpass,
    required String tclass,
    required String inschool,
    required String session,
    required String classValue,
    required String profession,
    required String section,
    required String transportstatus,
  }) async {
    return await repository.getStudentRecord(
      schoolCode: schoolCode,
      teaname: teaname,
      tpass: tpass,
      tclass: tclass,
      inschool: inschool,
      session: session,
      classValue: classValue,
      profession: profession,
      section: section,
      transportstatus: transportstatus,
    );
  }
}
