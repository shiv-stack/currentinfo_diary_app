import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff.dart';

abstract class StaffRepository {
  Future<Either<Failure, Staff>> login({
    required String schoolCode,
    required String name,
    required String uniqueCode,
  });
}
