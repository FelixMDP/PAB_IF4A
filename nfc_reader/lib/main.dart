import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NFCReaderScreen(),
    );
  }
}

class NFCReaderScreen extends StatefulWidget {
  const NFCReaderScreen({super.key});

  @override
  State<NFCReaderScreen> createState() => _NFCReaderScreenState();
}

class _NFCReaderScreenState extends State<NFCReaderScreen> {
  final List<String> _nfcIds = [];
  bool _isScanning = false;
  double _progressValue = 0.0;
  Color _statusColor = Colors.blue;
  String _statusText = "Tekan tombol untuk memulai pemindaian";

  @override
  void initState() {
    super.initState();
    _checkNFCAvailability();
  }

  void _checkNFCAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _nfcIds.add("NFC tidak tersedia pada perangkat ini");
      });
    }
  }

  void _startNFCScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _progressValue = 0.2;
      _statusColor = Colors.orange;
      _statusText = "Scanning NFC...";
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var nfcData = tag.data;
        String? nfcId = nfcData['nfca']?['identifier']?.toString();
        String timeStamp = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(DateTime.now());
        if (nfcId != null) {
          setState(() {
            _nfcIds.insert(0, "$timeStamp - NFC ID: $nfcId");
            _progressValue = 1.0;
            _statusColor = Colors.green;
            _statusText = "Kartu berhasil dibaca!";
          });
        } else {
          setState(() {
            _nfcIds.insert(0, "$timeStamp - Tidak dapat membaca ID NFC");
            _progressValue = 1.0;
            _statusColor = Colors.red;
            _statusText = "Gagal membaca kartu";
          });
        }
      },
    );
  }

  void _stopNFCScan() async {
    await NfcManager.instance.stopSession();
    setState(() {
      _isScanning = false;
      _progressValue = 0.0;
      _statusColor = Colors.blue;
      _statusText = "Tekan tombol untuk memulai pemindaian";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NFC Reader")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _statusText,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            AnimatedContainer(
              duration: Duration(seconds: 1),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isScanning ? Colors.orangeAccent : Colors.grey,
              ),
              child: Icon(Icons.nfc, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: _progressValue,
              minHeight: 8,
              backgroundColor: Colors.grey,
              color: _statusColor,
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: _nfcIds.length,
                  itemBuilder: (context, index) {
                    String entry = _nfcIds[index];
                    List<String> parts = entry.split(' - NFC ID: ');
                    String timeStamp = parts[0];
                    String nfcId = parts.length > 1
                        ? parts[1]
                        : "Tidak dapat membaca ID NFC";

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeStamp,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(nfcId, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        // title: Text(_nfcIds[index], style: TextStyle(fontSize: 16)),
                        // leading: Icon(Icons.history, color: Colors.blueAccent),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startNFCScan,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Mulai Scan",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopNFCScan,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Stop Scan",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
