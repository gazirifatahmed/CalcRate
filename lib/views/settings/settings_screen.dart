import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/calculator_viewmodel.dart';
import 'share_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CalculatorViewModel>(context);
    final isDarkMode = viewModel.isDarkMode;
    final isSoundEnabled = viewModel.isSoundEnabled;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F11) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.amber, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings', 
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF0F0F11) : const Color(0xFFF5F5F7),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDarkMode ? [] : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    Icons.dark_mode, 
                    Colors.indigo, 
                    'Night Mode', 
                    isDarkMode: isDarkMode,
                    trailing: Switch(
                      value: isDarkMode, 
                      onChanged: (v) => viewModel.toggleTheme(v),
                      activeThumbColor: Colors.green,
                    )
                  ),
                  Divider(color: isDarkMode ? Colors.black26 : Colors.grey[200], height: 1, indent: 50),
                  // নতুন সাউন্ড অন/অফ টগল বাটন
                  _buildSettingTile(
                    Icons.volume_up, 
                    Colors.redAccent, 
                    'Sound', 
                    isDarkMode: isDarkMode,
                    trailing: Switch(
                      value: isSoundEnabled, 
                      onChanged: (v) => viewModel.toggleSound(v),
                      activeThumbColor: Colors.green,
                    )
                  ),
                  Divider(color: isDarkMode ? Colors.black26 : Colors.grey[200], height: 1, indent: 50),
                  _buildSettingTile(
                    Icons.share, 
                    Colors.teal, 
                    'Share', 
                    isDarkMode: isDarkMode,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShareScreen())),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14)
                  ),
                  Divider(color: isDarkMode ? Colors.black26 : Colors.grey[200], height: 1, indent: 50),
                  _buildSettingTile(
                    Icons.description, 
                    Colors.purple, 
                    'Agreements', 
                    isDarkMode: isDarkMode,
                    onTap: () => _showPopupMenu(context),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'CalcRate v1.0', 
              style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black45, fontSize: 14, fontWeight: FontWeight.w500)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, Color iconBg, String title, {required bool isDarkMode, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      title: Text(
        title, 
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16)
      ),
      trailing: trailing,
    );
  }

  void _showPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(40, 290, 40, 0), // একটু নিচে নামানো হয়েছে যাতে সাউন্ড রোর সাথে ওভারল্যাপ না করে
      color: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        PopupMenuItem(
          onTap: () => _launchURL("https://www.termsfeed.com/live/b43aa8b2-12fd-426e-8c83-3399b0d37985"),
          child: const Text('Privacy Policy', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem(
          onTap: () => _launchURL("https://www.termsfeed.com/live/7fc90416-9c91-4663-aaba-11a30972ba80"),
          child: const Text('Terms Of Use', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $urlString");
      }
    } catch (e) {
      debugPrint("Error launching url: $e");
    }
  }
}