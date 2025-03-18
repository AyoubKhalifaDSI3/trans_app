import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  LatLng? _pickupPoint;
  LatLng? _deliveryPoint;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchPickupAndDeliveryPoints();
  }

  // Obtenir la position actuelle du chauffeur
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  // Récupérer les points de ramassage et de livraison depuis Firestore
  Future<void> _fetchPickupAndDeliveryPoints() async {
    String userId = "USER_ID"; // Remplace par FirebaseAuth.instance.currentUser!.uid

    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('chauffeurs').doc(userId).get();
    if (userData.exists) {
      setState(() {
        _pickupPoint = LatLng(userData['pickup_lat'], userData['pickup_lng']);
        _deliveryPoint = LatLng(userData['delivery_lat'], userData['delivery_lng']);
      });
    }
  }

  // Ouvrir Google Maps avec l'itinéraire
  void _openGoogleMaps() async {
    if (_currentPosition == null || _deliveryPoint == null) return;
    String url =
        "https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_deliveryPoint!.latitude},${_deliveryPoint!.longitude}&travelmode=driving";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible d\'ouvrir Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte & Navigation"),
        backgroundColor: const Color.fromRGBO(84, 131, 250, 1),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  position: _currentPosition!,
                  infoWindow: const InfoWindow(title: "Votre position"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
                if (_pickupPoint != null)
                  Marker(
                    markerId: const MarkerId("pickup"),
                    position: _pickupPoint!,
                    infoWindow: const InfoWindow(title: "Point de ramassage"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  ),
                if (_deliveryPoint != null)
                  Marker(
                    markerId: const MarkerId("delivery"),
                    position: _deliveryPoint!,
                    infoWindow: const InfoWindow(title: "Point de livraison"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  ),
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openGoogleMaps,
        backgroundColor: const Color.fromRGBO(84, 131, 250, 1),
        child: const Icon(Icons.directions, color: Colors.white),
      ),
    );
  }
}
