import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/staff.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_data_source.dart';
import '../../../student/data/models/student_model.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Staff>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  }) async {
    try {
      final staff = await remoteDataSource.login(
        schoolCode: schoolCode,
        name: name,
        uniqueCode: uniqueCode,
      );
      return Right(staff);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadData({
    required String schoolCode,
    required String login,
    required String password,
    required String staffClass,
    required String title,
    required String description,
    required String className,
    required String section,
    required String session,
    required String uploadDetails,
    required String featureTitle,
    String? filePath,
  }) async {
    try {
      final result = await remoteDataSource.uploadData(
        schoolCode: schoolCode,
        login: login,
        password: password,
        staffClass: staffClass,
        title: title,
        description: description,
        className: className,
        section: section,
        session: session,
        uploadDetails: uploadDetails,
        featureTitle: featureTitle,
        filePath: filePath,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentModel>>> getStudentRecord({
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
    try {
      final students = await remoteDataSource.getStudentRecord(
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
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getFeeReport({
    required String schoolCode,
    required String login,
    required String password,
    required String session,
    required String reportType,
    required String paymentMode,
    required String day,
    required String month,
    required String staffc,
    required String studentFeeSoftware,
  }) async {
    try {
      final report = await remoteDataSource.getFeeReport(
        schoolCode: schoolCode,
        login: login,
        password: password,
        session: session,
        reportType: reportType,
        paymentMode: paymentMode,
        day: day,
        month: month,
        staffc: staffc,
        studentFeeSoftware: studentFeeSoftware,
      );
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
