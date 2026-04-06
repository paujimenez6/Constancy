import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../generated/l10n.dart';
import '../../auth/data/repositories/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _cognomController;
  File? _imagePreview;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _nomController = TextEditingController(text: user.nom);
    _cognomController = TextEditingController(text: user.cognom);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _cognomController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 500, imageQuality: 80,);
    if (image != null) setState(() {_imagePreview = File(image.path);});
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final user = context.read<AuthProvider>().currentUser!;
    final strings = S.of(context);
    final supabase = Supabase.instance.client;

    try {
      String? finalImageUrl = user.imatgePerfil;

      if (_imagePreview != null) {
        final String storagePath = '${user.id}/avatar.png';

        await supabase.storage.from('avatars').upload(storagePath, _imagePreview!, fileOptions: const FileOptions(upsert: true),);

        final String rawUrl = supabase.storage.from('avatars').getPublicUrl(storagePath);
        finalImageUrl = "$rawUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      }

      await supabase.from('profiles').update({
        'nom': _nomController.text.trim(),
        'cognom': _cognomController.text.trim(),
        'imatge_perfil': finalImageUrl,
      }).eq('id', user.id);

      if (mounted) {
        if (_imagePreview != null) context.read<AuthProvider>().updateProfileImage(finalImageUrl!);
        context.read<AuthProvider>().updateUserData(nom: _nomController.text.trim(), cognom: _cognomController.text.trim(),);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.changesSaved), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      //debugPrint("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.savingError), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      appBar: AppBar(title: Text(strings.editProfileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: _imagePreview != null
                          ? FileImage(_imagePreview!) as ImageProvider
                          : (user.imatgePerfil != null ? NetworkImage(user.imatgePerfil!) : null),
                      child: (_imagePreview == null && user.imatgePerfil == null)
                          ? Text(user.nickname[0].toUpperCase(), style: TextStyle(fontSize: 40, color: theme.colorScheme.primary))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        onPressed: _pickImage,
                        backgroundColor: const Color(0xFF172748),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              TextFormField(
                initialValue: user.nickname,
                enabled: false,
                decoration: InputDecoration(
                  labelText: strings.usernameLabel,
                  helperText: strings.usernameInfo,
                  prefixIcon: const Icon(Icons.alternate_email),
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: strings.nameLabel, prefixIcon: const Icon(Icons.person_outline)),
                validator: (v) => v!.isEmpty ? strings.fieldRequired : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cognomController,
                decoration: InputDecoration(labelText: strings.lastNameLabel, prefixIcon: const Icon(Icons.person_outline)),
                validator: (v) => v!.isEmpty ? strings.fieldRequired : null,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: const Color(0xFF172748),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(strings.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}