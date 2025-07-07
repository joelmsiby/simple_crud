Employee toEmployee(Map<String, Object?> map) => Employee.toEmp(map);

class Employee{
  final String empName;
  final String empAddr;
  final String empEmail;
  final String empContact;
  final String insertDate;
  Employee(
      {required this.empName,
        required this.empAddr,
        required this.empEmail,
        required this.empContact,
        required this.insertDate});

  // convert to map
  Map<String, dynamic> toMap() => {
    'name': empName,
    'address': empAddr,
    'email': empEmail,
    'contact': empContact,
    'date': insertDate,
  };
  // convert map to employee
  factory Employee.toEmp(Map<String, dynamic> map) => Employee(
    empName: map['name'],
    empAddr: map['address'],
    empEmail: map['email'],
    empContact: map['contact'],
    insertDate: map['date'],
  );
}