import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fishlog/models/fishing_log.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class EditLogScreen extends StatefulWidget {
  final FishingLog logToEdit;
  const EditLogScreen({super.key, required this.logToEdit});

  @override
  State<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _locationController;
  late final TextEditingController _geocodedAddressController;
  late final TextEditingController _notesController;
  late final TextEditingController _temperatureController;
  late final TextEditingController _conditionsController;

  late bool _isCatch;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  Position? _currentPosition;
  bool _isLoadingLocation = false;
  File? _fishPhoto;
  File? _lurePhoto;
  bool _hasChanged = false;
  bool _isLoadingWeather = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.logToEdit.location);
    _geocodedAddressController = TextEditingController(text: widget.logToEdit.geocodedAddress ?? '');
    _notesController = TextEditingController(text: widget.logToEdit.notes);
    _temperatureController = TextEditingController(text: widget.logToEdit.temperature?.toString() ?? '');
    _conditionsController = TextEditingController(text: widget.logToEdit.conditions ?? '');

    _isCatch = widget.logToEdit.isCatch;
    _selectedDate = widget.logToEdit.date ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(widget.logToEdit.date ?? DateTime.now());

    _locationController.addListener(_onChanged);
    _notesController.addListener(_onChanged);

    if (widget.logToEdit.photoPath.isNotEmpty) {
      _fishPhoto = File(widget.logToEdit.photoPath);
    }
    if (widget.logToEdit.lurePhotoPath.isNotEmpty) {
      _lurePhoto = File(widget.logToEdit.lurePhotoPath);
    }

    // Si no hay datos de clima, intenta obtenerlos
    if (_conditionsController.text.isEmpty) {
      _fetchWeather(null);
    }
  }

  void _onChanged() {
    if (!_hasChanged) {
      setState(() {
        _hasChanged = true;
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return false;
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Los servicios de ubicación están deshabilitados. Por favor, habilítalos.',
            ),
          ),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (!mounted) return false;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (!mounted) return false;
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se denegaron los permisos de ubicación.'),
            ),
          );
        }
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Los permisos de ubicación se han denegado permanentemente. No se puede solicitar la ubicación.',
            ),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _fetchWeather(Position? position) async {
    setState(() {
      _isLoadingWeather = true;
    });

    try {
      final lat = position?.latitude ?? widget.logToEdit.latitude;
      final lon = position?.longitude ?? widget.logToEdit.longitude;

      if (lat == 0.0 && lon == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación no disponible para obtener clima.')),
        );
        return;
      }

      const apiKey = '52eddc52fcfac12362bfb6ef55608ab7';
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=es',
      );

  final response = await http.get(url);
  if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'].toStringAsFixed(1);
        final description = data['weather'][0]['description'];
        setState(() {
          _temperatureController.text = temp;
          _conditionsController.text = description;
          _hasChanged = true;
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo obtener el clima.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener datos del clima: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _geocodedAddressController.text =
              '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener la dirección: $e')),
        );
      }
    }
  }

  void _getCurrentLocation() async {
    if (!await _handleLocationPermission()) return;

          if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _hasChanged = true;
      });
      
      await _getAddressFromLatLng(position);
      if (!mounted) return;
      await _fetchWeather(position);
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación y clima actualizados.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación: $e')),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _launchMapsUrl() async {
    final lat = _currentPosition?.latitude ?? widget.logToEdit.latitude;
    final lon = _currentPosition?.longitude ?? widget.logToEdit.longitude;
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir la URL: $url';
    }
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (imageType == 'fish') {
          _fishPhoto = File(pickedFile.path);
        } else if (imageType == 'lure') {
          _lurePhoto = File(pickedFile.path);
        }
        _hasChanged = true;
      });
    }
  }

  void _saveLog() async {
    if (_formKey.currentState!.validate()) {
      final fishingLogBox = await Hive.openBox<FishingLog>('fishingLogs');
      final newDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final updatedLog = FishingLog(
        userId: widget.logToEdit.userId,
        location: _locationController.text,
        geocodedAddress: _geocodedAddressController.text,
        latitude: _currentPosition?.latitude ?? widget.logToEdit.latitude,
        longitude: _currentPosition?.longitude ?? widget.logToEdit.longitude,
        date: newDate,
        photoPath: _fishPhoto?.path ?? '',
        lurePhotoPath: _lurePhoto?.path ?? '',
        weather: widget.logToEdit.weather, // Este campo parece no usarse, se usa conditions
        lure: widget.logToEdit.lure, // Ajustar si es necesario
        notes: _notesController.text,
        isCatch: _isCatch,
        temperature: double.tryParse(_temperatureController.text),
        conditions: _conditionsController.text,
      );

      await fishingLogBox.put(widget.logToEdit.key, updatedLog);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro actualizado con éxito.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Cambios sin guardar'),
              content: const Text(
                '¿Quieres guardar los cambios antes de salir?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Descartar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        _hasChanged = true;
      });
    });
  }

  void _presentTimePicker() {
    showTimePicker(context: context, initialTime: _selectedTime).then((
      pickedTime,
    ) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
        _hasChanged = true;
      });
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _geocodedAddressController.dispose();
    _notesController.dispose();
    _temperatureController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_hasChanged) return true;
        final shouldSave = await _showUnsavedChangesDialog();
        if (shouldSave == true) {
          _saveLog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Editar Registro de Pesca')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Lugar (Personalizado)',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _geocodedAddressController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Dirección Oficial (Automática)',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Fecha: ${(_selectedDate).toString().substring(0, 10)}',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _presentDatePicker,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('Hora: ${_selectedTime.format(context)}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: _presentTimePicker,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _temperatureController,
                        decoration: const InputDecoration(labelText: 'Temperatura (°C)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    if (_isLoadingWeather) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _conditionsController,
                  decoration: const InputDecoration(
                    labelText: 'Condición del Clima',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('¿Hubo Captura?'),
                    Switch(
                      value: _isCatch,
                      onChanged: (value) {
                        setState(() {
                          _isCatch = value;
                          _hasChanged = true;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.location_on),
                  label: const Text('Actualizar Ubicación y Clima'),
                ),
                if (_currentPosition != null || widget.logToEdit.latitude != 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Latitud: ${(_currentPosition?.latitude ?? widget.logToEdit.latitude).toStringAsFixed(4)}, Longitud: ${(_currentPosition?.longitude ?? widget.logToEdit.longitude).toStringAsFixed(4)}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        IconButton(
                          onPressed: _launchMapsUrl,
                          icon: const Icon(Icons.map),
                          tooltip: 'Ver en Google Maps',
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (caña, línea, etc.)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Foto del Pez',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                if (_fishPhoto != null)
                  Image.file(_fishPhoto!, height: 200, fit: BoxFit.cover)
                else
                  Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('No hay imagen seleccionada'),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera, 'fish'),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar Foto'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery, 'fish'),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Foto del Señuelo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                if (_lurePhoto != null)
                  Image.file(_lurePhoto!, height: 200, fit: BoxFit.cover)
                else
                  Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('No hay imagen seleccionada'),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera, 'lure'),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar Foto'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery, 'lure'),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveLog,
                  child: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
