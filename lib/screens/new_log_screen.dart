import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fishlog/models/fishing_log.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class NewLogScreen extends StatefulWidget {
  final String username;
  const NewLogScreen({super.key, required this.username});

  @override
  State<NewLogScreen> createState() => _NewLogScreenState();
}

class _NewLogScreenState extends State<NewLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController(); // Para el nombre personalizado
  final _geocodedAddressController = TextEditingController(); // Para la dirección oficial
  final _notesController = TextEditingController();
  final _fishSpeciesController = TextEditingController();
  final _fishWeightController = TextEditingController();
  final _fishLengthController = TextEditingController();
  final _lureTypeController = TextEditingController();
  final _lureColorController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _conditionsController = TextEditingController();

  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isLoadingWeather = false;
  File? _fishPhoto;
  File? _lurePhoto;
  bool _isCatch = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoadingSave = false;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
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

  Future<void> _fetchWeather(Position position) async {
    setState(() {
      _isLoadingWeather = true;
    });

    try {
  const apiKey = '52eddc52fcfac12362bfb6ef55608ab7'; // Tu API Key
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=es',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'].toStringAsFixed(1);
        final description = data['weather'][0]['description'];
        setState(() {
          _temperatureController.text = temp;
          _conditionsController.text = description;
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

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      // Llamadas en secuencia
      await _getAddressFromLatLng(position);
      await _fetchWeather(position);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación y clima obtenidos con éxito.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener la ubicación o el clima: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _launchMapsUrl() async {
    if (_currentPosition == null) return;
    final lat = _currentPosition!.latitude;
    final lon = _currentPosition!.longitude;
    final url = Uri.parse('http://maps.google.com/?q=$lat,$lon');
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
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveLog() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoadingSave = true;
      });

      try {
        final fishingLogBox = Hive.box<FishingLog>('fishingLogs');
        DateTime? finalDateTime;
        if (_selectedDate != null && _selectedTime != null) {
          finalDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        }

        final newLog = FishingLog(
          userId: widget.username,
          location: _locationController.text, // Nombre personalizado
          geocodedAddress: _geocodedAddressController.text, // Dirección oficial
          latitude: _currentPosition?.latitude ?? 0.0,
          longitude: _currentPosition?.longitude ?? 0.0,
          date: finalDateTime,
          notes: _notesController.text,
          photoPath: _fishPhoto?.path ?? '',
          lurePhotoPath: _lurePhoto?.path ?? '',
          isCatch: _isCatch,
          fishSpecies: _fishSpeciesController.text.isNotEmpty ? _fishSpeciesController.text : null,
          fishWeight: double.tryParse(_fishWeightController.text),
          fishLength: double.tryParse(_fishLengthController.text),
          lureType: _lureTypeController.text.isNotEmpty ? _lureTypeController.text : null,
          lureColor: _lureColorController.text.isNotEmpty ? _lureColorController.text : null,
          temperature: double.tryParse(_temperatureController.text),
          conditions: _conditionsController.text.isNotEmpty ? _conditionsController.text : null,
        );

        await fishingLogBox.add(newLog);

        if (mounted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro guardado exitosamente.')),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el registro: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingSave = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _geocodedAddressController.dispose();
    _notesController.dispose();
    _fishSpeciesController.dispose();
    _fishWeightController.dispose();
    _fishLengthController.dispose();
    _lureTypeController.dispose();
    _lureColorController.dispose();
    _temperatureController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Registro de Pesca')),
      body: _isLoadingSave
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Lugar (Personalizado)',
                        hintText: 'Ej: La curva del sauce',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa un nombre para el lugar';
                        }
                        return null;
                      },
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
                    ElevatedButton.icon(
                      onPressed: _isLoadingLocation
                          ? null
                          : _getCurrentLocation,
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
                      label: Text(
                        _currentPosition == null
                            ? 'Obtener Ubicación y Clima'
                            : 'Ubicación y Clima Obtenidos',
                      ),
                    ),
                    if (_currentPosition != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Latitud: ${_currentPosition!.latitude.toStringAsFixed(4)}, Longitud: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedDate == null
                                  ? 'Seleccionar fecha'
                                  : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectTime(context),
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _selectedTime == null
                                  ? 'Seleccionar hora'
                                  : 'Hora: ${_selectedTime!.format(context)}',
                            ),
                          ),
                        ),
                      ],
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
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fishSpeciesController,
                      decoration: const InputDecoration(labelText: 'Especie del Pez'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _fishWeightController,
                            decoration: const InputDecoration(labelText: 'Peso (kg)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _fishLengthController,
                            decoration: const InputDecoration(labelText: 'Longitud (cm)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lureTypeController,
                      decoration: const InputDecoration(labelText: 'Tipo de Señuelo'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lureColorController,
                      decoration: const InputDecoration(labelText: 'Color del Señuelo'),
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
                          onPressed: () =>
                              _pickImage(ImageSource.camera, 'fish'),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Tomar Foto'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _pickImage(ImageSource.gallery, 'fish'),
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
                          onPressed: () =>
                              _pickImage(ImageSource.camera, 'lure'),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Tomar Foto'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _pickImage(ImageSource.gallery, 'lure'),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galería'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveLog,
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
