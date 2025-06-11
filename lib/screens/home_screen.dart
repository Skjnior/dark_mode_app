import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'addStudent.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  HomeScreen({required this.onThemeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  TextEditingController _searchController = TextEditingController();
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/students.json');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Manager'),
        backgroundColor: _selectedTheme == ThemeMode.dark
            ? Colors.black
            : _selectedTheme == ThemeMode.light
            ? Colors.blue
            : Theme.of(context).appBarTheme.backgroundColor,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const ListTile(title: Text("Paramètres"), leading: Icon(Icons.settings)),
            SwitchListTile(
              title: const Text("Mode Système 📱"),
              value: _selectedTheme == ThemeMode.system,
              onChanged: (value) {
                if (value) _changeTheme(ThemeMode.system);
              },
            ),
            SwitchListTile(
              title: const Text("Mode Clair ☀️"),
              value: _selectedTheme == ThemeMode.light,
              onChanged: (value) {
                if (value) _changeTheme(ThemeMode.light);
              },
            ),
            SwitchListTile(
              title: const Text("Mode Sombre 🌙"),
              value: _selectedTheme == ThemeMode.dark,
              onChanged: (value) {
                if (value) _changeTheme(ThemeMode.dark);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher par nom, prénom ou note",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      "${student['prenom']} ${student['nom']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date de naissance: ${student['dateNaissance']}"),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text("Note: ${student['note']}"),
                            _buildNoteBadge(student['note']),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showEditStudentBottomSheet(students.indexOf(student), student),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStudent(students.indexOf(student)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          Get.to(() => AddStudentScreen(onSave: _addStudent));
        },
      ),
    );
  }




  _loadStudents() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final loadedStudents = List<Map<String, dynamic>>.from(json.decode(contents));
        setState(() {
          students = loadedStudents;
          filteredStudents = loadedStudents;
        });
      }
    } catch (e) {
      print("Error loading students: $e");
    }
  }

  _saveStudents() async {
    final file = await _localFile;
    await file.writeAsString(json.encode(students));
  }

  _addStudent(Map<String, dynamic> student) {
    setState(() {
      students.add(student);
      _filterStudents();
    });
    _saveStudents();
  }

  _editStudent(int index, Map<String, dynamic> student) {
    setState(() {
      students[index] = student;
      _filterStudents();
    });
    _saveStudents();
  }

  _deleteStudent(int index) {
    setState(() {
      students.removeAt(index);
      _filterStudents();
    });
    _saveStudents();
  }

  _changeTheme(ThemeMode mode) {
    setState(() {
      _selectedTheme = mode;
    });
    widget.onThemeChanged(mode);
  }

  _filterStudents() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) {
        final nom = student['nom'].toString().toLowerCase();
        final prenom = student['prenom'].toString().toLowerCase();
        final note = student['note'].toString().toLowerCase();
        return nom.contains(query) || prenom.contains(query) || note.contains(query);
      }).toList();
    });
  }

  _showEditStudentBottomSheet(int index, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            height: 700,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: AddStudentScreen(
              student: student,
              onSave: (updatedStudent) {
                _editStudent(index, updatedStudent);
                Get.back();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteBadge(dynamic noteRaw) {
    double note = double.tryParse(noteRaw.toString()) ?? 0;

    String label;
    Color color;

    if (note > 15) {
      label = "Excellent";
      color = Colors.green;
    } else if (note >= 10) {
      label = "A la moyenne";
      color = Colors.orange;
    } else if (note >= 5) {
      label = "Pas la moyenne";
      color = Colors.blue;
    } else {
      label = "Médiocre";
      color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

}
