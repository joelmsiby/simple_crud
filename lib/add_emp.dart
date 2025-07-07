import 'package:flutter/material.dart';
import 'package:simple_crud/my_database.dart';
import 'package:simple_crud/emp.dart';
import 'home.dart';
import 'package:simple_crud/utils.dart';
import 'package:flutter/services.dart';

class AddEmp extends StatefulWidget {
  final MyDatabase myDatabase;
  const AddEmp({super.key, required this.myDatabase});

  @override
  State<AddEmp> createState() => _AddEmpState();
}

class _AddEmpState extends State<AddEmp> with SingleTickerProviderStateMixin {
  //
  bool _showErrors = false;
  //
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  //
  bool isNameValid = false;
  bool isAddressValid = false;
  bool isEmailValid = false;
  bool isContactValid = false;
  bool isDateValid = false;

  @override
  void initState() {
    super.initState();
    validateForm();

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

  //
  bool isFormValid = false;
  //
  final FocusNode _focusNode = FocusNode();
  late final FocusNode _emailFocusNode = FocusNode();
  late final FocusNode _contFocusNode = FocusNode();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime? selectedDate;
  //

  void validateForm() {
    final name = nameController.text.trim();
    final address = addController.text.trim();
    final email = emailController.text.trim();
    final contact = contController.text.trim();
    final date = dateController.text.trim();

    // update form state
    setState(() {
      isNameValid = name.isNotEmpty;
      isAddressValid = address.isNotEmpty;
      isEmailValid = isValidEmail(email);
      isContactValid = isValidContact(contact);
      isDateValid = date.isNotEmpty;

      isFormValid =
          isNameValid &&
          isAddressValid &&
          isEmailValid &&
          isContactValid &&
          isDateValid;

      // show errors if user has already attempted submission
      /* if (_showErrors && !currentlyValid) {
        _showErrors = true;
      } */
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Employee'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //emp name
              TextField(
                focusNode: _focusNode,
                controller: nameController,
                autofillHints: [AutofillHints.name],
                maxLength: 25,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Employee Name',
                  border: OutlineInputBorder(),
                  errorText: _showErrors && nameController.text.trim().isEmpty
                      ? 'Name is required'
                      : null,
                  suffixIcon: isNameValid
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                onChanged: (value) => validateForm(),
                textInputAction: TextInputAction.next,
              ),
              //emp address
              TextField(
                controller: addController,
                maxLength: 150,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  hintText: 'Employee Address',
                  border: OutlineInputBorder(),
                  errorText: _showErrors && addController.text.trim().isEmpty
                      ? 'Address is required'
                      : null,
                  suffixIcon: isAddressValid
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                onChanged: (value) => validateForm(),
                textInputAction: TextInputAction.next,
              ),
              //emp email
              TextField(
                focusNode: _emailFocusNode,
                controller: emailController,
                maxLength: 150,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Employee Email',
                  border: OutlineInputBorder(),
                  errorText: _showErrors && emailController.text.trim().isEmpty
                      ? 'Email is required'
                      : null,
                  suffixIcon: isEmailValid
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                onChanged: (value) => validateForm(),
                onSubmitted: (_) {
                  validateForm();
                  if (!isValidEmail(emailController.text.trim())) {
                    showErrorSnackBar('Invalid email format');
                  }
                },
                textInputAction: TextInputAction.next,
              ),
              //emp contact
              TextField(
                focusNode: _contFocusNode,
                controller: contController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Employee Contact',
                  border: OutlineInputBorder(),
                  errorText: _showErrors && contController.text.trim().isEmpty
                      ? 'Contact is required'
                      : null,
                  suffixIcon: isContactValid
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                onChanged: (value) => validateForm(),
                textInputAction: TextInputAction.next,
              ),
              //emp date of insert
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  hintText: 'Date of Insert',
                  border: OutlineInputBorder(),
                  //suffixIcon: Icon(Icons.calendar_today),
                  errorText: _showErrors && dateController.text.trim().isEmpty
                      ? 'Date is required'
                      : null,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDateValid)
                        const Icon(Icons.check, color: Colors.green),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior
                        .translucent, // ensures it captures gestures even if child is disabled
                    onTap: () {
                      if (!isFormValid) {
                        setState(() {
                          _showErrors = true; // show error text now
                        });
                        validateForm();
                        // Trigger a shake, show a snackbar, etc
                        _shakeController.forward();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              'Please fill out all fields before adding.',
                            ),
                          ),
                        );
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _shakeAnimation.value,
                            0,
                          ), // this uses the animation!
                          child: child,
                        );
                      },
                      child: Tooltip(
                        message: isFormValid
                            ? '' // no tooltip if the form is valid
                            : 'Add employee details',
                        child: AbsorbPointer(
                          absorbing:
                              !isFormValid, // disables tap without disabling the button widget
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: isFormValid ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            //width: 100,
                            //height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: isFormValid
                                  ? () async {
                                      //
                                      if (!isValidEmail(emailController.text)) {
                                        showErrorSnackBar(
                                          'Please enter a valid email',
                                        );
                                        return;
                                      }
                                      //
                                      //
                                      if (!isValidContact(
                                        contController.text,
                                      )) {
                                        showErrorSnackBar(
                                          'Please enter a valid contact',
                                        );
                                        return;
                                      }
                                      //
                                      Employee employee = Employee(
                                        empName: nameController.text,
                                        empAddr: addController.text,
                                        empEmail: emailController.text,
                                        empContact: contController.text,
                                        insertDate: dateController.text,
                                      );

                                      // Store the state of 'mounted' before the await
                                      final isMounted = mounted;

                                      await widget.myDatabase.insertEmp(
                                        employee,
                                      );

                                      if (isMounted && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                              '${employee.empName} added',
                                            ),
                                          ),
                                        );
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                      //
                                    }
                                  : () {
                                      setState(() {
                                        _showErrors =
                                            true; // show error text now
                                      });
                                      _shakeController
                                          .forward(); // shake effect
                                      showErrorSnackBar(
                                        'Please fill out all fields before adding.',
                                      );
                                    },
                              child: const Text('Add'),
                            ),
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
                      // clear fields
                      nameController.clear();
                      addController.clear();
                      emailController.clear();
                      contController.clear();
                      dateController.clear();
                      selectedDate = null;

                      // Dismiss active SnackBars
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();

                      //Reset shake animation
                      _shakeController.reset();

                      // hide error message on reset
                      setState(() {
                        _showErrors = false;
                      });

                      // recalculate isFormValid
                      validateForm();
                      _focusNode.requestFocus(); // focus on name field
                      //
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _emailFocusNode.dispose();
    _contFocusNode.dispose();
    super.dispose();
  }
}
