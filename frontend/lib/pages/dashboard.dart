import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<dynamic> _userStats = [];
  Timer? _refreshTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (t) => _fetchDashboardData());
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:4000/api/dashboard/all'));
      if (response.statusCode == 200) {
        setState(() {
          _userStats = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    }
    catch (e) {
      debugPrint("Error: $e");
    }
  }
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Color _getRiskColour(double score) {
    if (score < 0.3) return Colors.greenAccent;
    if (score < 0.7) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Monitor", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Real-time analysis of user request patterns", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _userStats.isEmpty 
                  ? const Center(child: Text("No active users. Go to the Users page to start a simulation."))
                  : _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
          columns: const [
            DataColumn(label: Text('USER ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('REQUESTS', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('RISK SCORE', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('DECISION', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('LAST SEEN', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _userStats.map((user) {
            double score = (user['riskScore'] ?? 0.0).toDouble();
            String decision = user['decision'] ?? 'ALLOW';
            
            return DataRow(cells: [
              DataCell(Text(user['userId'], style: const TextStyle(color: Colors.blueAccent))),
              DataCell(Text(user['totalEvents'].toString())),
              DataCell(Text(
                score.toStringAsFixed(2),
                style: TextStyle(color: _getRiskColour(score), fontWeight: FontWeight.bold),
              )),
              DataCell(_buildDecisionChip(decision)),
              DataCell(Text(
                DateTime.fromMillisecondsSinceEpoch(user['updatedAt']).toString().split(' ')[1].split('.')[0],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDecisionChip(String decision) {
    bool isThrottled = decision == 'THROTTLE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isThrottled ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isThrottled ? Colors.redAccent : Colors.greenAccent),
      ),
      child: Text(
        decision,
        style: TextStyle(
          color: isThrottled ? Colors.redAccent : Colors.greenAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}