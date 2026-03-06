import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/jobs_provider.dart';

class ApplyJobScreen extends ConsumerStatefulWidget {
  final int jobId;
  const ApplyJobScreen({super.key, required this.jobId});

  @override
  ConsumerState<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends ConsumerState<ApplyJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverLetterCtrl = TextEditingController();
  final _resumeUrlCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _coverLetterCtrl.dispose();
    _resumeUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await ref.read(jobsProvider.notifier).applyToJob(
      widget.jobId,
      _coverLetterCtrl.text.trim(),
      _resumeUrlCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _submitting = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit application')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Submit your Application',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              TextFormField(
                controller: _resumeUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'Resume URL',
                  hintText: 'https://example.com/your-resume.pdf',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter resume URL' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coverLetterCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Cover Letter',
                  hintText: 'Tell us about yourself and why you\'re a great fit...',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 20) ? 'Cover letter must be at least 20 characters' : null,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
