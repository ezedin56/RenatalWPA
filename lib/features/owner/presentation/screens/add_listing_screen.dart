import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/location_service.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});

  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  int _currentStep = 0;

  // Step 1 — Basic Info
  final _titleCtrl = TextEditingController();
  String _propertyType = 'apartment';
  final _bedroomsCtrl = TextEditingController(text: '1');
  final _bathroomsCtrl = TextEditingController(text: '1');

  // Step 2 — Location
  final _locationCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  double? _pickedLat;
  double? _pickedLng;
  GoogleMapController? _mapController;
  bool _locating = false;

  // Step 3 — Pricing
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();

  // Step 4 — Description
  final _descCtrl = TextEditingController();
  final _amenitiesCtrl = TextEditingController();

  // Step 5 — Photos
  final List<File> _pickedImages = [];
  List<String> _uploadedUrls = [];
  bool _uploading = false;
  String? _uploadError;

  // Step 6 — House Rules
  final _checkInCtrl = TextEditingController();
  final _petPolicyCtrl = TextEditingController();

  bool _submitting = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _mapController?.dispose();
    for (final c in [_titleCtrl, _locationCtrl, _cityCtrl, _areaCtrl, _priceCtrl,
        _depositCtrl, _descCtrl, _amenitiesCtrl, _checkInCtrl, _petPolicyCtrl,
        _bedroomsCtrl, _bathroomsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    final remaining = 10 - _pickedImages.length;
    final toAdd = picked.take(remaining).map((x) => File(x.path)).toList();

    setState(() {
      _pickedImages.addAll(toAdd);
      _uploadError = null;
    });
  }

  Future<void> _uploadImages() async {
    if (_pickedImages.isEmpty) return;
    setState(() { _uploading = true; _uploadError = null; });

    try {
      final dio = ref.read(dioProvider);
      final formData = FormData();
      for (final file in _pickedImages) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      }
      final response = await dio.post(ApiEndpoints.uploadImages, data: formData);
      _uploadedUrls = List<String>.from(response.data['data']['urls']);
    } catch (e) {
      setState(() { _uploadError = 'Upload failed. Check your connection.'; });
    } finally {
      setState(() { _uploading = false; });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
      if (_uploadedUrls.length > index) _uploadedUrls.removeAt(index);
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      // Upload images first if not yet uploaded
      if (_pickedImages.isNotEmpty && _uploadedUrls.isEmpty) {
        await _uploadImages();
        if (_uploadError != null) { setState(() => _submitting = false); return; }
      }

      final dio = ref.read(dioProvider);
      final location = [_locationCtrl.text, _cityCtrl.text, _areaCtrl.text]
          .where((s) => s.isNotEmpty).join(', ');

      await dio.post(ApiEndpoints.houses, data: {
        'title': _titleCtrl.text.trim(),
        'type': _propertyType,
        'bedrooms': int.tryParse(_bedroomsCtrl.text) ?? 1,
        'bathrooms': int.tryParse(_bathroomsCtrl.text) ?? 1,
        'location': location,
        'price': double.tryParse(_priceCtrl.text) ?? 0,
        'description': _descCtrl.text.trim(),
        'amenities': _amenitiesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        'images': _uploadedUrls,
        'houseRules': [_checkInCtrl.text, _petPolicyCtrl.text].where((s) => s.isNotEmpty).join('\n'),
        if (_pickedLat != null) 'coordinates': {
          'type': 'Point',
          'coordinates': [_pickedLng, _pickedLat], // GeoJSON: [lng, lat]
        },
      });

      if (mounted) _showPremiumUpgradeModal();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to publish listing. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _onStepContinue() {
    if (_currentStep < 5) {
      setState(() => _currentStep += 1);
    } else {
      _submit();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
    else context.pop();
  }

  void _showPremiumUpgradeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.star, color: AppColors.secondary, size: 48),
            const SizedBox(height: 16),
            const Text('Upgrade to Premium', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Boost your listing to get 5x more views.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _buildFeatureRow(Icons.check_circle, 'Unlimited active listings'),
            _buildFeatureRow(Icons.check_circle, 'Featured placement in search'),
            _buildFeatureRow(Icons.check_circle, 'Verified badge on profile'),
            const SizedBox(height: 24),
            const Text('ETB 500 / month', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              onPressed: () { Navigator.pop(context); context.push('/owner/premium-payment'); },
              child: const Text('Upgrade with M-Pesa'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () { Navigator.pop(context); context.pop(); },
              child: const Text('Publish for Free (1 Remaining)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, color: AppColors.success, size: 20),
      const SizedBox(width: 12),
      Text(text),
    ]),
  );

  // ── Steps ──────────────────────────────────────────────────────────────────

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    final pos = await LocationService.getCurrentPosition();
    if (pos == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get location. Check permissions.')),
      );
      setState(() => _locating = false);
      return;
    }
    final address = await LocationService.reverseGeocode(pos.latitude, pos.longitude);
    setState(() {
      _pickedLat = pos.latitude;
      _pickedLng = pos.longitude;
      _locationCtrl.text = address;
      _locating = false;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15),
    );
  }

  Widget _buildLocationStep() {
    final initialPos = LatLng(_pickedLat ?? 9.0054, _pickedLng ?? 38.7636);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Use My Location button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _locating ? null : _useMyLocation,
            icon: _locating
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
            label: Text(_locating ? 'Getting location...' : 'Use My Current Location'),
          ),
        ),
        const SizedBox(height: 16),
        // Interactive map — tap to pick location
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: initialPos, zoom: 13),
              onMapCreated: (c) => _mapController = c,
              onTap: (latLng) async {
                final address = await LocationService.reverseGeocode(latLng.latitude, latLng.longitude);
                setState(() {
                  _pickedLat = latLng.latitude;
                  _pickedLng = latLng.longitude;
                  _locationCtrl.text = address;
                });
              },
              markers: _pickedLat != null
                  ? {Marker(markerId: const MarkerId('picked'), position: LatLng(_pickedLat!, _pickedLng!))}
                  : {},
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Tap on the map to pin the exact location', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Street / Address', prefixIcon: Icon(Icons.location_on_outlined))),
        const SizedBox(height: 16),
        TextField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City')),
        const SizedBox(height: 16),
        TextField(controller: _areaCtrl, decoration: const InputDecoration(labelText: 'Neighborhood / Area')),
      ],
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tap to pick images
        GestureDetector(
          onTap: _pickedImages.length < 10 ? _pickImages : null,
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 36,
                    color: _pickedImages.length < 10 ? AppColors.primary : AppColors.textSecondary),
                const SizedBox(height: 6),
                Text(
                  _pickedImages.length < 10
                      ? 'Tap to add photos (${_pickedImages.length}/10)'
                      : 'Maximum 10 photos reached',
                  style: TextStyle(
                    color: _pickedImages.length < 10 ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Preview grid
        if (_pickedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
            ),
            itemCount: _pickedImages.length,
            itemBuilder: (ctx, i) => Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_pickedImages[i], fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4, right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(i),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Upload button
        if (_pickedImages.isNotEmpty && _uploadedUrls.isEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : _uploadImages,
              icon: _uploading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.upload),
              label: Text(_uploading ? 'Uploading...' : 'Upload Photos'),
            ),
          ),
        ],

        // Uploaded confirmation
        if (_uploadedUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 18),
              const SizedBox(width: 6),
              Text('${_uploadedUrls.length} photo${_uploadedUrls.length > 1 ? 's' : ''} uploaded',
                  style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w500)),
            ]),
          ),

        // Error
        if (_uploadError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_uploadError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Listing', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _submitting ? null : details.onStepContinue,
                child: _submitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_currentStep == 5 ? 'Preview & Publish' : 'Continue'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
            ),
          ]),
        ),
        steps: [
          Step(
            title: const Text('Basic Information'),
            isActive: _currentStep >= 0,
            content: Column(children: [
              TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Property Title')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _propertyType,
                decoration: const InputDecoration(labelText: 'Property Type'),
                items: const [
                  DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                  DropdownMenuItem(value: 'house', child: Text('House')),
                  DropdownMenuItem(value: 'condo', child: Text('Condo')),
                  DropdownMenuItem(value: 'studio', child: Text('Studio')),
                ],
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: TextField(controller: _bedroomsCtrl, decoration: const InputDecoration(labelText: 'Bedrooms'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _bathroomsCtrl, decoration: const InputDecoration(labelText: 'Bathrooms'), keyboardType: TextInputType.number)),
              ]),
            ]),
          ),
          Step(
            title: const Text('Location'),
            isActive: _currentStep >= 1,
            content: _buildLocationStep(),
          ),
          Step(
            title: const Text('Pricing'),
            isActive: _currentStep >= 2,
            content: Column(children: [
              TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price per month (ETB)'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: _depositCtrl, decoration: const InputDecoration(labelText: 'Security Deposit (Optional)'), keyboardType: TextInputType.number),
            ]),
          ),
          Step(
            title: const Text('Description & Amenities'),
            isActive: _currentStep >= 3,
            content: Column(children: [
              TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Detailed Description'), maxLines: 4),
              const SizedBox(height: 16),
              TextField(controller: _amenitiesCtrl, decoration: const InputDecoration(labelText: 'Amenities (comma separated)', hintText: 'WiFi, Parking, Security...')),
            ]),
          ),
          Step(
            title: const Text('Photos'),
            isActive: _currentStep >= 4,
            content: _buildPhotosStep(),
          ),
          Step(
            title: const Text('House Rules'),
            isActive: _currentStep >= 5,
            content: Column(children: [
              TextField(controller: _checkInCtrl, decoration: const InputDecoration(labelText: 'Check-in Time (Optional)')),
              const SizedBox(height: 16),
              TextField(controller: _petPolicyCtrl, decoration: const InputDecoration(labelText: 'Pet Policy (e.g. No Pets)')),
            ]),
          ),
        ],
      ),
    );
  }
}
