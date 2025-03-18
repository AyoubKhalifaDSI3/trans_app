import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trans_app/screens/signin_screen.dart';
import 'package:trans_app/theme/theme.dart';
import 'package:trans_app/widgets/custom_scaffold.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();

}


class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  String? selectedColor;
  File? _vehicleImage;
   String? _vehicleImageBase64;
 // final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('chauffeurs');
  final GlobalKey<FormState> _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = false;
  ////////////////////
  Future<void> pickVehicleImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      
      setState(() {
        _vehicleImage = File(pickedFile.path);
      });
    }
  }
  ////////////////////////
  
  //get vehicleImageBase64 => null; // Set to false initially for agreement checkbox

 /*Future<String?> pickImageAndConvertToBase64() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image == null) return null;

  Uint8List imageBytes = await image.readAsBytes();
  String base64String = base64Encode(imageBytes);

  return base64String;
} */

  
  
  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('vehicle_images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
 Future<void> registration() async {
  if (_formSignupKey.currentState!.validate() && agreePersonalData) {
    try {
      // Créer l'utilisateur avec Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Récupérer l'UID de l'utilisateur
      final uid = userCredential.user!.uid;
  
            String? imageUrl;
        if (_vehicleImage != null) {
          List<int> imageBytes = await _vehicleImage!.readAsBytes();
          imageUrl = base64Encode(imageBytes);
        }
      // Télécharger l'image du véhicule (si elle existe)
     /* String? imageUrl;
      if (_vehicleImage != null) {
        imageUrl = await uploadImageToFirebase(_vehicleImage!);
      }*/

      // Enregistrer les informations du chauffeur dans Firestore avec l'UID
      await FirebaseFirestore.instance.collection('chauffeurs').doc(uid).set({
        'uid': uid, // Stocker l'UID dans Firestore
        'name': nameController.text,
        'lastname': lastnameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        //'password': passwordController.text.trim(),
        'vehicle': vehicleController.text,
        'vehicleColor': selectedColor,
        
         if (imageUrl != null) 'vehicleImage': imageUrl, // Ajouter seulement si non null
      });

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Inscription réussie!", style: TextStyle(fontSize: 20.0)),
          backgroundColor: Colors.green,
        ),
      );

      // Rediriger vers la page de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs
      String errorMessage = '';
      if (e.code == 'weak-password') {
        errorMessage = "Le mot de passe est trop faible.";
      } else if (e.code == "email-already-in-use") {
        errorMessage = "Un compte existe déjà avec cet email.";
      } else {
        errorMessage = "Une erreur s'est produite: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: TextStyle(fontSize: 18.0)),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else if (!agreePersonalData) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez accepter le traitement des données personnelles.'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title
                      TextFormField(
                controller: nameController,
                validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom complet';
                          }
                          return null;
                        },
                decoration: InputDecoration(labelText: 'Prénom',
                hintText: 'Entrer Le prenom ',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          ),
                ),const SizedBox(height: 25.0),
                
              TextFormField(
                controller: lastnameController,
                validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le nom ';
                          }
                          return null;
                        },
                        decoration:  InputDecoration(labelText: 'Nom de famille',
                          hintText: 'Entrer Le nom ',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                           ),
                          ),
                        ),const SizedBox(height: 25.0),
                  
              
              TextFormField(
                controller: phoneController,
                validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le telephone ';
                          }
                          return null;
                        },
                 decoration:  InputDecoration(labelText: 'Téléphone',
                  hintText: 'Entrer Le nom ',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                           ),
                        ),
                 ),const SizedBox(height: 25.0),
              TextFormField(
                 controller: emailController,
                 validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre adresse e-mail';
                          }
                          return null;
                        },
                  decoration:  InputDecoration(labelText: 'Email',
                  hintText: 'Entrer Email',hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                             ),
                          ),   
                      ),const SizedBox(height: 25.0),
              TextFormField(controller: passwordController,
               obscureText: true,
               obscuringCharacter: '*',
               validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                decoration:  InputDecoration(
                  label: const Text('Mot de passe'),
                  hintText: 'Entrer mot de passe',
                  hintStyle: const TextStyle(color: Colors.black26),
                  border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                  ),
               ),const SizedBox(height: 25.0),

              TextFormField(controller: vehicleController,
              validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre vehicule';
                          }
                          return null;
                        },
               decoration:  InputDecoration(
                label: const Text('Vehicule'),
                hintText: 'Entrer le vehicule',
                hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                     ),
                   DropdownButtonFormField<String>(
                decoration:  InputDecoration(labelText: 'Couleur du véhicule'),
                value: selectedColor,
                items: ['Rouge', 'Bleu', 'Vert', 'Noir', 'Blanc']
                    .map((color) => DropdownMenuItem(value: color, child: Text(color)))
                    .toList(),
                onChanged: (value) => setState(() => selectedColor = value),
              ),
              const SizedBox(height: 10),
              _vehicleImageBase64 != null
                  ? Image.memory(base64Decode(_vehicleImageBase64!), height: 100)
                  : ElevatedButton(onPressed: pickVehicleImage, child: const Text('Choisir une image')),
                  const SizedBox(height: 25.0),
              
                
                      // Personal data agreement checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            "J'accepte le traitement de ",
                            style: TextStyle(color: Colors.black45),
                          ),
                          Text(
                            'Données personnelles',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),

                      // Signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: registration,
                          child: const Text("S'inscrire"),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              // ignore: deprecated_member_use
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              // ignore: deprecated_member_use
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30.0),

                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Vous avez déjà un compte ? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Se connecter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  Widget buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        obscuringCharacter: '*',
        validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer $label' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
