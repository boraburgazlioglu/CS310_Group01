import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/band_provider.dart';
import '../utils/colors.dart';
import '../utils/text.dart';
import '../utils/padding.dart';
import '../widgets/bandmate_header.dart';

class BandSelectionScreen extends StatefulWidget {
  const BandSelectionScreen({super.key});

  @override
  State<BandSelectionScreen> createState() => _BandSelectionScreenState();
}

class _BandSelectionScreenState extends State<BandSelectionScreen> {
  final TextEditingController _bandNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _joinCodeController = TextEditingController();

  final CollectionReference<Map<String, dynamic>> _bandsCollection =
  FirebaseFirestore.instance.collection('bands');

  bool _isCreateMode = true;
  bool _isLoading = false;

  static const String _mainRoute = '/home';

  @override
  void dispose() {
    _bandNameController.dispose();
    _descriptionController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();

    return List.generate(
      6,
          (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> _setBandSessionAndEnterApp({
    required String bandId,
    required String bandName,
    required String joinCode,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'currentBandId': bandId,
        'joinedBands': FieldValue.arrayUnion([bandId]),
      }, SetOptions(merge: true));
    }

    if (!mounted) return;

    context.read<BandProvider>().setCurrentBand(
      bandId: bandId,
      bandName: bandName,
      joinCode: joinCode,
    );

    Navigator.pushReplacementNamed(context, _mainRoute);
  }

  Future<void> _createBand() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('You must be logged in first.');
      return;
    }

    final bandName = _bandNameController.text.trim();
    final description = _descriptionController.text.trim();

    if (bandName.isEmpty) {
      _showMessage('Please enter a band name.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bandDoc = _bandsCollection.doc();
      final joinCode = _generateJoinCode();

      await bandDoc.set({
        'id': bandDoc.id,
        'name': bandName,
        'description': description,
        'joinCode': joinCode,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [user.uid],
        'memberRoles': {
          user.uid: 'admin',
        },
        'isDeleted': false,
      });

      await _setBandSessionAndEnterApp(
        bandId: bandDoc.id,
        bandName: bandName,
        joinCode: joinCode,
      );
    } catch (e) {
      _showMessage('Could not create band.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _joinBand() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('You must be logged in first.');
      return;
    }

    final joinCode = _joinCodeController.text.trim().toUpperCase();

    if (joinCode.isEmpty) {
      _showMessage('Please enter a band code.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final query = await _bandsCollection
          .where('joinCode', isEqualTo: joinCode)
          .where('isDeleted', isEqualTo: false)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _showMessage('No band found with this code.');
        return;
      }

      final bandDoc = query.docs.first;
      final bandData = bandDoc.data();

      await _bandsCollection.doc(bandDoc.id).set({
        'members': FieldValue.arrayUnion([user.uid]),
        'memberRoles': {
          user.uid: 'member',
        },
      }, SetOptions(merge: true));

      await _setBandSessionAndEnterApp(
        bandId: bandDoc.id,
        bandName: bandData['name'] ?? 'Band',
        joinCode: bandData['joinCode'] ?? '',
      );
    } catch (e) {
      _showMessage('Could not join band.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _enterExistingBand(
      QueryDocumentSnapshot<Map<String, dynamic>> bandDoc,
      ) async {
    final data = bandDoc.data();

    await _setBandSessionAndEnterApp(
      bandId: bandDoc.id,
      bandName: data['name'] ?? 'Band',
      joinCode: data['joinCode'] ?? '',
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTexts.bodyM),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: BandmateHeader(),
      body: SingleChildScrollView(
        padding: AppPadding.allL,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Your Band', style: AppTexts.headM),
            const SizedBox(height: 8),
            Text(
              'Select one of your bands, create a new one, or join with a band code.',
              style: AppTexts.bodyM,
            ),
            const SizedBox(height: 16),

            if (user != null) _buildUserBandsList(user.uid),

            const SizedBox(height: 16),
            _buildModeSelector(),
            const SizedBox(height: 16),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isCreateMode
                  ? _buildCreateBandCard()
                  : _buildJoinBandCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBandsList(String userId) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Bands', style: AppTexts.headS),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _bandsCollection
                .where('members', arrayContains: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _InfoBox(text: 'Could not load your bands.');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              final activeBands = docs.where((doc) {
                final data = doc.data();
                return data['isDeleted'] != true;
              }).toList();

              if (activeBands.isEmpty) {
                return _InfoBox(
                  text:
                  'You are not in any band yet. Create one or join with a code.',
                );
              }

              return Column(
                children: activeBands.map((bandDoc) {
                  return _BandCard(
                    bandDoc: bandDoc,
                    isLoading: _isLoading,
                    onEnter: () => _enterExistingBand(bandDoc),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      width: double.infinity,
      padding: AppPadding.allM,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              title: 'Create Band',
              selected: _isCreateMode,
              onTap: () {
                setState(() {
                  _isCreateMode = true;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeButton(
              title: 'Join Band',
              selected: !_isCreateMode,
              onTap: () {
                setState(() {
                  _isCreateMode = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateBandCard() {
    return _SectionCard(
      key: const ValueKey('create'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.add_circle_outline,
            title: 'Create a New Band',
          ),
          const SizedBox(height: 16),
          _InputField(
            controller: _bandNameController,
            hintText: 'Band name',
            icon: Icons.groups_2_outlined,
          ),
          const SizedBox(height: 12),
          _InputField(
            controller: _descriptionController,
            hintText: 'Short description',
            icon: Icons.edit_note_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _MainButton(
            text: 'Create Band',
            icon: Icons.music_note,
            isLoading: _isLoading,
            onPressed: _createBand,
          ),
        ],
      ),
    );
  }

  Widget _buildJoinBandCard() {
    return _SectionCard(
      key: const ValueKey('join'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.login,
            title: 'Join an Existing Band',
          ),
          const SizedBox(height: 16),
          _InputField(
            controller: _joinCodeController,
            hintText: 'Enter band code',
            icon: Icons.key,
          ),
          const SizedBox(height: 16),
          _MainButton(
            text: 'Join Band',
            icon: Icons.group_add_outlined,
            isLoading: _isLoading,
            onPressed: _joinBand,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _BandCard extends StatelessWidget {
  const _BandCard({
    required this.bandDoc,
    required this.isLoading,
    required this.onEnter,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> bandDoc;
  final bool isLoading;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final data = bandDoc.data();

    final bandName = data['name'] ?? 'Unnamed Band';
    final description = data['description'] ?? '';
    final joinCode = data['joinCode'] ?? '';
    final members = data['members'];

    int memberCount = 0;
    if (members is List) {
      memberCount = members.length;
    }

    return Padding(
      padding: AppPadding.vertS,
      child: Row(
        children: [
          Container(
            padding: AppPadding.allM,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.groups_2,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bandName, style: AppTexts.bodyL),
                if (description.toString().isNotEmpty)
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTexts.bodyS,
                  ),
                const SizedBox(height: 4),
                Text(
                  '$memberCount members • Code: $joinCode',
                  style: AppTexts.bodyS,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onEnter,
            icon: Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppPadding.allM,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: selected
                ? AppTexts.button
                : AppTexts.bodyM.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: AppTexts.headS),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      style: AppTexts.bodyM,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hintText,
        hintStyle: AppTexts.bodyM,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: AppPadding.allM,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  const _MainButton({
    required this.text,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.white,
          ),
        )
            : Icon(icon, color: AppColors.white, size: 16),
        label: Text(
          isLoading ? 'Please wait...' : text,
          style: AppTexts.button,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.vertS,
      child: Text(text, style: AppTexts.bodyM),
    );
  }
}