import 'package:flutter/material.dart';
import 'package:simple_crud/edit_emp.dart';
import 'package:simple_crud/emp.dart';
import 'add_emp.dart';
import 'my_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //
  bool isLoading = false;
  List<Employee> employees = List.empty(growable: true);
  //
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  //
  final MyDatabase _myDatabase = MyDatabase();
  int count = 0;

  // Search logic
  List<Employee> get filteredEmployees {
    if (searchQuery.isEmpty) return employees;
    return employees
        .where(
          (emp) =>
              emp.empName.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  // get the data when page is loaded
  Future<void> getDataFromDb() async {
    //
    await _myDatabase.initializeDatabase();
    List<Map<String, Object?>> map = await _myDatabase.getEmpList();
    for (int i = 0; i < map.length; i++) {
      employees.add(Employee.toEmp(map[i]));
    }
    count = await _myDatabase.countEmp();
    setState(() {
      isLoading = false;
    });
    //
  }

  @override
  void initState() {
    /*
    employees.add(
      Employee(
        empName: 'abd',
        empAddr: 'abcdefg',
        empEmail: 'abc@gmail.com',
        empContact: "1234567890",
        insertDate: '2025-07-01',
      ),
    );
    employees.add(
      Employee(
        empName: 'John Doe',
        empAddr: '123 Main St',
        empEmail: 'john.doe@example.com',
        empContact: "0987654321",
        insertDate: '2025-07-02',
      ),
    );
    */
    getDataFromDb();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employees ($count)'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
          ? const Center(child: Text('No Employee Data Found'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Employee by name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Showing ${filteredEmployees.length} result${filteredEmployees.length == 1 ? '' : 's'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditEmp(
                                employee: filteredEmployees[index],
                                myDatabase: _myDatabase,
                              ),
                            ),
                          );
                        },
                        title: Text(
                          filteredEmployees[index].empName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(filteredEmployees[index].empAddr),
                        trailing: IconButton(
                          onPressed: () async {
                            // delete logic
                            String empName = filteredEmployees[index].empName;

                            // Store the state of `mounted` before the await
                            final isMounted = mounted;

                            await _myDatabase.deleteEmp(
                              filteredEmployees[index],
                            );
                            if (isMounted && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('$empName deleted'),
                                ),
                              );
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEmp(myDatabase: _myDatabase),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
        backgroundColor: Colors.teal[300],
      ), // <== removed semicolon from here and placed it here
    );
  }
}
