import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../data/models/student_model.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../../injection_container.dart';

class MessagesPage extends StatefulWidget {
  final StudentModel student;

  const MessagesPage({super.key, required this.student});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final credentials =
        await sl<AuthLocalDataSource>().getActiveStudentCredentials();
    if (credentials != null) {
      if (mounted) {
        context.read<StudentBloc>().add(
          GetMessages(
            schoolCode: widget.student.schoolCode ?? "",
            studentId: widget.student.cdiaryId ?? "",
            password: credentials['password'] ?? "",
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1C21),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Personal Messages",
          style: TextStyle(
            color: Color(0xFF1A1C21),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFF000000).withValues(alpha: 0.05),
            height: 1,
          ),
        ),
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is MessagesLoading) {
            return const Center(child: AppLoadingIndicator());
          } else if (state is MessagesLoaded) {
            if (state.messages.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                return _buildMessageCard(state.messages[index]);
              },
            );
          } else if (state is MessagesFailure) {
            return _buildErrorState(state.message);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildMessageCard(dynamic message) {
    final String sender = message['sname'] ?? "Unknown";
    final String body = message['msg'] ?? "";
    final String time = message['time'] ?? "";
    final bool isSent = (message['replystatus'] ?? "reply") == "send";
    final Color accentColor =
        isSent ? const Color(0xFF3B82F6) : Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: accentColor),
              Expanded(
                child: InkWell(
                  onTap: () => _showDetails(sender, body, time, isSent),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isSent
                                    ? "TO: ${message['sendto'] ?? 'Staff'}"
                                    : sender,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Color(0xFF1A1C21),
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              time.split(' ').first,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          body,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSent ? "OUTGOING" : "INCOMING",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(String sender, String body, String time, bool isSent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailedMessageView(
        sender: sender,
        body: body,
        time: time,
        isSent: isSent,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mail_outline_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No messages found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1C21),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Private messages from your teachers\nwill appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadMessages,
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailedMessageView extends StatelessWidget {
  final String sender;
  final String body;
  final String time;
  final bool isSent;

  const _DetailedMessageView({
    required this.sender,
    required this.body,
    required this.time,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        isSent ? const Color(0xFF3B82F6) : Theme.of(context).primaryColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    sender.isNotEmpty ? sender[0].toUpperCase() : "?",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSent ? "Sent to ${sender}" : "From ${sender}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Color(0xFF1A1C21),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Text(
                body,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1C21),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "GOT IT",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
