import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import untuk Timer

void main() {
  runApp(const MonitoringApp());
}

class MonitoringApp extends StatelessWidget {
  const MonitoringApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring Dashboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: const Color(0xFF95EC69),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF95EC69),
          secondary: Color(0xFF95EC69),
        ),
      ),
      home: const MonitoringDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MonitoringDashboard extends StatefulWidget {
  const MonitoringDashboard({Key? key}) : super(key: key);

  @override
  State<MonitoringDashboard> createState() => _MonitoringDashboardState();
}

class _MonitoringDashboardState extends State<MonitoringDashboard> {
  bool aiMode = false;
  Map<String, dynamic> monitoringData = {};
  late Timer _timer; // Timer untuk periodik fetching data

  @override
  void initState() {
    super.initState();
    fetchMonitoringData(); // Fetch data awal
    _startPeriodicFetch(); // Start fetching data secara berkala
  }

  // Fungsi untuk memulai fetching data setiap 10 detik
  void _startPeriodicFetch() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchMonitoringData();
    });
  }

  // Pastikan Timer dibatalkan saat widget dihancurkan
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Ambil data dari API
  Future<void> fetchMonitoringData() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.100.6:3000/api/sensor-data'));

      if (response.statusCode == 200) {
        // Jika request berhasil, parse JSON dan perbarui monitoringData
        setState(() {
          monitoringData = json.decode(response.body);
        });
      } else {
        // Jika request gagal, tampilkan error
        print('Failed to load data');
      }
    } catch (e) {
      // Tangani jika terjadi error
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Rumah Dimas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Temperature Statistics moved to the top
            _buildTemperatureStats(),
            const SizedBox(height: 24),

            // Current Readings moved to the second position
            _buildCurrentReadings(),
            const SizedBox(height: 24),

            // Additional Data
            _buildAdditionalData(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentReadings() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Readings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    monitoringData['nilai_suhu_max_humid_max'] != null &&
                            (monitoringData['nilai_suhu_max_humid_max'] as List)
                                .isNotEmpty
                        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                            DateTime.parse(
                              monitoringData['nilai_suhu_max_humid_max'][0]
                                  ['timestamp'],
                            ),
                          )
                        : 'No data available',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              Icon(
                Icons.more_vert,
                color: Colors.grey[400],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Display data from API
          if (monitoringData['nilai_suhu_max_humid_max'] != null &&
              (monitoringData['nilai_suhu_max_humid_max'] as List).isNotEmpty)
            ...((monitoringData['nilai_suhu_max_humid_max'] as List)
                .map<Widget>((data) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMetricCard('ID', '${data['idx']}', Icons.fingerprint),
                    _buildMetricCard(
                        'Temperature', '${data['suhu']}°C', Icons.thermostat),
                    _buildMetricCard(
                        'Humidity', '${data['humid']}%', Icons.water_drop),
                    _buildMetricCard('Brightness', '${data['kecerahan']}%',
                        Icons.brightness_5),
                  ],
                ),
              );
            }).toList())
          else
            Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemperatureStats() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temperature Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Max', '${monitoringData['suhumax']}°C'),
              _buildStatCard('Min', '${monitoringData['suhumin']}°C'),
              _buildStatCard('Avg', '${monitoringData['suhurata']}°C'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalData() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (monitoringData['month_year_max'] != null &&
              monitoringData['month_year_max'].length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCard(
                  'Month-Year 1',
                  monitoringData['month_year_max'][0]['month_year'],
                  Icons.date_range,
                ),
                _buildMetricCard(
                  'Month-Year 2',
                  monitoringData['month_year_max'][1]['month_year'],
                  Icons.date_range,
                ),
              ],
            )
          else
            Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14, // Font size adjusted
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
