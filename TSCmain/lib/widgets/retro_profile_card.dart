

// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

/// RetroProfileCard: Aesthetic profile card with CRT flicker, editable fields, guest lock, and export.
class RetroProfileCard extends StatefulWidget {
  final File? avatarFile;
  const RetroProfileCard({Key? key, this.avatarFile}) : super(key: key);
  @override
  State<RetroProfileCard> createState() => _RetroProfileCardState();
}

class _RetroProfileCardState extends State<RetroProfileCard> {
  // Profile fields
  String name = 'HAERIN';
  String birth = '2004.05.15';
  String height = '167cm';
  String blood = 'A';
  String constellation = 'TAURUS';

  // Theme and guest mode
  String theme = 'pink'; // pink | beige | mint
  bool isGuest = true;
  bool _flickerOn = true;
  final GlobalKey _repaintKey = GlobalKey();

  // For button animations
  bool _avatarPressed = false;
  bool _rightPanelPressed = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _startFlicker();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: RepaintBoundary(
        key: _repaintKey,
        child: Container(
          decoration: BoxDecoration(
            color: _themeBg(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  _topBrowserBar(),
                  _addressBar(),
                  _heartRow(),
                  // --- Control strip below heart row ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _themeButton('pink'),
                            _themeButton('beige'),
                            _themeButton('mint'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => isGuest = !isGuest);
                            _savePrefs();
                          },
                          child: Text(isGuest ? 'GUEST MODE' : 'LOGGED IN'),
                        ),
                      ],
                    ),
                  ),
                  _mainContent(),
                  _loadingBar(),
                  // --- Export button after loading bar ---
                  TextButton(
                    onPressed: _exportAsImage,
                    child: const Text('EXPORT PROFILE'),
                  ),
                ],
              ),
              // --- CRT Flicker overlay ---
              if (_flickerOn)
                Positioned.fill(
                  child: IgnorePointer(
                    child: _crtFlickerOverlay(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _topBrowserBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFE9C9DD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: Row(
        children: [
          _dot(const Color(0xFFC9B8E6)),
          _dot(const Color(0xFFFFE7A3)),
          _dot(const Color(0xFFB7D8F2)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFD9EEF2),
              border: Border.all(color: Colors.black),
            ),
            child: const Text(
              'HAERIN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F1E8),
              border: Border.all(color: Colors.black),
            ),
            child: const Text(
              'LOOKING FOR ATTENTION !!!',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F1E8),
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: Row(
        children: const [
          Icon(Icons.refresh, size: 14),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'https://www.newjeans.com',
              style: TextStyle(fontSize: 11),
            ),
          ),
          Icon(Icons.mail_outline, size: 14),
        ],
      ),
    );
  }

  // ================= HEART STRIP =================
  Widget _heartRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          11,
          (_) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              Icons.favorite,
              size: 14,
              color: Color(0xFF3B3B3B),
            ),
          ),
        ),
      ),
    );
  }

  // ================= MAIN CONTENT =================
  Widget _mainContent() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => _avatarPressed = true),
            onTapUp: (_) => setState(() => _avatarPressed = false),
            onTapCancel: () => setState(() => _avatarPressed = false),
            child: AnimatedScale(
              scale: _avatarPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: _avatarPanel(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _editableLabelValue('NAME', name, (val) {
                  setState(() => name = val);
                  _savePrefs();
                }),
                _editableLabelValue('BIRTH', birth, (val) {
                  setState(() => birth = val);
                  _savePrefs();
                }),
                _editableLabelValue('HEIGHT', height, (val) {
                  setState(() => height = val);
                  _savePrefs();
                }),
                _editableLabelValue('BLOOD', blood, (val) {
                  setState(() => blood = val);
                  _savePrefs();
                }),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTapDown: (_) => setState(() => _rightPanelPressed = true),
            onTapUp: (_) => setState(() => _rightPanelPressed = false),
            onTapCancel: () => setState(() => _rightPanelPressed = false),
            child: AnimatedScale(
              scale: _rightPanelPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: _rightPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPanel() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFE9C9DD),
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            child: const Center(
              child: Text(
                '강해린',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Stack(
            children: [
              _checkerboardBackground(width: 100, height: 120),
              SizedBox(
                height: 120,
                width: 100,
                child: widget.avatarFile != null
                    ? Image.file(widget.avatarFile!, fit: BoxFit.cover)
                    : const Icon(Icons.person, size: 48),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rightPanel() {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONSTELLATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          _editableConstellation(),
        ],
      ),
    );
  }

  // ================= LOADING BAR =================
  Widget _loadingBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      child: Row(
        children: [
          const Text(
            'Loading...',
            style: TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.85,
                alignment: Alignment.centerLeft,
                child: Container(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _dot(Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _themeButton(String t) {
    return GestureDetector(
      onTap: () {
        setState(() => theme = t);
        _savePrefs();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: t == 'pink'
              ? const Color(0xFFE9C9DD)
              : t == 'beige'
                  ? const Color(0xFFF3E8D8)
                  : const Color(0xFFDFF2EC),
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }

  // --- Editable fields with guest lock ---
  Widget _editableLabelValue(String label, String value, void Function(String) onSave) {
    return GestureDetector(
      onTap: () async {
        if (isGuest) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Guest mode: editing locked')),
          );
          return;
        }
        await _editField(label, value, onSave);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 62,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            if (!isGuest)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.edit, size: 14, color: Colors.black.withOpacity(0.45)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _editableConstellation() {
    return GestureDetector(
      onTap: () async {
        if (isGuest) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Guest mode: editing locked')),
          );
          return;
        }
        await _editField('CONSTELLATION', constellation, (val) {
          setState(() => constellation = val);
          _savePrefs();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFC9B8E6),
          border: Border.fromBorderSide(const BorderSide(color: Colors.black)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              constellation,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isGuest)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(Icons.edit, size: 14, color: Colors.black.withOpacity(0.45)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _checkerboardBackground({required double width, required double height}) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CheckerboardPainter(),
    );
  }

  // --- CRT Flicker effect ---
  Widget _crtFlickerOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.transparent,
            Colors.white.withOpacity(0.08),
          ],
          stops: const [0, 0.5, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(
        painter: _CrtScanlinePainter(),
        child: Container(),
      ),
    );
  }

  // --- Dialog for editing fields ---
  Future<void> _editField(String label, String currentValue, void Function(String) onSave) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter $label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      onSave(result);
    }
  }

  // --- Persistence and flicker ---
  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      name = p.getString('name') ?? name;
      birth = p.getString('birth') ?? birth;
      height = p.getString('height') ?? height;
      blood = p.getString('blood') ?? blood;
      constellation = p.getString('constellation') ?? constellation;
      theme = p.getString('theme') ?? theme;
      isGuest = p.getBool('guest') ?? true;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    p.setString('name', name);
    p.setString('birth', birth);
    p.setString('height', height);
    p.setString('blood', blood);
    p.setString('constellation', constellation);
    p.setString('theme', theme);
    p.setBool('guest', isGuest);
  }

  void _startFlicker() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return false;
      setState(() => _flickerOn = !_flickerOn);
      return true;
    });
  }

  Future<void> _exportAsImage() async {
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/retro_profile.png');
      await file.writeAsBytes(pngBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile exported as image')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Color _themeBg() {
    switch (theme) {
      case 'beige':
        return const Color(0xFFF3E8D8);
      case 'mint':
        return const Color(0xFFDFF2EC);
      default:
        return const Color(0xFFD9EEF2);
    }
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double squareSize = 10;
    final paint1 = Paint()..color = const Color(0xFFE0E7EA);
    final paint2 = Paint()..color = const Color(0xFFBFD9DD);
    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isLightSquare = ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        final paint = isLightSquare ? paint1 : paint2;
        canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrtScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.10)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}