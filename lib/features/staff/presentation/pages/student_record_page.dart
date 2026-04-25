import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff.dart';
import '../bloc/student_record_cubit.dart';
import '../bloc/user_detail_cubit.dart';
import './user_detail_page.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
            "Users Record",
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
        body: BlocBuilder<StudentRecordCubit, StudentRecordState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // --- Scrollable Filter Section ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
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
                          const SizedBox(width: 12),
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
                      const SizedBox(height: 12),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              "Status",
                              schoolStatuses,
                              selectedStatus,
                              (val) => setState(() => selectedStatus = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        "Transport Facility",
                        transports,
                        selectedTransport,
                        (val) => setState(() => selectedTransport = val!),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state is StudentRecordLoading
                              ? null
                              : () => _onSearchPressed(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state is StudentRecordLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "SEARCH RECORDS",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- Results Section ---
                if (state is StudentRecordLoaded)
                  state.students.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Text(
                              "No matching records found.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.students.length,
                          itemBuilder: (context, index) {
                            final student = state.students[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () async {
                                  final staffRoles = [
                                    "Chairman",
                                    "Director",
                                    "Principal",
                                    "Vice-Principal",
                                    "Teacher",
                                    "Helper",
                                    "Accountant",
                                    "Staff",
                                    "Admin",
                                    "Transport Incharge",
                                    "Driver",
                                    "Reception",
                                    "Guard",
                                  ];
                                  if (staffRoles.contains(selectedClass)) {
                                    return;
                                  }

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) =>
                                            di.sl<UserDetailCubit>(),
                                        child: UserDetailPage(
                                          student: student,
                                          staff: widget.staff,
                                        ),
                                      ),
                                    ),
                                  );
                                  if (mounted) {
                                    _onSearchPressed(context);
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 45,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Hero(
                                                tag:
                                                    'avatar_${student.cdiaryId}',
                                                child:
                                                    student.studentImage !=
                                                            null &&
                                                        student
                                                            .studentImage!
                                                            .isNotEmpty &&
                                                        !student.studentImage!
                                                            .contains("None")
                                                    ? Image.network(
                                                        student.studentImage!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (c, e, s) => Icon(
                                                              Icons.person,
                                                              size: 24,
                                                              color: Theme.of(
                                                                context,
                                                              ).primaryColor,
                                                            ),
                                                      )
                                                    : Icon(
                                                        Icons.person,
                                                        size: 24,
                                                        color: Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                      ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student.name ?? "NA",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 14,
                                                    color: Color(0xFF1A1C1E),
                                                  ),
                                                ),
                                                Text(
                                                  "${student.className ?? ""} • ${student.section ?? ""}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _compactBadge(
                                            "Enroll No: ${student.enrollNumber ?? "NA"}",
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      indent: 12,
                                      endIndent: 12,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          _compactInfo(
                                            Icons.cake_rounded,
                                            student.dob ?? "NA",
                                          ),
                                          const SizedBox(height: 6),
                                          _compactInfo(
                                            Icons.family_restroom_rounded,
                                            "Father: ${student.fatherName ?? "NA"}  |  Mother: ${student.motherName ?? "NA"}",
                                          ),
                                          const SizedBox(height: 6),
                                          _compactInfo(
                                            Icons.phone_rounded,
                                            "${student.contactNumber ?? "NA"} / ${student.alternateNumber ?? "NA"}",
                                            canCopy: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              bottom: Radius.circular(16),
                                            ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.lock_person_rounded,
                                            size: 14,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            "Pass:",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            student.password ?? "NA",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF1A1C1E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                else if (state is StudentRecordError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Text(
                        "Enter filters and tap Search.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            );
          },
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A1C1E),
                    ),
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
          widget.staff.assignClass ??
          widget.staff.designation ??
          "", // staffc maps to assignClass (or designation/class)
      inschool: selectedStatus == "Yes" ? "School Status - Yes" : "No",
      session: selectedSession,
      classValue: selectedClass,
      profession: selectedClass, // Profession same as class in dropdown
      section: selectedSection,
      transportstatus: selectedTransport,
    );
  }

  Widget _compactBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _compactInfo(IconData icon, String value, {bool canCopy = false}) {
    final bool isPhone = icon == Icons.phone_rounded;

    return Builder(
      builder: (context) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (isPhone && value != "NA") {
                    final numbers = value
                        .split('/')
                        .map((e) => e.trim())
                        .toList();
                    if (numbers.length > 1) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: numbers
                                .map(
                                  (num) => ListTile(
                                    leading: const Icon(Icons.call),
                                    title: Text("Call $num"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      launchUrl(Uri.parse('tel:$num'));
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      );
                    } else if (numbers.isNotEmpty) {
                      launchUrl(Uri.parse('tel:${numbers[0]}'));
                    }
                  } else if (canCopy && value != "NA") {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Copied: $value")));
                  }
                },
                onLongPress: () {
                  if (value != "NA") {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Copied: $value")));
                  }
                },
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPhone
                        ? Theme.of(context).primaryColor
                        : const Color(0xFF495057),
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
