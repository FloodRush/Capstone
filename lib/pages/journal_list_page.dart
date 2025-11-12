import 'dart:math';

import 'package:flutter/material.dart';
import 'journal_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalListPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const JournalListPage({Key? key, this.onBackToHome}) : super(key: key);
  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final user = FirebaseAuth.instance.currentUser;
  Set<String> selected = {};
  final searchController = TextEditingController();
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
          initialTag: List<String>.from(entryDoc['tag'] ?? []),//requires more safety in case there are no tags
          
          onSave: (title, date, entry, tag) async {
            await entryDoc.reference.update({
              'name': title,
              'date': date,
              'entry': entry,
              'tag': tag,
            });
          },
        ),
      ),
    );
    setState(() {}); // Refresh after edit
  }

  void _deleteEntry(DocumentSnapshot entryDoc) async {
    await entryDoc.reference.delete();
    setState(() {}); // Refresh after delete
  }

  void _viewEntry(DocumentSnapshot entryDoc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(entryDoc['name'] ?? ''),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entryDoc['date'] ?? '', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 12),
              Text(entryDoc['entry'] ?? ''),
              Text((entryDoc['tag'] is List)  ? (entryDoc['tag'] as List) .map((t) => '#${t.toString().trim().toLowerCase()}') .join(' ')  : '#${entryDoc['tag']?.toString() ?? ''}', style: TextStyle(fontSize: 16),  maxLines: 1,  overflow: TextOverflow.ellipsis,),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _selectAll(List<DocumentSnapshot> docs) {
    setState(() {
      selected = docs.map((d) => d.id).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF181829) : Colors.transparent;
    final Color cardColor = isDark ? const Color(0xFF23233A) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color dateColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) return true;
        if (widget.onBackToHome != null) {
          debugPrint('Journal back: onBackToHome fired (tab mode)');
          widget.onBackToHome!();
          return false;
        }
        debugPrint('Journal back: no route to pop and onBackToHome==null');
        return true;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: isDark
              ? null
              : const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE7BDF0), Color(0xFFF7C7D7), Color(0xFFD6EAF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: textColor,
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else if (widget.onBackToHome != null) {
                            debugPrint('Journal back: onBackToHome fired (tab mode)');
                            widget.onBackToHome!();
                          } else {
                            debugPrint('Journal back: no route to pop and onBackToHome==null');
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Journal',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // --- Original body rent below ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getEntriesStream(),
                    builder: (context, snapshot) {
                      final docs = snapshot.data?.docs ?? [];
                      bool hasEntries = docs.isNotEmpty;
                  
                /*return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        ),
                      ),
      ),
                    Expanded(
                      child: hasEntries ? ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          return ListTile(
                            title: Text(doc['name'] ?? ''),
                            subtitle: Text(doc['date'] ?? ''), // Changed from `body:` to `subtitle:`
                          );
                        },
                    ) 
                    );*/      
                       return Column(
                        children: [     
                          // SizedBox(height: 8),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, size: 32, color: isDark ? Colors.white : Colors.black),
                                tooltip: 'Add',
                                onPressed: _addEntry,
                              ),
                              SizedBox(width: 18),
                              IconButton(
                                icon: Icon(Icons.delete_outline, size: 32, color: isDark ? Colors.white : Colors.black),
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
                                icon: Icon(Icons.edit_outlined, size: 32, color: isDark ? Colors.white : Colors.black),
                                tooltip: 'Edit',
                                onPressed: selected.length == 1
                                    ? () => _editEntry(docs.firstWhere((d) => selected.contains(d.id)))
                                    : null,
                              ),
                              SizedBox(width: 18),
                              IconButton(
                                icon: Icon(Icons.remove_red_eye_outlined, size: 32, color: isDark ? Colors.white : Colors.black),
                                tooltip: 'View',
                                onPressed: selected.length == 1
                                    ? () => _viewEntry(docs.firstWhere((d) => selected.contains(d.id)))
                                    : null,
                              ),
                              SizedBox(width: 18),
                              IconButton(
                                icon: Icon(Icons.select_all, size: 32, color: isDark ? Colors.white : Colors.black),
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
                                            color: cardColor,
                                            borderRadius: BorderRadius.circular(22),
                                            boxShadow: [
                                              if (!isDark)
                                                BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 2))
                                            ],
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
                                                    border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 2),
                                                    color: isSelected ? (isDark ? Colors.pink.shade200 : Colors.pink.shade100) : (isDark ? cardColor : Colors.white),
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
                                                      Text(entryDoc['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor)),
                                                      SizedBox(height: 6),
                                                      Text(entryDoc['date'] ?? '', style: TextStyle(fontSize: 15, color: dateColor)),
                                                      SizedBox(height: 6),
                                                      Text(entryDoc['entry'] ?? '', style: TextStyle(fontSize: 16, color: subTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                      SizedBox(height: 6),
                                                      Text((entryDoc['tag'] is List)  ? (entryDoc['tag'] as List)  .map((t) => '#${t.toString().trim().toLowerCase()}')  .join(' ')  : '#${entryDoc['tag']?.toString() ?? ''}', style: TextStyle(fontSize: 16, color: subTextColor), maxLines: 1,  overflow: TextOverflow.ellipsis,),
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
                                      style: TextStyle(fontSize: 18, color: subTextColor, fontWeight: FontWeight.w500),
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
      ),
    );
  }
}
