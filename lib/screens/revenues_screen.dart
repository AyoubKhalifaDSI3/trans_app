import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevenuesScreen extends StatefulWidget {
  const RevenuesScreen({super.key});

  @override
  _RevenuesScreenState createState() => _RevenuesScreenState();
}

class _RevenuesScreenState extends State<RevenuesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _revenueController = TextEditingController();

  String chauffeurName = "";
  bool isLoading = true;
  bool isCalculating = false;
  double chauffeurRevenue = 0.0;
  double clientPercentage = 0.10;
  double chauffeurFinalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadChauffeurData();
  }

  Future<void> _loadChauffeurData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot chauffeurDoc =
          await _firestore.collection('chauffeurs').doc(user.uid).get();

      if (chauffeurDoc.exists) {
        setState(() {
          chauffeurName = chauffeurDoc['name'] ?? "Chauffeur inconnu";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur de récupération des données : $e");
    }
  }

  void _calculateRevenue() {
    setState(() {
      isCalculating = false;
    });
    double totalRevenue = double.tryParse(_revenueController.text) ?? 0.0;
    double clientShare = totalRevenue * clientPercentage;
    chauffeurFinalRevenue = totalRevenue - clientShare;

    setState(() {
      chauffeurRevenue = totalRevenue;
      isCalculating = false;
      _revenueController.clear(); // Efface le champ après le calcul
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Revenus de $chauffeurName"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card pour le chauffeur
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chauffeur: $chauffeurName",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Statut du Trajet: En cours",
                            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Card pour les informations du trajet
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("🚖 Informations du Trajet",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text("Point de départ: Ville A", style: TextStyle(fontSize: 16)),
                          Text("Destination: Ville B", style: TextStyle(fontSize: 16)),
                          Text("Distance: 50 km", style: TextStyle(fontSize: 16)),
                          Text("Durée estimée: 1 heure", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Card pour la saisie des revenus
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("💰 Saisir le prix du trajet",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          TextField(
                            controller: _revenueController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Montant du trajet (€)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _calculateRevenue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text("Calculer les revenus", style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Affichage des revenus calculés
                  if (chauffeurRevenue > 0)
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "💵 Résumé des Revenus",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Revenu total:", style: TextStyle(fontSize: 16)),
                                Text("${chauffeurRevenue.toStringAsFixed(2)} €",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Commission client (10%) :", style: TextStyle(fontSize: 16)),
                                Text(
                                  "- ${(chauffeurRevenue * clientPercentage).toStringAsFixed(2)} €",
                                  style: TextStyle(fontSize: 16, color: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Revenu net :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(
                                  "${chauffeurFinalRevenue.toStringAsFixed(2)} €",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
