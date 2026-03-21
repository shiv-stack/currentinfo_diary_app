import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_data_source.dart';
import '../models/student_model.dart';
import '../models/leave_model.dart';
import '../models/exam_model.dart';
import '../models/mark_detail_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StudentModel>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    try {
      final student = await remoteDataSource.login(
        schoolCode: schoolCode,
        name: name,
        uniqueCode: uniqueCode,
      );
      return Right(student);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getClassNotices({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String className,
    required String section,
    String display = "classnot",
  }) async {
    try {
      final notices = await remoteDataSource.getClassNotices(
        schoolCode: schoolCode,
        cdiaryId: cdiaryId,
        password: password,
        session: session,
        className: className,
        section: section,
        display: display,
      );
      return Right(notices);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAttendance({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
  }) async {
    try {
      final attendance = await remoteDataSource.getAttendance(
        schoolCode: schoolCode,
        cdiaryId: cdiaryId,
        password: password,
        session: session,
        month: month,
      );
      return Right(attendance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAssignments({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
    required String day,
    required String studentClass,
    required String section,
    required String showhw,
  }) async {
    try {
      final assignments = await remoteDataSource.getAssignments(
        schoolCode: schoolCode,
        cdiaryId: cdiaryId,
        password: password,
        session: session,
        month: month,
        day: day,
        studentClass: studentClass,
        section: section,
        showhw: showhw,
      );
      return Right(assignments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getFees({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String studentFeeSoftware,
  }) async {
    try {
      final fees = await remoteDataSource.getFees(
        schoolCode: schoolCode,
        cdiaryId: cdiaryId,
        password: password,
        session: session,
        studentFeeSoftware: studentFeeSoftware,
      );
      return Right(fees);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExamModel>>> getExams({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
  }) async {
    try {
      final exams = await remoteDataSource.getExams(
        schoolCode: schoolCode,
        studentId: studentId,
        password: password,
        session: session,
      );
      return Right(exams);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarkDetailModel>>> getMarkDetails({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
    required String marksClass,
    required String marksYear,
    required String marksExam,
  }) async {
    try {
      final details = await remoteDataSource.getMarkDetails(
        schoolCode: schoolCode,
        studentId: studentId,
        password: password,
        session: session,
        marksClass: marksClass,
        marksYear: marksYear,
        marksExam: marksExam,
      );
      return Right(details);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaveModel>>> getLeaves({
    required String schoolCode,
    required String studentId,
    required String password,
  }) async {
    try {
      final leaves = await remoteDataSource.getLeaves(
        schoolCode: schoolCode,
        studentId: studentId,
        password: password,
      );
      return Right(leaves);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> applyLeave({
    required String schoolCode,
    required String studentId,
    required String password,
    required String studentName,
    required String studentClass,
    required String admissionRollNo,
    required String session,
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.applyLeave(
        schoolCode: schoolCode,
        studentId: studentId,
        password: password,
        studentName: studentName,
        studentClass: studentClass,
        admissionRollNo: admissionRollNo,
        session: session,
        fromDate: fromDate,
        toDate: toDate,
        reason: reason,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updatePassword({
    required String schoolCode,
    required String studentId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final result = await remoteDataSource.updatePassword(
        schoolCode: schoolCode,
        studentId: studentId,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
