import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/contact_helper.dart';
import '../../bloc/debt/debt_bloc.dart';
import '../../bloc/debt/debt_event.dart';
import '../../bloc/debt/debt_state.dart';
import '../../../domain/entities/debt.dart';

class AddDebtPage extends StatefulWidget {
  const AddDebtPage({super.key});

  @override
  State<AddDebtPage> createState() => _AddDebtPageState();
}

class _AddDebtPageState extends State<AddDebtPage> {
  final _amountController = TextEditingController();
  final _searchController = TextEditingController();
  final _manualNameController = TextEditingController();
  final _manualPhoneController = TextEditingController();
  
  DebtType _selectedType = DebtType.lended;
  Contact? _selectedContact;
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isSearching = false;
  bool _isManualMode = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await ContactHelper.getContacts();
    setState(() {
      _allContacts = contacts;
      _filteredContacts = contacts;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _filteredContacts = ContactHelper.filterContacts(_allContacts, query);
    });
  }

  void _submit() {
    if (_amountController.text.isEmpty) return;
    
    String personName;
    String? phoneNumber;

    if (_isManualMode) {
      if (_manualNameController.text.isEmpty) return;
      personName = _manualNameController.text;
      phoneNumber = _manualPhoneController.text.isNotEmpty ? _manualPhoneController.text : null;
    } else {
      if (_selectedContact == null) return;
      personName = _selectedContact!.displayName;
      phoneNumber = _selectedContact!.phones.isNotEmpty
          ? _selectedContact!.phones.first.number
          : null;
    }

    final debt = DebtEntity(
      id: const Uuid().v4(),
      personName: personName,
      phoneNumber: phoneNumber,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      dateTime: DateTime.now(),
      type: _selectedType,
    );

    context.read<DebtBloc>().add(AddDebtRequested(debt));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return BlocListener<DebtBloc, DebtState>(
      listener: (context, state) {
        if (state.addSuccess) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: Text("NEW ENTRY",
              style: TextStyle(
                  letterSpacing: 2, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AMOUNT INPUT
              Center(
                child: Column(
                  children: [
                    Text("AMOUNT",
                        style: TextStyle(
                            color: (isDark ? Colors.white : Colors.black).withOpacity(0.38),
                            fontSize: 12,
                            letterSpacing: 2)),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: "0.00",
                        hintStyle: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.12)),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // TYPE SELECTOR
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _typeButton("LENDED", DebtType.lended, Colors.greenAccent, isDark),
                    _typeButton("BORROWED", DebtType.borrowed, Colors.orangeAccent, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // WHO SECTION HEADER WITH TOGGLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("WHO?",
                      style: TextStyle(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.38), 
                          fontSize: 12, 
                          letterSpacing: 2)),
                  GestureDetector(
                    onTap: () => setState(() {
                      _isManualMode = !_isManualMode;
                      _isSearching = false;
                    }),
                    child: Text(
                      _isManualMode ? "CHOOSE CONTACT" : "ADD MANUALLY",
                      style: const TextStyle(
                        color: Color(0xFF00FF88),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (_isManualMode)
                _buildManualEntryFields(isDark)
              else if (_selectedContact != null && !_isSearching)
                _buildSelectedContact(isDark)
              else
                _buildContactSearchField(isDark),

              if (!_isManualMode && _isSearching) _buildContactList(isDark),

              const SizedBox(height: 60),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF88),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 10,
                    shadowColor: const Color(0xFF00FF88).withOpacity(0.4),
                  ),
                  child: const Text("SAVE ENTRY",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntryFields(bool isDark) {
    return Column(
      children: [
        _buildTextField(_manualNameController, "Person Name", Icons.person_outline, isDark),
        const SizedBox(height: 12),
        _buildTextField(_manualPhoneController, "Phone Number (Optional)", Icons.phone_outlined, isDark, keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.24)),
        prefixIcon: Icon(icon, color: const Color(0xFF00FF88)),
        filled: true,
        fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: const Color(0xFF00FF88).withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _typeButton(String label, DebtType type, Color activeColor, bool isDark) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? activeColor.withOpacity(0.3) : Colors.transparent),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSelected ? activeColor : (isDark ? Colors.white24 : Colors.black26),
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedContact(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF00FF88).withOpacity(0.1),
            child: Text(_selectedContact!.displayName.isNotEmpty ? _selectedContact!.displayName[0] : "?",
                style: const TextStyle(color: Color(0xFF00FF88))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedContact!.displayName,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                if (_selectedContact!.phones.isNotEmpty)
                  Text(_selectedContact!.phones.first.number,
                      style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.38), fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF00FF88), size: 20),
            onPressed: () => setState(() => _isSearching = true),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSearchField(bool isDark) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearch,
      onTap: () => setState(() => _isSearching = true),
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: "Search phone contacts...",
        hintStyle: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.24)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF88)),
        filled: true,
        fillColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: const Color(0xFF00FF88).withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildContactList(bool isDark) {
    return Container(
      height: 300,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ListView.builder(
          itemCount: _filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = _filteredContacts[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                child: Text(contact.displayName.isNotEmpty ? contact.displayName[0] : "?",
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
              ),
              title: Text(contact.displayName,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14)),
              subtitle: Text(
                  contact.phones.isNotEmpty ? contact.phones.first.number : "No number",
                  style: TextStyle(color: (isDark ? Colors.white : Colors.black).withOpacity(0.38), fontSize: 11)),
              onTap: () {
                setState(() {
                  _selectedContact = contact;
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            );
          },
        ),
      ),
    );
  }
}
