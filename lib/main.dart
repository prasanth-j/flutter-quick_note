import 'package:flutter/material.dart';
import 'package:notes/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quick Note',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  void refreshNotes() async {
    final data = await SqlHelper.getItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  final _noteForm = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  void showForm(int? id) async {
    if (id != null) {
      final existingNote = _items.firstWhere((element) => element['id'] == id);
      _title.text = existingNote['title'];
      _description.text = existingNote['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Form(
          key: _noteForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: _title,
                decoration: const InputDecoration(hintText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                controller: _description,
                decoration: const InputDecoration(hintText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_noteForm.currentState!.validate()) {
                    if (id == null) {
                      await addNote();
                    }

                    if (id != null) {
                      await updateNote(id);
                    }

                    _title.text = '';
                    _description.text = '';

                    Navigator.of(context).pop();
                  }
                },
                child: Text((id == null) ? 'Create' : 'Update'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Insert new note to the database
  Future<void> addNote() async {
    await SqlHelper.createItem(_title.text, _description.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note added successfully!'),
      ),
    );

    refreshNotes();
  }

  // Update an existing note
  Future<void> updateNote(int id) async {
    await SqlHelper.updateItem(id, _title.text, _description.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note updated successfully!'),
      ),
    );

    refreshNotes();
  }

  // Delete an existing note
  Future<void> deleteNote(int id) async {
    await SqlHelper.deleteItem(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note deleted successfully!'),
      ),
    );

    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Note'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) => Card(
                color: Colors.pink[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(_items[index]['title']),
                    subtitle: Text(_items[index]['description']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => showForm(_items[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteNote(_items[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showForm(null),
      ),
    );
  }
}
