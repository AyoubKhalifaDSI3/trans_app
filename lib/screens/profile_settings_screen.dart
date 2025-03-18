import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _lastname = '';
  String _phone = '';
  

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('chauffeurs').doc(user.uid).get();
      if (userData.exists) {
        setState(() {
          _name = userData['nom'] ?? '';
          _lastname = userData['prenom'] ?? '';
          _phone = userData['telephone'] ?? '';
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('chauffeurs').doc(user.uid).update({
          'nom': _name,
          'prenom': _lastname,
          'telephone': _phone,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour !"),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
          );
        });
      }
    }
  }

  Future<void> _changePassword() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _auth.sendPasswordResetEmail(email: user.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email de réinitialisation envoyé !"),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil & Paramètres"),
        backgroundColor: const Color(0xFF5483FA),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📌 Carte des informations personnelles
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informations personnelles",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),

                        // Nom
                        TextFormField(
                          initialValue: _name,
                          decoration: InputDecoration(
                            labelText: "Nom",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onSaved: (value) => _name = value!,
                          validator: (value) => value!.isEmpty ? "Ce champ est obligatoire" : null,
                        ),
                        const SizedBox(height: 10),

                        // Prénom
                        TextFormField(
                          initialValue: _lastname,
                          decoration: InputDecoration(
                            labelText: "Prénom",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onSaved: (value) => _lastname = value!,
                          validator: (value) => value!.isEmpty ? "Ce champ est obligatoire" : null,
                        ),
                        const SizedBox(height: 10),

                        // Téléphone
                        TextFormField(
                          initialValue: _phone,
                          decoration: InputDecoration(
                            labelText: "Téléphone",
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          keyboardType: TextInputType.phone,
                          onSaved: (value) => _phone = value!,
                          validator: (value) => value!.isEmpty ? "Ce champ est obligatoire" : null,
                        ),
                        const SizedBox(height: 20),

                        // Bouton de mise à jour
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _updateProfile,
                            icon: const Icon(Icons.save),
                            label: const Text("Mettre à jour le profil"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5483FA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 📌 Changement du mot de passe
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.lock, color: Color(0xFF5483FA)),
                  title: const Text("Changer le mot de passe"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _changePassword,
                ),
              ),

              const SizedBox(height: 30),

              // 📌 Avis et notes
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                
              ),
            ],
          ),
        ),
      ),
    );
  }
}
