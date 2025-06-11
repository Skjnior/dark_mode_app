import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AddStudentScreen extends StatefulWidget {
  final Map<String, dynamic>? student;
  final Function(Map<String, dynamic>) onSave;

  AddStudentScreen({this.student, required this.onSave});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _nomController.text = widget.student!['nom'];
      _prenomController.text = widget.student!['prenom'];
      _dateNaissanceController.text = widget.student!['dateNaissance'];
      _noteController.text = widget.student!['note'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color primaryColor = isDark ? Colors.tealAccent : Colors.purple;
    Color backgroundColor = isDark ? Colors.grey[850]! : Colors.purple.shade50;
    Color textColor = isDark ? Colors.white : Colors.black;

    InputDecoration inputDecoration(String label, String hint, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? "Ajouter un étudiant" : "Modifier un étudiant"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 25,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: inputDecoration("Nom", "Entrez votre nom", Icons.person),
                validator: (value) => value == null || value.isEmpty ? 'Le nom est requis' : null,
              ),
              TextFormField(
                controller: _prenomController,
                decoration: inputDecoration("Prénom", "Entrez votre prénom", Icons.person_outline),
                validator: (value) => value == null || value.isEmpty ? 'Le prénom est requis' : null,
              ),
              TextFormField(
                controller: _dateNaissanceController,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(Duration(days: 365 * 20)), // par défaut 20 ans
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Theme(
                        data: isDark
                            ? ThemeData.dark()
                            : ThemeData.light(),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                    setState(() {
                      _dateNaissanceController.text = formattedDate;
                    });
                  }
                },
                decoration: inputDecoration(
                  "Date de naissance", "JJ/MM/AAAA", Icons.calendar_today,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La date de naissance est requise';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration("Note", "Entrez une note", Icons.star),
                validator: (value) => value == null || value.isEmpty ? 'La note est requise' : null,
              ),
              Container(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(double.infinity, 30),
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.deepPurple
                        : Colors.blue,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave({
                        'nom': _nomController.text,
                        'prenom': _prenomController.text,
                        'dateNaissance': _dateNaissanceController.text,
                        'note': _noteController.text,
                      });
                      Get.back();
                    }
                  },
                  child: Text(
                    widget.student == null ? "Ajouter" : "Sauvegarder",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
