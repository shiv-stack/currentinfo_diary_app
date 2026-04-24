import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/staff_upload_cubit.dart';
import '../bloc/staff_upload_state.dart';
import '../../domain/entities/staff.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../injection_container.dart';

class StaffUploadPage extends StatefulWidget {
  final String featureTitle;
  final Staff staff;

  const StaffUploadPage({
    super.key,
    required this.featureTitle,
    required this.staff,
  });

  @override
  State<StaffUploadPage> createState() => _StaffUploadPageState();
}

class _StaffUploadPageState extends State<StaffUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedClass;
  String? _selectedSection;

  final List<String> _classes = [
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
  ];

  final List<String> _sections = [
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

  File? _selectedFile;
  final _picker = ImagePicker();

  Future<void> _pickImageFromSource(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 30,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDocument() async {
    final result = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: [
        'pdf',
        'csv',
        'ppt',
        'pptx',
        'doc',
        'docx',
        'xls',
        'xlsx',
      ],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromSource(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Document (PDF, CSV, PPT)'),
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<StaffUploadCubit>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            widget.featureTitle,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1C1E),
          elevation: 0,
        ),
        body: BlocConsumer<StaffUploadCubit, StaffUploadState>(
          listener: (context, state) {
            if (state is StaffUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else if (state is StaffUploadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Content Details"),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _titleController,
                      label: "Title",
                      hint: "Enter title for ${widget.featureTitle}",
                      validator: (v) => v!.isEmpty ? "Title is required" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descController,
                      label: "Description",
                      hint: "Enter detailed description",
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Target Class & Section"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: "Class",
                            value: _selectedClass,
                            items: _classes,
                            onChanged: (v) =>
                                setState(() => _selectedClass = v),
                            validator: (v) => v == null ? "Required" : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: "Section",
                            value: _selectedSection,
                            items: _sections,
                            onChanged: (v) =>
                                setState(() => _selectedSection = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle("Attachment (Optional)"),
                    const SizedBox(height: 16),
                    _buildFilePicker(),
                    const SizedBox(height: 40),
                    _buildSubmitButton(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1A1C1E),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          validator: validator,
          onChanged: onChanged,
          menuMaxHeight: 300,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedFile == null
                ? Colors.grey.shade200
                : Colors.green.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedFile == null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Tap to select an image",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child:
                            _selectedFile!.path.toLowerCase().endsWith(
                                  '.pdf',
                                ) ||
                                _selectedFile!.path.toLowerCase().endsWith(
                                  '.csv',
                                ) ||
                                _selectedFile!.path.toLowerCase().endsWith(
                                  '.ppt',
                                ) ||
                                _selectedFile!.path.toLowerCase().endsWith(
                                  '.pptx',
                                ) ||
                                _selectedFile!.path.toLowerCase().endsWith(
                                  '.doc',
                                ) ||
                                _selectedFile!.path.toLowerCase().endsWith(
                                  '.docx',
                                ) ||
                                _selectedFile!.path.toLowerCase().endsWith(
                                  '.xls',
                                ) ||
                                _selectedFile!.path.toLowerCase().endsWith(
                                  '.xlsx',
                                )
                            ? Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.blue.shade50,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.description,
                                      size: 60,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedFile!.path.split('/').last,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Image.file(
                                _selectedFile!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () =>
                                setState(() => _selectedFile = null),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "File Selected",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, StaffUploadState state) {
    final isLoading = state is StaffUploadLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _submit(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "UPLOAD NOW",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final localData = sl<AuthLocalDataSource>();
      final session = await localData.getCachedSession();
      if (!mounted) return;

      // Use assignClass for Holiday Homework as per requirements
      final bool isHolidayHw = widget.featureTitle == "Holiday Homework";
      final staffc = isHolidayHw 
          ? (widget.staff.assignClass ?? _selectedClass ?? "")
          : (_selectedClass ?? "");

      context.read<StaffUploadCubit>().uploadData(
        schoolCode: widget.staff.schoolCode ?? "",
        login: widget.staff.name ?? "",
        password: widget.staff.password ?? "",
        staffClass: staffc,
        title: _titleController.text,
        description: _descController.text,
        className: _selectedClass ?? "",
        section: _selectedSection ?? "",
        session: session ?? "",
        uploadDetails:
            (widget.staff.contactNumber ?? "") + (widget.staff.name ?? ""),
        featureTitle: widget.featureTitle,
        filePath: _selectedFile?.path,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
