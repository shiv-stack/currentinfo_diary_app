import 'package:current_diary_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';


class SchoolCodePage extends StatefulWidget {
  const SchoolCodePage({super.key});

  @override
  State<SchoolCodePage> createState() => _SchoolCodePageState();
}

class _SchoolCodePageState extends State<SchoolCodePage> {

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CURRENT DIARY")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Success")),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Enter School Code",
                  ),
                ),
                const SizedBox(height: 30),
                if (state is AuthLoading)
                  const CircularProgressIndicator()
                else
                  PrimaryButton(
                    title: "SUBMIT",
                    onPressed: () {
                      context.read<AuthBloc>().add(
                          SubmitSchoolCode(controller.text));
                    },
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(SkipPressed());
                  },
                  child: const Text("SKIP"),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}