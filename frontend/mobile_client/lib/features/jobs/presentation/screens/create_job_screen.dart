import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/jobs_provider.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _type = 'Full-time';
  bool _submitting = false;

  static const _types = ['Full-time', 'Part-time', 'Internship', 'Contract', 'Remote'];

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _companyCtrl.dispose(); _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await ref.read(jobsProvider.notifier).createJob(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      type: _type,
    );
    if (mounted) {
      setState(() => _submitting = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job listing created!')));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create job')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Job Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Job Title', prefixIcon: Icon(Icons.work_outline)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a job title' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _companyCtrl,
                decoration: const InputDecoration(labelText: 'Company', prefixIcon: Icon(Icons.business_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter company name' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter location' : null),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Job Type', prefixIcon: Icon(Icons.category_outlined)),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) { if (v != null) setState(() => _type = v); }),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined)),
                validator: (v) => (v == null || v.trim().length < 20) ? 'Description too short' : null),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 22, width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
