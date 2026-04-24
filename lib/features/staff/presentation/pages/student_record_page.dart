import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff.dart';
import '../bloc/student_record_cubit.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/utils/app_toast.dart';

class StudentRecordPage extends StatefulWidget {
  final Staff staff;
  const StudentRecordPage({super.key, required this.staff});

  @override
  State<StudentRecordPage> createState() => _StudentRecordPageState();
}

class _StudentRecordPageState extends State<StudentRecordPage> {
  final List<String> classes = [
    "Student",
    "Chairman",
    "Director",
    "Principal",
    "Vice-Principal",
    "Teacher",
    "KinderGarten",
    "Playgroup",
    "Pre-Nursery",
    "Nursery",
    "Nursery (S)",
    "Nursery (J)",
    "LKG",
    "UKG",
    "KG",
    "First",
    "Second",
    "Third",
    "Fourth",
    "Fifth",
    "Sixth",
    "Seventh",
    "Eighth",
    "Ninth",
    "Tenth",
    "Eleventh",
    "Twelfth",
    "Helper",
    "Accountant",
    "Staff",
    "Admin",
    "Transport Incharge",
    "Driver",
    "Reception",
    "Guard",
  ];

  final List<String> sections = [
    "Section",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "A1",
    "B1",
    "C1",
    "D1",
    "E1",
    "F1",
    "G1",
    "H1",
    "I1",
    "J1",
    "K1",
    "L1",
    "M1",
    "N1",
    "O1",
    "P1",
    "Q1",
    "R1",
    "S1",
    "T1",
    "U1",
    "V1",
    "W1",
    "X1",
    "Y1",
    "Z1",
    "A2",
    "B2",
    "C2",
    "D2",
    "E2",
    "F2",
    "G2",
    "H2",
    "I2",
    "J2",
    "K2",
    "L2",
    "M2",
    "N2",
    "O2",
    "P2",
    "Q2",
    "R2",
    "S2",
    "T2",
    "U2",
    "V2",
    "W2",
    "X2",
    "Y2",
    "Z2",
    "A3",
    "B3",
    "C3",
    "D3",
    "E3",
    "F3",
    "G3",
    "H3",
    "I3",
    "J3",
    "K3",
    "L3",
    "M3",
    "N3",
    "O3",
    "P3",
    "Q3",
    "R3",
    "S3",
    "T3",
    "U3",
    "V3",
    "W3",
    "X3",
    "Y3",
    "Z3",
  ];

  final List<String> sessions = [
    "2026-2027",
    "2025-2026",
    "2024-2025",
    "2023-2024",
    "2022-2023",
    "2021-2022",
  ];
  final List<String> schoolStatuses = ["Yes", "No"];
  final List<String> transports = [
    "Transport",
    "Bus1N",
    "Bus2N",
    "Bus3N",
    "Bus4N",
    "Bus5N",
    "Bus6N",
    "Bus7N",
    "Bus8N",
    "Bus9N",
    "Bus10N",
    "Bus11N",
    "Bus12N",
    "Bus13N",
    "Bus14N",
    "Bus15N",
    "Bus16N",
    "Bus17N",
    "Bus18N",
    "Bus19N",
    "Bus20N",
    "Bus21N",
    "Bus22N",
    "Bus23N",
    "Bus24N",
    "Bus25N",
    "Bus26N",
    "Bus27N",
    "Bus28N",
    "Bus29N",
  ];

  String selectedClass = "Student";
  String selectedSection = "Section";
  String selectedSession = "2026-2027";
  String selectedStatus = "Yes";
  String selectedTransport = "Transport";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<StudentRecordCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            "Student Record",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF1A1C1E),
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1C1E),
          elevation: 0,
          centerTitle: false,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          "Class/Profession",
                          classes,
                          selectedClass,
                          (val) => setState(() => selectedClass = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdown(
                          "Section",
                          sections,
                          selectedSection,
                          (val) => setState(() => selectedSection = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          "Session",
                          sessions,
                          selectedSession,
                          (val) => setState(() => selectedSession = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdown(
                          "School Status",
                          schoolStatuses,
                          selectedStatus,
                          (val) => setState(() => selectedStatus = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    "Transport Facility",
                    transports,
                    selectedTransport,
                    (val) => setState(() => selectedTransport = val!),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<StudentRecordCubit, StudentRecordState>(
                    builder: (context, state) {
                      final isLoading = state is StudentRecordLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _onSearchPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const AppLoadingIndicator(
                                  centered: false,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  "SEARCH RECORDS",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<StudentRecordCubit, StudentRecordState>(
                builder: (context, state) {
                  if (state is StudentRecordLoaded) {
                    if (state.students.isEmpty) {
                      return const Center(
                        child: Text("No students found matching filters."),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.students.length,
                      itemBuilder: (context, index) {
                        final student = state.students[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: student.studentImage != null && student.studentImage!.isNotEmpty
                                    ? Image.network(
                                        student.studentImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Icon(Icons.person, color: Theme.of(context).primaryColor),
                                      )
                                    : Icon(Icons.person, color: Theme.of(context).primaryColor),
                              ),
                            ),
                            title: Text(
                              student.name ?? "Unknown",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1C1E),
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Class: ${student.className} | Sec: ${student.section}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is StudentRecordError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is StudentRecordInitial) {
                    return const Center(
                      child: Text("Select filters and press search"),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              menuMaxHeight: 300,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF1A1C1E)),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _onSearchPressed(BuildContext context) {
    context.read<StudentRecordCubit>().fetchStudentRecord(
      schoolCode: widget.staff.schoolCode ?? "",
      teaname: widget.staff.name ?? "",
      tpass: widget.staff.password ?? "",
      tclass:
          widget.staff.designation ?? "", // staffc maps to designation or class
      inschool: selectedStatus == "Yes" ? "School Status - Yes" : "No",
      session: selectedSession,
      classValue: selectedClass,
      profession: selectedClass, // Profession same as class in dropdown
      section: selectedSection,
      transportstatus: selectedTransport,
    );
  }
}
