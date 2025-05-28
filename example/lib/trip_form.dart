
import 'package:flutter/material.dart';

import 'trip.dart';

class TripFormPage extends StatefulWidget {
  const TripFormPage({Key? key}) : super(key: key);

  @override
  _TripFormPageState createState() => _TripFormPageState();
}

class _TripFormPageState extends State<TripFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial = _endDate ?? _startDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate ?? DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final trip = Trip(
        name: _nameController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip created: $trip')),
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateDates() {
    if (_startDate == null || _endDate == null) {
      return 'Please select both dates';
    }
    if (_endDate!.isBefore(_startDate!)) {
      return 'End date must be after start date';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_startDate == null
                        ? 'Start date'
                          : 'Start: ${_startDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: _pickStartDate,
                    child: const Text('Select'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(_endDate == null
                        ? 'End date'
                          : 'End: ${_endDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: _pickEndDate,
                    child: const Text('Select'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final error = _validateDates();
                  return error == null
                      ? const SizedBox.shrink()
                      : Text(error, style: TextStyle(color: Colors.red));
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
