

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class AddressBookPage extends StatefulWidget {
  final bool selectMode;

  const AddressBookPage({
    Key? key,
    this.selectMode = false,
  }) : super(key: key);

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  List addresses = [];
  bool loading = true;

  // Add controllers and state variables for add-address modal
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLineController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String _label = 'HOME';
  bool _isDefault = false;
  bool _saving = false;
  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _resetAddAddressFields() {
    _fullNameController.clear();
    _phoneController.clear();
    _addressLineController.clear();
    _cityController.clear();
    _stateController.clear();
    _pincodeController.clear();
    _label = 'HOME';
    _isDefault = false;
    _saving = false;
  }

  Future<void> _openAddAddressSheet() async {
    _resetAddAddressFields();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Add Address",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressLineController,
                      decoration: const InputDecoration(
                        labelText: "Address Line",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: "City",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: "State",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Pincode",
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('HOME'),
                          selected: _label == 'HOME',
                          onSelected: (selected) {
                            setModalState(() => _label = 'HOME');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('WORK'),
                          selected: _label == 'WORK',
                          onSelected: (selected) {
                            setModalState(() => _label = 'WORK');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('OTHER'),
                          selected: _label == 'OTHER',
                          onSelected: (selected) {
                            setModalState(() => _label = 'OTHER');
                          },
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Make this default"),
                      value: _isDefault,
                      onChanged: (val) {
                        setModalState(() => _isDefault = val ?? false);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                setModalState(() => _saving = true);
                                final uid = FirebaseAuth.instance.currentUser!.uid;
                                final body = {
                                  "firebase_uid": uid,
                                  "full_name": _fullNameController.text.trim(),
                                  "phone": _phoneController.text.trim(),
                                  "address_line": _addressLineController.text.trim(),
                                  "city": _cityController.text.trim(),
                                  "state": _stateController.text.trim(),
                                  "pincode": _pincodeController.text.trim(),
                                  "label": _label,
                                  "is_default": _isDefault ? 1 : 0,
                                };
                                final res = await http.post(
                                  Uri.parse('http://192.168.0.150:3000/address'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: json.encode(body),
                                );
                                setModalState(() => _saving = false);
                                if (res.statusCode == 200 || res.statusCode == 201) {
                                  Navigator.of(context).pop();
                                  _loadAddresses();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to add address')),
                                  );
                                }
                              },
                        child: _saving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("SAVE"),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final res = await http.get(
      Uri.parse('http://192.168.0.150:3000/address/$uid'),
    );

    if (res.statusCode == 200) {
      final List list = json.decode(res.body);
      list.sort((a, b) {
        if (a['is_default'] == b['is_default']) return 0;
        return a['is_default'] == 1 ? -1 : 1;
      });
      setState(() {
        addresses = list;
        loading = false;
      });
    }
  }

  Future<void> _setDefault(int id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await http.put(
      Uri.parse('http://192.168.0.150:3000/address/default/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'firebase_uid': uid}),
    );

    await _loadAddresses();
    if (widget.selectMode) {
      final selected = addresses.firstWhere((a) => a['id'] == id);
      final selectedAddressString =
          '${selected['full_name']}, ${selected['address_line']}, ${selected['city']}, ${selected['state']} - ${selected['pincode']}';

      Navigator.pop(context, selectedAddressString);
      return;
    }
    _showAddressChangedMessage();
  }

  void _showAddressChangedMessage() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Delivery address changed successfully',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 95, // sits just above FAB
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _delete(int id) async {
    await http.delete(
      Uri.parse('http://192.168.0.150:3000/address/$id'),
    );

    _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddAddressSheet,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? const Center(child: Text('No addresses saved'))
              : _AddressList(
                  addresses: addresses,
                  onSetDefault: _setDefault,
                  onDelete: _delete,
                ),
    );
  }
}
// --- Animated List Widget for address cards ---
class _AddressList extends StatefulWidget {
  final List addresses;
  final Future<void> Function(int id) onSetDefault;
  final Future<void> Function(int id) onDelete;
  const _AddressList({
    required this.addresses,
    required this.onSetDefault,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  State<_AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<_AddressList> with TickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Map<String, dynamic>> _addresses;
  bool _firstBuild = true;
  int? _movingUpId;
  int? _movingDownId;

  @override
  void initState() {
    super.initState();
    _addresses = List<Map<String, dynamic>>.from(widget.addresses);
  }

  @override
  void didUpdateWidget(covariant _AddressList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If addresses changed (by id order), animate the swap.
    final oldDefaultIdx = _addresses.indexWhere((a) => a['is_default'] == 1);
    final newDefaultIdx = widget.addresses.indexWhere((a) => a['is_default'] == 1);
    final oldDefaultId = oldDefaultIdx != -1 ? _addresses[oldDefaultIdx]['id'] : null;
    final newDefaultId = newDefaultIdx != -1 ? widget.addresses[newDefaultIdx]['id'] : null;

    if (!_firstBuild && oldDefaultId != null && newDefaultId != null && oldDefaultId != newDefaultId) {
      // Animate: move tapped card up to index 0, old default down.
      final tappedIdx = widget.addresses.indexWhere((a) => a['id'] == newDefaultId);
      final oldIdx = _addresses.indexWhere((a) => a['id'] == oldDefaultId);
      if (tappedIdx == 0 && oldIdx == 0) {
        // Already at top, just update.
        setState(() {
          _addresses = List<Map<String, dynamic>>.from(widget.addresses);
        });
        return;
      }
      // Remove tapped card from its old position, insert at 0.
      setState(() {
        _movingUpId = newDefaultId;
        _movingDownId = oldDefaultId;
      });
      // Remove tapped card from old position.
      final tappedOldIdx = _addresses.indexWhere((a) => a['id'] == newDefaultId);
      final tappedCard = _addresses.removeAt(tappedOldIdx);
      _listKey.currentState?.removeItem(
        tappedOldIdx,
        (context, animation) => _slideTransitionCard(
          card: tappedCard,
          animation: animation,
          direction: SlideDirection.up,
        ),
        duration: const Duration(milliseconds: 300),
      );
      // Insert tapped card at top.
      Future.delayed(const Duration(milliseconds: 10), () {
        setState(() {
          _addresses.insert(0, tappedCard);
        });
        _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
      });
      // Remove old default from top (if it was at index 0) and re-insert to its new position.
      if (oldIdx == 0) {
        final oldDefaultCard = _addresses.removeAt(1); // Because tapped card is now at 0
        _listKey.currentState?.removeItem(
          1,
          (context, animation) => _slideTransitionCard(
            card: oldDefaultCard,
            animation: animation,
            direction: SlideDirection.down,
          ),
          duration: const Duration(milliseconds: 300),
        );
        Future.delayed(const Duration(milliseconds: 10), () {
          setState(() {
            _addresses.insert(tappedOldIdx, oldDefaultCard);
          });
          _listKey.currentState?.insertItem(tappedOldIdx, duration: const Duration(milliseconds: 300));
        });
      }
      // After animation, reset.
      Future.delayed(const Duration(milliseconds: 350), () {
        setState(() {
          _addresses = List<Map<String, dynamic>>.from(widget.addresses);
          _movingUpId = null;
          _movingDownId = null;
        });
      });
    } else if (!_firstBuild && widget.addresses.length != _addresses.length) {
      // Address added or deleted, just update.
      setState(() {
        _addresses = List<Map<String, dynamic>>.from(widget.addresses);
      });
    } else if (_firstBuild) {
      _firstBuild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _addresses.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i, animation) {
        final a = _addresses[i];
        // If this card is moving, animate slide.
        if (_movingUpId != null && a['id'] == _movingUpId) {
          return _slideTransitionCard(card: a, animation: animation, direction: SlideDirection.up);
        }
        if (_movingDownId != null && a['id'] == _movingDownId) {
          return _slideTransitionCard(card: a, animation: animation, direction: SlideDirection.down);
        }
        return _buildAddressCard(context, a, i, animation);
      },
    );
  }

  Widget _slideTransitionCard({
    required Map<String, dynamic> card,
    required Animation<double> animation,
    required SlideDirection direction,
  }) {
    final offsetTween = direction == SlideDirection.up
        ? Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        : Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero);
    return SlideTransition(
      position: animation.drive(offsetTween),
      child: _buildAddressCard(context, card, null, kAlwaysCompleteAnimation),
    );
  }

  Widget _buildAddressCard(BuildContext context, Map<String, dynamic> a, int? idx, Animation<double> animation) {
    // Visually emphasize default, dim others, scale slightly.
    return AnimatedOpacity(
      opacity: a['is_default'] == 1 ? 1.0 : 0.6,
      duration: const Duration(milliseconds: 250),
      child: AnimatedScale(
        scale: a['is_default'] == 1 ? 1.0 : 0.98,
        duration: const Duration(milliseconds: 250),
        child: Container(
          key: ValueKey(a['id']),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.pink.shade700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (a['is_default'] == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Radio<int>(
                    value: a['id'],
                    groupValue: _addresses.firstWhere(
                      (e) => e['is_default'] == 1,
                      orElse: () => {'id': -1},
                    )['id'],
                    onChanged: (_) async {
                      // Only trigger if not already default
                      if (a['is_default'] != 1) {
                        await widget.onSetDefault(a['id']);
                      }
                    },
                    activeColor: Colors.pink.shade600,
                  ),
                  Expanded(
                    child: Text(
                      a['full_name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(a['address_line']),
              Text('${a['city']}, ${a['state']} - ${a['pincode']}'),
              const SizedBox(height: 8),
              Text('Phone: ${a['phone']}'),
              const Divider(height: 24),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => widget.onDelete(a['id']),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

enum SlideDirection { up, down }