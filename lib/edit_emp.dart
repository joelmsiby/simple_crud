import 'package:flutter/material.dart';
import 'package:simple_crud/emp.dart';
import 'package:simple_crud/my_database.dart';
import 'package:simple_crud/home.dart';
import 'package:simple_crud/utils.dart';
import 'package:flutter/services.dart';

class EditEmp extends StatefulWidget {
  final MyDatabase myDatabase;
  final Employee employee;

  const EditEmp({super.key, required this.employee, required this.myDatabase});

  @override
  State<EditEmp> createState() => _EditEmpState();
}

class _EditEmpState extends State<EditEmp> with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late final FocusNode _emailFocusNode = FocusNode();
  late final FocusNode _contFocusNode = FocusNode();

  late final TextEditingController nameController = TextEditingController();
  late final TextEditingController addController = TextEditingController();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController contController = TextEditingController();
  late final TextEditingController dateController = TextEditingController();
  DateTime? selectedDate;

  bool isFormValid = false;
  bool _showErrors = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  void validateForm() {
    final name = nameController.text.trim();
    final address = addController.text.trim();
    final email = emailController.text.trim();
    final contact = contController.text.trim();
    final date = dateController.text.trim();

    final currentlyValid =
        name.isNotEmpty &&
        address.isNotEmpty &&
        isValidEmail(email) &&
        isValidContact(contact) &&
        date.isNotEmpty;

    setState(() {
      isFormValid = currentlyValid;
    });
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(message)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.year}-${picked.month}-${picked.day}";
        validateForm();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    validateForm();

    nameController.text = widget.employee.empName;
    addController.text = widget.employee.empAddr;
    emailController.text = widget.employee.empEmail;
    contController.text = widget.employee.empContact;
    dateController.text = widget.employee.insertDate;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.addListener(() {
        if (_emailFocusNode.hasFocus) {
          final email = emailController.text.trim();
          if (email.isNotEmpty && !isValidEmail(email)) {
            showErrorSnackBar('Invalid email format');
          }
        }
      });

      _contFocusNode.addListener(() {
        if (_contFocusNode.hasFocus) {
          final contact = contController.text.trim();
          if (contact.isNotEmpty && !isValidContact(contact)) {
            showErrorSnackBar('Invalid contact number');
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _emailFocusNode.dispose();
    _contFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Employee'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              focusNode: _focusNode,
              controller: nameController,
              maxLength: 25,
              decoration: InputDecoration(
                hintText: 'Employee Name',
                border: const OutlineInputBorder(),
                errorText: _showErrors && nameController.text.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),
              onChanged: (_) => validateForm(),
            ),
            TextField(
              controller: addController,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Employee Address',
                border: const OutlineInputBorder(),
                errorText: _showErrors && addController.text.trim().isEmpty
                    ? 'Address is required'
                    : null,
              ),
              onChanged: (_) => validateForm(),
            ),
            TextField(
              focusNode: _emailFocusNode,
              controller: emailController,
              maxLength: 150,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Employee Email',
                border: const OutlineInputBorder(),
                errorText: _showErrors && emailController.text.trim().isEmpty
                    ? 'Email is required'
                    : null,
              ),
              onChanged: (_) => validateForm(),
              onSubmitted: (_) {
                validateForm();
                if (!isValidEmail(emailController.text.trim())) {
                  showErrorSnackBar('Invalid email format');
                }
              },
            ),
            TextField(
              focusNode: _contFocusNode,
              controller: contController,
              maxLength: 10,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Employee Contact',
                border: const OutlineInputBorder(),
                errorText: _showErrors && contController.text.trim().isEmpty
                    ? 'Contact is required'
                    : null,
              ),
              onChanged: (_) => validateForm(),
            ),
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                hintText: 'Date of Insert',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
                errorText: _showErrors && dateController.text.trim().isEmpty
                    ? 'Date is required'
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (!isFormValid) {
                      setState(() {
                        _showErrors = true;
                      });
                      validateForm();
                      _shakeController.forward();
                      showErrorSnackBar(
                        'Please fill out all fields before updating.',
                      );
                    }
                  },
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    ),
                    child: AbsorbPointer(
                      absorbing: !isFormValid,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isFormValid ? Colors.orange : Colors.grey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          onPressed: isFormValid
                              ? () async {
                                  if (!isValidEmail(emailController.text)) {
                                    showErrorSnackBar(
                                      'Please enter a valid email',
                                    );
                                    return;
                                  }
                                  if (!isValidContact(contController.text)) {
                                    showErrorSnackBar(
                                      'Please enter a valid contact',
                                    );
                                    return;
                                  }

                                  final employee = Employee(
                                    empName: nameController.text,
                                    empAddr: addController.text,
                                    empEmail: emailController.text,
                                    empContact: contController.text,
                                    insertDate: dateController.text,
                                  );

                                  final isMounted = mounted;
                                  await widget.myDatabase.updateEmp(employee);

                                  if (isMounted && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.orange[700],
                                        content: Text(
                                          '${employee.empName} updated.',
                                        ),
                                      ),
                                    );
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HomePage(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                }
                              : () => _shakeController.forward(),
                          child: const Text('Update'),
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent[100],
                  ),
                  onPressed: () {
                    nameController.clear();
                    addController.clear();
                    emailController.clear();
                    contController.clear();
                    dateController.clear();
                    selectedDate = null;

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    _shakeController.reset();

                    setState(() {
                      _showErrors = false;
                    });

                    validateForm();
                    _focusNode.requestFocus();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
