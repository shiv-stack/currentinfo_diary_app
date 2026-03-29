import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/student_model.dart';
import '../../data/models/leave_model.dart';
import '../../data/models/exam_model.dart';
import '../../data/models/mark_detail_model.dart';

abstract class StudentRepository {
  Future<Either<Failure, StudentModel>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });

  Future<Either<Failure, void>> logoutNotification({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });

  Future<Either<Failure, List<dynamic>>> getClassNotices({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String className,
    required String section,
    String display = "classnot",
  });

  Future<Either<Failure, List<dynamic>>> getAttendance({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String month,
  });

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
  });

  Future<Either<Failure, List<dynamic>>> getFees({
    required String schoolCode,
    required String cdiaryId,
    required String password,
    required String session,
    required String studentFeeSoftware,
  });

  Future<Either<Failure, List<ExamModel>>> getExams({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
  });

  Future<Either<Failure, List<MarkDetailModel>>> getMarkDetails({
    required String schoolCode,
    required String studentId,
    required String password,
    required String session,
    required String marksClass,
    required String marksYear,
    required String marksExam,
  });

  Future<Either<Failure, List<LeaveModel>>> getLeaves({
    required String schoolCode,
    required String studentId,
    required String password,
  });

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
  });

  Future<Either<Failure, String>> updatePassword({
    required String schoolCode,
    required String studentId,
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, List<dynamic>>> getMessages({
    required String schoolCode,
    required String studentId,
    required String password,
  });
}
