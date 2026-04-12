import 'package:flutter/material.dart';
import '../../domain/entities/staff.dart';

class StaffDashboardPage extends StatelessWidget {
  final Staff staff;

  const StaffDashboardPage({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff Dashboard"),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/school-code'),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: staff.staffImage != null ? NetworkImage(staff.staffImage!) : null,
              child: staff.staffImage == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome, ${staff.name ?? 'Staff Member'}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (staff.designation != null)
              Text(
                staff.designation!,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            const SizedBox(height: 40),
            const Text("Your dashboard features are coming soon!"),
          ],
        ),
      ),
    );
  }
}
