import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late SharedPreferences _prefs;
  late TextEditingController _nameC;
  int dailyGoal = 3;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController();
    _load();
  }

  void _load() async {
    _prefs = await SharedPreferences.getInstance();
    _nameC.text = _prefs.getString('profile_name') ?? '';
    setState(()=> dailyGoal = _prefs.getInt('profile_goal') ?? 3);
  }

  void _save() {
    _prefs.setString('profile_name', _nameC.text.trim());
    _prefs.setInt('profile_goal', dailyGoal);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height:12),
          Row(children: [
            const Text('Daily goal:'),
            const SizedBox(width:12),
            DropdownButton<int>(value: dailyGoal, items: [1,2,3,5,8,10].map((n)=>DropdownMenuItem(value:n, child: Text('$n'))).toList(), onChanged: (v)=>setState(()=>dailyGoal=v ?? 3))
          ]),
          const SizedBox(height:20),
          ElevatedButton(onPressed: _save, child: const Text('Save'))
        ]),
      ),
    );
  }
}
