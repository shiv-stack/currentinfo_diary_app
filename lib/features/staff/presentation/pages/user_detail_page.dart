import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../student/data/models/student_model.dart';
import '../../domain/entities/staff.dart';
import '../bloc/user_detail_cubit.dart';
import '../bloc/user_detail_state.dart';

class UserDetailPage extends StatefulWidget {
  final StudentModel student;
  final Staff staff;
  const UserDetailPage({super.key, required this.student, required this.staff});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  bool _isEditing = false;
  final Map<String, TextEditingController> _ctrl = {};
  late TextEditingController _otherNationalityCtrl;

  final List<String> _classList = [
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

  final List<String> _sectionList = [
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
  ];

  final List<String> _transportList = [
    "No",
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

  final List<String> _professionList = [
    "Chairman",
    "Teacher",
    "Student",
    "Vice-Principal",
    "Principal",
    "Director",
    "Helper",
    "Accountant",
    "Staff",
    "Driver",
    "Admin",
  ];

  final List<String> _religionList = [
    "Hindu",
    "Muslim",
    "Sikh",
    "Christian",
    "Bhudism",
  ];
  final List<String> _yesNoList = ["Yes", "No"];
  final List<String> _nationalityList = ["INDIAN", "Others"];
  final List<String> _categoryList = ["General", "SC", "ST", "OBC"];

  StudentModel get s => widget.student;
  Staff get staff => widget.staff;

  @override
  void initState() {
    super.initState();
    _otherNationalityCtrl = TextEditingController();
    _initCtrl();
  }

  void _initCtrl() {
    void add(String k, String? v) => _ctrl[k] = TextEditingController(text: v);
    add('name', s.name);
    String? dobStr = s.dob;
    if (dobStr != null &&
        dobStr.isNotEmpty &&
        dobStr != "NA" &&
        dobStr != "null" &&
        dobStr != "NOT PROVIDED") {
      try {
        if (dobStr.contains('/')) {
          final parts = dobStr.split('/');
          if (parts.length == 3) {
            final year = int.parse(parts[2]);
            final month = int.parse(parts[1]);
            final day = int.parse(parts[0]);
            if (year < 1900 ||
                year > 2100 ||
                month < 1 ||
                month > 12 ||
                day < 1 ||
                day > 31) {
              dobStr = "";
            } else {
              DateTime(year, month, day); // Ensure valid
            }
          } else {
            dobStr = "";
          }
        } else if (dobStr.contains('-')) {
          DateTime.parse(dobStr);
        } else {
          dobStr = "";
        }
      } catch (_) {
        dobStr = "";
      }
    } else {
      dobStr = "";
    }
    add('dob', dobStr);
    add('fatherName', s.fatherName);
    add('motherName', s.motherName);
    add('profession', s.profession);
    add('className', s.className);
    add('section', s.section);
    add('enrollNumber', s.enrollNumber);
    add('contactNumber', s.contactNumber);
    add('alternateNumber', s.alternateNumber);
    add('email', s.email);
    add('address', s.address);
    add('password', s.password);
    add('cdiaryId', s.cdiaryId);

    // Fields from rawJson needed for API
    final raw = s.rawJson ?? {};

    // Prioritize bus_number as the actual bus ID, fallback to transport
    String? transportValue = raw['bus_number']?.toString();
    if (transportValue == null ||
        transportValue.isEmpty ||
        transportValue == "NA" ||
        transportValue == "null") {
      transportValue = raw['transport']?.toString();
    }

    if (transportValue != null &&
        transportValue.startsWith("Bus") &&
        transportValue.endsWith("No")) {
      transportValue =
          transportValue.substring(0, transportValue.length - 2) + "N";
    }
    add('transport', transportValue);

    final nat = raw['nationality']?.toString() ?? "";
    if (nat.toUpperCase() != "INDIAN" &&
        nat.isNotEmpty &&
        nat != "NA" &&
        nat != "null") {
      _ctrl['nationality'] = TextEditingController(text: "Others");
      _otherNationalityCtrl.text = nat;
    } else {
      add('nationality', nat);
    }

    add('religion', raw['religion']?.toString());

    String? g = raw['gender']?.toString();
    if (g?.toUpperCase() == 'M') {
      g = 'Male';
    } else if (g?.toUpperCase() == 'F')
      g = 'Female';
    add('gender', g);

    add('category', raw['category']?.toString());
    add('bloodgroup', raw['bloodgroup']?.toString());
    add('rfid', raw['rfid']?.toString());
    add('adharNumber', raw['adhar_number']?.toString());
    add('height', raw['height']?.toString());
    add('weight', raw['weight']?.toString());
    add('doa', raw['doa']?.toString());
    add('guardian', raw['guardian']?.toString());
    add('srnumber', raw['srnumber']?.toString());
    add('rollno', raw['r_num']?.toString());
    add('busNumber', raw['bus_number']?.toString());
    add('schoolhouse', raw['schoolhouse']?.toString());
    add('nccscout', raw['nccscout']?.toString());
    add('oldnewadmission', raw['oldnewadmission']?.toString());
    add('message', raw['message']?.toString());
    add('lastschool', raw['lastschool']?.toString());
    add('lastclass', raw['lastclass']?.toString());
    add('tcissued', raw['tcissued']?.toString());
    add('tcissueddate', raw['tcissueddate']?.toString());
    add('penNumber', raw['pen_number']?.toString());
    add('registration', raw['regis_num']?.toString());
    add('rte', raw['right_to_education']?.toString());
    String? inSch =
        raw['inschool']?.toString() ?? raw['status_value']?.toString();
    if (inSch != null) {
      final low = inSch.toLowerCase();
      if (low == "yes" || low.contains("status - yes")) {
        inSch = "Yes";
      } else if (low == "no" || low.contains("unsubscribe")) {
        inSch = "No";
      } else {
        inSch = "Yes";
      }
    } else {
      inSch = "Yes";
    }
    add('inschool', inSch);
    add('familyId', raw['family_id']?.toString());

    for (final d in _dynItems()) {
      add('dyn_${d.key}', d.value);
    }
  }

  @override
  void dispose() {
    _otherNationalityCtrl.dispose();
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _val(String key) {
    final t = _ctrl[key]?.text.trim() ?? "";
    return (t.isEmpty || t == "NA" || t == "null" || t == "NOT PROVIDED")
        ? "N/A"
        : t;
  }

  @override
  Widget build(BuildContext context) {
    final pc = Theme.of(context).primaryColor;
    final dynItems = _dynItems();

    return BlocListener<UserDetailCubit, UserDetailState>(
      listener: (context, state) {
        if (state is UserDetailUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          setState(() => _isEditing = false);
        } else if (state is UserDetailUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${state.message}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<UserDetailCubit, UserDetailState>(
        builder: (context, state) {
          final isSaving = state is UserDetailLoading;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F6FA),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (_isEditing) {
                          final name = _ctrl['name']?.text.trim() ?? '';
                          if (name.length < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Name must be at least 5 characters long",
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          context.read<UserDetailCubit>().updateRecord(
                            schoolCode: staff.schoolCode ?? '',
                            staffLogin: staff.name ?? '',
                            staffPass: staff.password ?? '',
                            staffClass: staff.assignClass ?? '',
                            fields: {
                              'cdiaryid': _ctrl['cdiaryId']?.text ?? '',
                              'name': _ctrl['name']?.text ?? '',
                              'transport': _ctrl['transport']?.text ?? 'NA',
                              'lastclass': _ctrl['lastclass']?.text ?? '',
                              'email': _ctrl['email']?.text ?? '',
                              'tcissued': _ctrl['tcissued']?.text ?? 'No',
                              'tcissueddate': _ctrl['tcissueddate']?.text ?? '',
                              'pen_number': _ctrl['penNumber']?.text ?? '',
                              'nccscout': _ctrl['nccscout']?.text ?? 'No',
                              'rollno': _ctrl['rollno']?.text ?? '',
                              'registration': _ctrl['registration']?.text ?? '',
                              'schoolhouse': _ctrl['schoolhouse']?.text ?? '',
                              'busno': _ctrl['transport']?.text ?? 'NA',
                              'password': _ctrl['password']?.text ?? '',
                              'class': _ctrl['className']?.text ?? '',
                              'section': _ctrl['section']?.text ?? '',
                              'doa': _ctrl['doa']?.text ?? '',
                              'religion': _ctrl['religion']?.text ?? '',
                              'oldnewadmission':
                                  _ctrl['oldnewadmission']?.text ?? 'Old',
                              'message': _ctrl['message']?.text ?? '',
                              'alternatenumber':
                                  _ctrl['alternateNumber']?.text ?? '',
                              'adhar': _ctrl['adharNumber']?.text ?? '',
                              'srnumber': _ctrl['srnumber']?.text ?? '',
                              'family_id': _ctrl['familyId']?.text ?? '',
                              'enroll': _ctrl['enrollNumber']?.text ?? '',
                              'dob': _ctrl['dob']?.text ?? '',
                              'mobile': _ctrl['contactNumber']?.text ?? '',
                              'father': _ctrl['fatherName']?.text ?? '',
                              'rfid': _ctrl['rfid']?.text ?? '',
                              'height': _ctrl['height']?.text ?? '',
                              'weight': _ctrl['weight']?.text ?? '',
                              'bloodgroup': _ctrl['bloodgroup']?.text ?? '',
                              'mother': _ctrl['motherName']?.text ?? '',
                              'address': _ctrl['address']?.text ?? '',
                              'lastschool': _ctrl['lastschool']?.text ?? '',
                              'guardian': _ctrl['guardian']?.text ?? '',
                              'inschool': _ctrl['inschool']?.text ?? 'Yes',
                              'gender': _ctrl['gender']?.text ?? '',
                              'rte': _ctrl['rte']?.text ?? 'No',
                              'category': _ctrl['category']?.text ?? 'General',
                              'profession':
                                  _ctrl['profession']?.text ?? 'Student',
                              'nationality':
                                  _ctrl['nationality']?.text == 'Others'
                                  ? _otherNationalityCtrl.text
                                  : _ctrl['nationality']?.text ?? '',
                            },
                          );
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                backgroundColor: isSaving
                    ? Colors.grey
                    : (_isEditing ? Colors.green : pc),
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                        color: Colors.white,
                      ),
                label: Text(
                  isSaving ? "SAVING..." : (_isEditing ? "SAVE" : "EDIT"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── HEADER with centered image ──
                  SliverToBoxAdapter(child: _buildProfileHeader(context, pc)),
                  // ── ALL TILES in one scroll ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _sectionLabel("PERSONAL"),
                        _tile(
                          Icons.cake_rounded,
                          "Date of Birth",
                          "dob",
                          Colors.blue,
                          isDate: true,
                        ),
                        _tile(
                          Icons.face_rounded,
                          "Father's Name",
                          "fatherName",
                          Colors.indigo,
                        ),
                        _tile(
                          Icons.face_3_rounded,
                          "Mother's Name",
                          "motherName",
                          Colors.pink,
                        ),
                        _tile(
                          Icons.work_rounded,
                          "Profession",
                          "profession",
                          Colors.purple,
                          options: _professionList,
                        ),
                        _tile(
                          Icons.class_rounded,
                          "Class",
                          "className",
                          Colors.orange,
                          options: _classList,
                        ),
                        _tile(
                          Icons.grid_view_rounded,
                          "Section",
                          "section",
                          Colors.orange,
                          options: _sectionList,
                        ),
                        _tile(
                          Icons.numbers_rounded,
                          "Enrollment No",
                          "enrollNumber",
                          Colors.teal,
                        ),
                        const SizedBox(height: 8),
                        _sectionLabel("CONTACT & SECURITY"),
                        _tile(
                          Icons.phone_rounded,
                          "Contact Number",
                          "contactNumber",
                          Colors.green,
                          isPhone: true,
                        ),
                        _tile(
                          Icons.phone_android_rounded,
                          "Alternate Number",
                          "alternateNumber",
                          Colors.green,
                          isPhone: true,
                        ),
                        _tile(
                          Icons.lock_rounded,
                          "Password",
                          "password",
                          Colors.amber,
                        ),
                        _tile(
                          Icons.email_rounded,
                          "Email",
                          "email",
                          Colors.blueGrey,
                        ),
                        _tile(
                          Icons.home_rounded,
                          "Address",
                          "address",
                          Colors.red,
                        ),
                        _tile(
                          Icons.badge_rounded,
                          "CDiary ID",
                          "cdiaryId",
                          Colors.cyan,
                        ),
                        const SizedBox(height: 8),
                        _sectionLabel("ACADEMIC & PERSONAL"),
                        _tile(
                          Icons.wc_rounded,
                          "Gender",
                          "gender",
                          Colors.deepPurple,
                          options: ['Male', 'Female'],
                        ),
                        _tile(
                          Icons.temple_hindu_rounded,
                          "Religion",
                          "religion",
                          Colors.brown,
                          options: _religionList,
                        ),
                        _tile(
                          Icons.public_rounded,
                          "Nationality",
                          "nationality",
                          Colors.blue,
                          options: _nationalityList,
                        ),
                        _tile(
                          Icons.category_rounded,
                          "Category",
                          "category",
                          Colors.deepOrange,
                          options: _categoryList,
                        ),
                        _tile(
                          Icons.water_drop_rounded,
                          "Blood Group",
                          "bloodgroup",
                          Colors.red,
                        ),
                        _tile(
                          Icons.height_rounded,
                          "Height",
                          "height",
                          Colors.teal,
                        ),
                        _tile(
                          Icons.monitor_weight_rounded,
                          "Weight",
                          "weight",
                          Colors.teal,
                        ),
                        _tile(
                          Icons.nfc_rounded,
                          "RFID",
                          "rfid",
                          Colors.blueGrey,
                        ),
                        _tile(
                          Icons.credit_card_rounded,
                          "Aadhaar No",
                          "adharNumber",
                          Colors.indigo,
                        ),
                        _tile(
                          Icons.calendar_month_rounded,
                          "Date of Admission",
                          "doa",
                          Colors.purple,
                        ),
                        _tile(
                          Icons.format_list_numbered_rounded,
                          "Roll Number",
                          "rollno",
                          Colors.amber,
                        ),
                        _tile(
                          Icons.document_scanner_rounded,
                          "SR Number",
                          "srnumber",
                          Colors.grey,
                        ),
                        _tile(
                          Icons.class_rounded,
                          "Last Class Studied",
                          "lastclass",
                          Colors.indigo,
                          options: _classList,
                        ),
                        _tile(
                          Icons.assignment_ind_rounded,
                          "Guardian",
                          "guardian",
                          Colors.brown,
                        ),
                        const SizedBox(height: 8),
                        _sectionLabel("TRANSPORT & MISC"),
                        _tile(
                          Icons.directions_bus_rounded,
                          "Bus Number",
                          "transport",
                          Colors.green,
                          options: _transportList,
                        ),
                        _tile(
                          Icons.house_rounded,
                          "School House",
                          "schoolhouse",
                          Colors.orange,
                        ),
                        _tile(
                          Icons.military_tech_rounded,
                          "NCC/Scout",
                          "nccscout",
                          Colors.amber,
                        ),
                        _tile(
                          Icons.swap_horiz_rounded,
                          "Old/New Admission",
                          "oldnewadmission",
                          Colors.purple,
                        ),
                        _tile(
                          Icons.policy_rounded,
                          "RTE",
                          "rte",
                          Colors.blue,
                          options: _yesNoList,
                        ),
                        _tile(
                          Icons.school_rounded,
                          "In School",
                          "inschool",
                          Colors.green,
                          options: _yesNoList,
                        ),
                        _tile(
                          Icons.description_rounded,
                          "TC Issued",
                          "tcissued",
                          Colors.redAccent,
                          options: _yesNoList,
                        ),
                        _tile(
                          Icons.calendar_today_rounded,
                          "TC Issued Date",
                          "tcissueddate",
                          Colors.redAccent,
                        ),
                        _tile(
                          Icons.family_restroom_rounded,
                          "Family ID",
                          "familyId",
                          Colors.pink,
                        ),
                        if (dynItems.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _sectionLabel("MORE DETAILS"),
                          ...dynItems.map(
                            (d) => _tile(
                              Icons.label_important_rounded,
                              d.label,
                              'dyn_${d.key}',
                              Colors.grey,
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE HEADER – image on top, name & stats in a card overlapping bottom
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProfileHeader(BuildContext context, Color pc) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [pc, pc.withValues(alpha: 0.7)],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
        ),
        // Profile card that overlaps
        Positioned(
          left: 24,
          right: 24,
          top: 120,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Name
                _isEditing
                    ? TextField(
                        controller: _ctrl['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1C1E),
                        ),
                        decoration: InputDecoration(
                          hintText: "Full Name",
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: pc, width: 2),
                          ),
                        ),
                      )
                    : Text(
                        _val('name'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1C1E),
                          letterSpacing: -0.3,
                        ),
                      ),
                const SizedBox(height: 6),
                // Subtitle chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (_val('profession').isNotEmpty)
                      _chip(_val('profession'), pc),
                    if (_val('className').isNotEmpty)
                      _chip(_val('className'), pc),
                    if (_val('section').isNotEmpty) _chip(_val('section'), pc),
                  ],
                ),
                const SizedBox(height: 16),
                // Quick stats row
                Row(
                  children: [
                    _quickStat("ID", _val('cdiaryId'), pc),
                    _vertDivider(),
                    _quickStat("Enrollment", _val('enrollNumber'), pc),
                    _vertDivider(),
                    _quickStat("Password", _val('password'), pc),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Avatar – centered on top of the card
        Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Hero(
              tag: 'avatar_${s.cdiaryId}',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _hasImage
                      ? Image.network(
                          s.studentImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(pc),
                        )
                      : _placeholder(pc),
                ),
              ),
            ),
          ),
        ),
        // Spacer to push content below the card
        SizedBox(height: 340),
        // Back button – on top of everything
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get _hasImage =>
      s.studentImage != null &&
      s.studentImage!.isNotEmpty &&
      !s.studentImage!.contains("None") &&
      !s.studentImage!.endsWith("media/");

  Widget _placeholder(Color pc) {
    return Container(
      color: pc.withValues(alpha: 0.15),
      child: Icon(Icons.person_rounded, size: 40, color: pc),
    );
  }

  Widget _chip(String text, Color pc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: pc.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: pc, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _quickStat(String label, String value, Color pc) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _copy(context, value),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: pc,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vertDivider() {
    return Container(width: 1, height: 28, color: Colors.grey.shade100);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION LABEL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10, left: 4),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(height: 1, color: Colors.grey.shade200)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TILE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _tile(
    IconData icon,
    String label,
    String key,
    Color color, {
    bool isPhone = false,
    bool isDate = false,
    List<String>? options,
  }) {
    final val = _val(key);
    final ctrl = _ctrl[key];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _isEditing && ctrl != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              options != null
                                  ? DropdownButtonFormField<String>(
                                      value: options.contains(ctrl.text)
                                          ? ctrl.text
                                          : null,
                                      dropdownColor: Colors.white,
                                      items: options
                                          .map(
                                            (o) => DropdownMenuItem(
                                              value: o,
                                              child: Text(o),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        setState(() {
                                          ctrl.text = v ?? "";
                                        });
                                      },
                                      style: const TextStyle(
                                        color: Color(0xFF1A1C1E),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: color,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    )
                                  : TextField(
                                      controller: ctrl,
                                      readOnly: isDate,
                                      onTap: isDate
                                          ? () async {
                                              DateTime? initialDate;
                                              try {
                                                if (ctrl.text.isNotEmpty &&
                                                    ctrl.text != "NA") {
                                                  if (ctrl.text.contains('/')) {
                                                    final parts = ctrl.text
                                                        .split('/');
                                                    if (parts.length == 3) {
                                                      initialDate = DateTime(
                                                        int.parse(parts[2]),
                                                        int.parse(parts[1]),
                                                        int.parse(parts[0]),
                                                      );
                                                    }
                                                  } else {
                                                    initialDate =
                                                        DateTime.tryParse(
                                                          ctrl.text,
                                                        );
                                                  }
                                                }
                                              } catch (_) {}
                                              final picked =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        initialDate ??
                                                        DateTime.now(),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime.now()
                                                        .add(
                                                          const Duration(
                                                            days: 365,
                                                          ),
                                                        ),
                                                  );
                                              if (picked != null) {
                                                final d =
                                                    "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                                                setState(() => ctrl.text = d);
                                              }
                                            }
                                          : null,
                                      style: const TextStyle(
                                        color: Color(0xFF1A1C1E),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: color,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                              if (key == 'nationality' && ctrl.text == 'Others')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TextField(
                                    controller: _otherNationalityCtrl,
                                    style: const TextStyle(
                                      color: Color(0xFF1A1C1E),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter Nationality",
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: color,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () => _onTap(context, val, isPhone),
                            onLongPress: () => _copy(context, val),
                            child: Text(
                              val,
                              style: TextStyle(
                                color: isPhone && val != "N/A"
                                    ? Theme.of(context).primaryColor
                                    : const Color(0xFF1A1C1E),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void _onTap(BuildContext ctx, String val, bool isPhone) {
    if (val == "N/A") return;
    if (isPhone) {
      final nums = val
          .split('/')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (nums.length > 1) {
        showModalBottomSheet(
          context: ctx,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ...nums.map(
                  (n) => ListTile(
                    leading: const Icon(
                      Icons.call_rounded,
                      color: Colors.green,
                    ),
                    title: Text(
                      n,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      launchUrl(Uri.parse('tel:$n'));
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      } else {
        launchUrl(Uri.parse('tel:${nums[0]}'));
      }
    } else {
      _copy(ctx, val);
    }
  }

  void _copy(BuildContext ctx, String val) {
    if (val == "N/A") return;
    Clipboard.setData(ClipboardData(text: val));
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text("Copied: $val"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DYNAMIC ITEMS
  // ═══════════════════════════════════════════════════════════════════════════

  List<_DynItem> _dynItems() {
    if (s.rawJson == null) return [];
    const skip = {
      'Name',
      'gender',
      'dob',
      'dateofbirth',
      'Father',
      'Mother',
      'religion',
      'category',
      'bloodgroup',
      'nationality',
      'Profession',
      'Class',
      'class',
      'section',
      'enroll_number',
      'doa',
      'stream',
      'rfid',
      'Contact number',
      'contact_number',
      'alternatenumber',
      'email',
      'Address',
      'address',
      'adhar_number',
      'adharcard',
      'pass',
      'password',
      'cdiaryid',
      'transport',
      'bus_number',
      'busno',
      'bus_no',
      'busNumber',
      'schoolhouse',
      'status_value',
      'regis_num',
      'pen_number',
      'tcissued',
      'tcissueddate',
      'guardian',
      'record_addedon',
      'student_image',
      'thoughttitle',
      'thoughtmessage',
      'return',
      'feesoftware',
      'height',
      'weight',
      'r_num',
      'srnumber',
      'nccscout',
      'oldnewadmission',
      'message',
      'lastschool',
      'lastclass',
      'right_to_education',
      'family_id',
      'inschool',
    };
    final list = <_DynItem>[];
    s.rawJson!.forEach((key, value) {
      final v = value?.toString().trim() ?? "";
      if (!skip.contains(key) &&
          v.isNotEmpty &&
          v != "NA" &&
          v != "null" &&
          v != "NOT PROVIDED") {
        final label = key
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : "")
            .join(' ');
        list.add(_DynItem(key, label, v));
      }
    });
    return list;
  }
}

class _DynItem {
  final String key;
  final String label;
  final String value;
  _DynItem(this.key, this.label, this.value);
}
