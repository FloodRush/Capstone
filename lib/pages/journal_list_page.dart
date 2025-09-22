import 'package:flutter/material.dart';
import 'package:project/theme.dart';
import 'journal_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalListPage extends StatefulWidget {
  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final user = FirebaseAuth.instance.currentUser;
  Set<String> selected = {};

  Stream<QuerySnapshot> getEntriesStream() {
    return FirebaseFirestore.instance
      .collection('Entries')
      .where('uid', isEqualTo: user?.uid)
      .snapshots();
  }

  void _addEntry() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JournalPage()),
    );
    setState(() {}); // Refresh after add
  }

  void _editEntry(DocumentSnapshot entryDoc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalPage(
          initialTitle: entryDoc['name'] ?? '',
          initialDate: entryDoc['date'] ?? '',
          initialEntry: entryDoc['entry'] ?? '',
          onSave: (title, date, entryText) async {
            await entryDoc.reference.update({
              'name': title,
              'date': date,
              'entry': entryText,
            });
          },
        ),
      ),
    );
    setState(() {}); // Refresh after edit
  }

  void _viewEntry(DocumentSnapshot entryDoc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entryDoc['name'] ?? ''),
        content: Text('${entryDoc['date'] ?? ''}\n\n${entryDoc['entry'] ?? ''}'),
      ),
    );
  }

  void _deleteEntry(DocumentSnapshot entryDoc) async {
    await entryDoc.reference.delete();
    setState(() {}); // Refresh after delete
  }

  void _selectAll(List docs) {
    setState(() {
      selected = docs.map((d) => d.id as String).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7BDF0), Color(0xFFF7C7D7), Color(0xFFD6EAF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 8),
              Center(
                child: Text(
                  "Journal",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getEntriesStream(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data?.docs ?? [];
                    bool hasEntries = docs.isNotEmpty;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, size: 32),
                              tooltip: 'Add',
                              onPressed: _addEntry,
                            ),
                            SizedBox(width: 18),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 32),
                              tooltip: 'Delete',
                              onPressed: selected.isNotEmpty
                                  ? () {
                                      for (var id in selected) {
                                        _deleteEntry(docs.firstWhere((d) => d.id == id));
                                      }
                                      selected.clear();
                                    }
                                  : null,
                            ),
                            SizedBox(width: 18),
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 32),
                              tooltip: 'Edit',
                              onPressed: selected.length == 1
                                  ? () => _editEntry(docs.firstWhere((d) => selected.contains(d.id)))
                                  : null,
                            ),
                            SizedBox(width: 18),
                            IconButton(
                              icon: Icon(Icons.remove_red_eye_outlined, size: 32),
                              tooltip: 'View',
                              onPressed: selected.length == 1
                                  ? () => _viewEntry(docs.firstWhere((d) => selected.contains(d.id)))
                                  : null,
                            ),
                            SizedBox(width: 18),
                            IconButton(
                              icon: Icon(Icons.select_all, size: 32),
                              tooltip: 'Select All',
                              onPressed: docs.isNotEmpty ? () => _selectAll(docs) : null,
                            ),
                          ],
                        ),
                        hasEntries
                            ? Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final entryDoc = docs[index];
                                    final isSelected = selected.contains(entryDoc.id);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selected.remove(entryDoc.id);
                                          } else {
                                            selected.add(entryDoc.id);
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(22),
                                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 2))],
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(18.0),
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.grey.shade400, width: 2),
                                                  color: isSelected ? Colors.pink.shade100 : Colors.white,
                                                ),
                                                child: isSelected
                                                    ? Icon(Icons.check, color: Colors.pink, size: 18)
                                                    : null,
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(entryDoc['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                                    SizedBox(height: 6),
                                                    Text(entryDoc['date'] ?? '', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                                                    SizedBox(height: 6),
                                                    Text(entryDoc['entry'] ?? '', style: TextStyle(fontSize: 16, color: Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Expanded(
                                child: Center(
                                  child: Text(
                                    "Start your journaling journey today! Tap + to add your first entry.",
                                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
