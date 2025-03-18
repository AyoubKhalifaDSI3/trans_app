import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrajetScreen extends StatefulWidget {
  const TrajetScreen({super.key});

  @override
  _TrajetScreenState createState() => _TrajetScreenState();
}

class _TrajetScreenState extends State<TrajetScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _deliveryController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTransport;
  List<String> transportModes = ['Bateau', 'Avion'];

  Map<String, bool> expanded = {
    'ramassage': false,
    'livraison': false,
    'trajets': false,
  };

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  /// Fonction pour sélectionner une date (uniquement pour les trajets)
  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTransport = null;
      });
    }
  }

  /// Ajouter un point ou un trajet avec une date uniquement pour les trajets
 void _addOrUpdateData(String collection, String value) async {
    if (value.isEmpty || _currentUser == null || _selectedDate == null || _selectedTransport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    try {
      DocumentReference chauffeurRef = _firestore.collection('chauffeurs').doc(_currentUser!.uid);

      Map<String, dynamic> data = {
        "name": value,
        "date": _selectedDate!.toIso8601String().split('T')[0], // Format YYYY-MM-DD
        "style": _selectedTransport,
      };

      await chauffeurRef.update({
        collection: FieldValue.arrayUnion([data])
      });

      setState(() {
        _selectedDate = null;
        _selectedTransport = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$value ajouté avec succès")),
      );
    } catch (e) {
      print("Erreur Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  } 
  Widget _buildTransportDropdown() {
    return DropdownButton<String>(
      hint: const Text("Sélectionner un mode de transport"),
      value: _selectedTransport,
      onChanged: (String? newValue) {
        setState(() {
          _selectedTransport = newValue;
        });
      },
      items: transportModes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
   Widget _buildList(String collection) {
    if (_currentUser == null) return const CircularProgressIndicator();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chauffeurs')
          .doc(_currentUser!.uid)
          .collection(collection)
          .orderBy(collection == "trajets" ? 'date' : 'name', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        var docs = snapshot.data!.docs;

        if (docs.isEmpty) return const Text("Aucun élément ajouté");

        return Column(
          children: [
            for (var doc in docs)
              Card(
                elevation: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(doc["name"], style: const TextStyle(fontSize: 18)),
                  subtitle: collection == "trajets"
                      ? Text(
                          "Date: ${doc["date"]}",
                          style: const TextStyle(color: Colors.grey),
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => doc.reference.delete(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String collection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 6.0,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ajouter $label",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              if (collection == "trajets")
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () => _pickDate(context),
                ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () {
                  _addOrUpdateData(collection, controller.text);
                  controller.clear();
                },
              ),
            ],
          ),
        ),
        if (collection == "trajets" && _selectedDate != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              "Date sélectionnée: ${_selectedDate!.toIso8601String().split('T')[0]}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
          _buildTransportDropdown(),
        ],
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des trajets"),
        backgroundColor:  Color.fromRGBO(84, 131, 250, 1),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInputField("Point de ramassage", _pickupController, "ramassage"),
                  _buildInputField("Point de livraison", _deliveryController, "livraison"),
                  _buildInputField("Trajet", _routeController, "trajets"),
                ] ,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

