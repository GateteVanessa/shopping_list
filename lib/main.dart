import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Item {
  String name;
  bool bought;
  int quantity;
  String note;
  String category;

  Item(
      this.name, {
        this.bought = false,
        this.quantity = 1,
        this.note = '',
        this.category = 'Food',
      });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const HomeScreen(title: 'Shopping List'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = TextEditingController();
  final List<Item> items = [Item('Milk'), Item('Bread'), Item('Rice')];
  String filter = 'All';

  void addItem() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final matches =
    items.where((i) => i.name.toLowerCase() == text.toLowerCase());

    if (matches.isNotEmpty) {
      final existing = matches.first;
      setState(() {
        existing.quantity++;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${existing.name} is already on the list: now ×${existing.quantity}'),
        ),
      );
    } else {
      setState(() {
        items.add(Item(text));
      });
    }
    controller.clear();
  }

  void removeItem(Item item) {
    final position = items.indexOf(item);
    setState(() {
      items.remove(item);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              items.insert(position, item);
            });
          },
        ),
      ),
    );
  }

  Widget filterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: filter == label,
        onSelected: (_) {
          setState(() {
            filter = label;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Item> shown;
    if (filter == 'To buy') {
      shown = items.where((i) => !i.bought).toList();
    } else if (filter == 'Bought') {
      shown = items.where((i) => i.bought).toList();
    } else {
      shown = [
        ...items.where((i) => !i.bought),
        ...items.where((i) => i.bought),
      ];
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'New item'),
                    onSubmitted: (_) => addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addItem, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                filterChip('All'),
                filterChip('To buy'),
                filterChip('Bought'),
              ],
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Your list is empty'))
                  : shown.isEmpty
                  ? const Center(child: Text('Nothing here'))
                  : ListView.builder(
                itemCount: shown.length,
                itemBuilder: (context, index) {
                  final item = shown[index];
                  return ListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.bought
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(item.note.isEmpty
                        ? item.category
                        : '${item.category} · ${item.note}'),
                    onTap: () {
                      setState(() {
                        item.bought = !item.bought;
                      });
                    },
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailsScreen(item: item),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (item.quantity > 1) {
                              setState(() {
                                item.quantity--;
                              });
                            }
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              item.quantity++;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removeItem(item),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  final Item item;
  const DetailsScreen({super.key, required this.item});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final nameController = TextEditingController();
  final noteController = TextEditingController();
  String category = 'Food';

  @override
  void initState() {
    super.initState();
    nameController.text = widget.item.name;
    noteController.text = widget.item.note;
    category = widget.item.category;
  }

  void save() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    widget.item.name = name;
    widget.item.note = noteController.text.trim();
    widget.item.category = category;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 12),
            Row(
              children: ['Food', 'Drinks', 'Home'].map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: category == c,
                    onSelected: (_) {
                      setState(() {
                        category = c;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}