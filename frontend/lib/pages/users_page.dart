import 'dart:async';
import 'package:flutter/material.dart';

class UserInstance {
  final String id;
  final String name;
  final bool isAutomatic;
  final int? interval;
  Timer? timer;

  UserInstance({required this.id, required this.name, required this.isAutomatic, this.interval});
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final List<UserInstance> _instances = [];

  void _sendRequest(String name) {
    print("Sending Request for $name");
  }

  void _showCreateDialog() {
    String name = "";
    int interval = 1000;
    bool isAuto = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add new user instance"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "User Name"),
                onChanged: (value) => name = value,
              ),
              SwitchListTile(value: isAuto, onChanged: (val) => setDialogState(() => isAuto = val)),
              if (isAuto) 
                TextField(
                  decoration: const InputDecoration(labelText: "Interval"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => interval = int.tryParse(value) ?? 1000,
                )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                _addInstance(name, isAuto, interval);
                Navigator.pop(context);
              }, 
              child: const Text("Create"),
            )
          ],
        )
      )
    );
  }

  void _addInstance(String name, bool isAuto, int interval) {
    final newInst = UserInstance(id: DateTime.now().toString(), name: name, isAutomatic: isAuto, interval: interval);

    if (isAuto) {
      newInst.timer = Timer.periodic(Duration(milliseconds: interval), (timer) => _sendRequest(name));
    }

    setState(() {
      _instances.add(newInst);
    });
  }

  void  _deleteInstance(UserInstance inst) {
    inst.timer?.cancel();
    setState(() {
      _instances.remove(inst);
    });
  }
  @override
  void dispose() {
    for (var inst in _instances) {
      inst.timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(onPressed: _showCreateDialog, child: const Icon(Icons.add),),
      body: Padding(padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: _instances.map((inst) => _buildUserCard(inst)).toList(),
        ),),
    );
  }

  Widget _buildUserCard(UserInstance inst) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(inst.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
          Text(inst.isAutomatic ? "(Auto: ${inst.interval}ms)" : "(Manual)", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!inst.isAutomatic) 
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue,),
                  onPressed: () => _sendRequest(inst.name),
                ),
              IconButton(
                onPressed: () => _deleteInstance(inst),
                icon: const Icon(Icons.close, color: Colors.redAccent,)
              ),
            ],
          )
        ],
      ),
    );
  }
}

