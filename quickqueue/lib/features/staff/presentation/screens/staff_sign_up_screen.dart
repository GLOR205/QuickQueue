import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/failures.dart';
import '../../../location/domain/entities/location_entity.dart';
import '../../../location/domain/usecases/get_locations.dart';
import '../../domain/entities/staff_queue_option.dart';
import '../../domain/usecases/get_staff_queue_options.dart';
import '../../domain/usecases/sign_up_staff.dart';
import '../widgets/staff_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'queue_dashboard_screen.dart';

/// Staff self sign-up: creates the Firebase Auth account and the matching
/// `staff/{uid}` Firestore doc together, deriving `locationName`/
/// `counterLabel` from the location/queue the staff member picks rather
/// than free-typing them.
class StaffSignUpScreen extends StatefulWidget {
  const StaffSignUpScreen({super.key});

  @override
  State<StaffSignUpScreen> createState() => _StaffSignUpScreenState();
}

class _StaffSignUpScreenState extends State<StaffSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _loadingLocations = true;
  bool _loadingQueues = false;
  List<LocationEntity> _locations = const [];
  List<StaffQueueOption> _queueOptions = const [];
  LocationEntity? _selectedLocation;
  StaffQueueOption? _selectedQueue;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    final locations = await sl<GetLocations>()();
    if (!mounted) return;
    setState(() {
      _locations = locations;
      _loadingLocations = false;
    });
  }

  Future<void> _onLocationChanged(LocationEntity? location) async {
    setState(() {
      _selectedLocation = location;
      _selectedQueue = null;
      _queueOptions = const [];
      _loadingQueues = location != null;
    });
    if (location == null) return;
    final queues = await sl<GetStaffQueueOptions>()(location.id);
    if (!mounted) return;
    setState(() {
      _queueOptions = queues;
      _loadingQueues = false;
    });
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedLocation == null || _selectedQueue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location and queue.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final staff = await sl<SignUpStaff>()(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        locationId: _selectedLocation!.id,
        locationName: _selectedLocation!.name,
        queueId: _selectedQueue!.id,
        counterLabel: _selectedQueue!.counterLabel,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => QueueDashboardScreen(staff: staff)),
        (route) => false,
      );
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StaffColors.themeData,
      child: Scaffold(
        backgroundColor: StaffColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back,
                            size: 16, color: StaffColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'Back to staff login',
                          style: TextStyle(
                              color: StaffColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Staff sign up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: StaffColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create your staff account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: StaffColors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full name',
                    icon: Icons.badge_outlined,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Enter your name'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'staff@hospital.rw',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Enter your email'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 6)
                        ? 'At least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _DropdownField<LocationEntity>(
                    label: 'Location',
                    hint: _loadingLocations
                        ? 'Loading locations...'
                        : 'Select your location',
                    value: _selectedLocation,
                    items: _locations,
                    itemLabel: (location) => location.name,
                    onChanged: _loadingLocations ? null : _onLocationChanged,
                  ),
                  const SizedBox(height: 16),
                  _DropdownField<StaffQueueOption>(
                    label: 'Queue',
                    hint: _selectedLocation == null
                        ? 'Select a location first'
                        : (_loadingQueues
                            ? 'Loading queues...'
                            : 'Select your queue'),
                    value: _selectedQueue,
                    items: _queueOptions,
                    itemLabel: (queue) => queue.name,
                    onChanged: (_selectedLocation == null || _loadingQueues)
                        ? null
                        : (queue) => setState(() => _selectedQueue = queue),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: _isSubmitting ? 'Creating account...' : 'Sign up',
                    onPressed: _isSubmitting ? null : _signUp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: StaffColors.textSecondary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(hint,
              style:
                  const TextStyle(color: StaffColors.textMuted, fontSize: 14)),
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item),
                      style: const TextStyle(
                          fontSize: 15, color: StaffColors.textPrimary)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: StaffColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StaffColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: StaffColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: StaffColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
