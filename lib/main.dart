 import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

 Future<void> sendSMS(String message) async {
  const twilioNumber = "12345678"; // fake number for testing

  final uri = Uri.parse("sms:$twilioNumber?body=${Uri.encodeComponent(message)}");

  if (!await launchUrl(uri)) {
    throw Exception("Could not launch SMS app");
  }
}


 

void main() {
runApp(const MessagingApp());
}

class MessagingApp extends StatefulWidget {
const MessagingApp({super.key});

@override
State<MessagingApp> createState() => _MessagingAppState();
}

class _MessagingAppState extends State<MessagingApp> {
ThemeMode _themeMode = ThemeMode.light;

void toggleTheme() {
setState(() {
_themeMode =
_themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
});
}

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: "Inquiry SMS App",
theme: ThemeData(
brightness: Brightness.light,
primaryColor: const Color(0xFF6C3CF0), // Purple aesthetic
scaffoldBackgroundColor: Colors.white,
),
darkTheme: ThemeData(
brightness: Brightness.dark,
primaryColor: const Color(0xFF8A63FF),
scaffoldBackgroundColor: const Color(0xFF121212),
),
themeMode: _themeMode,
home: MainPage(onToggleTheme: toggleTheme),
);
}
}

class MainPage extends StatefulWidget {
final VoidCallback onToggleTheme;

const MainPage({super.key, required this.onToggleTheme});

@override
State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
List<String> conversations = [];
int selectedConversation = -1;
Map<String, List<String>> messages = {};

final TextEditingController _controller = TextEditingController();

bool sidebarOpen = true; // ← NEW (for sliding sidebar)

Future<void> sendSMS(String message) async {
const twilioNumber = "YOUR_FAKE_TWILIO_NUMBER";

final uri = Uri(
scheme: "sms",
path: twilioNumber,
queryParameters: {"body": message},
);

await launchUrl(uri);
}

void createConversation() {
final TextEditingController nameCtrl = TextEditingController();

showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Text("Name your conversation"),
content: TextField(
controller: nameCtrl,
decoration: const InputDecoration(hintText: "e.g. Science Project"),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text("Cancel"),
),
TextButton(
onPressed: () {
String name = nameCtrl.text.trim();
if (name.isEmpty) return;

setState(() {
conversations.add(name);
messages[name] = [];
selectedConversation = conversations.length - 1;
});

Navigator.pop(context);
},
child: const Text("Create"),
),
],
);
},
);
}

@override
Widget build(BuildContext context) {
String convoName =
selectedConversation >= 0 ? conversations[selectedConversation] : "";

return Scaffold(
body: Row(
children: [
// --------------------------
// LEFT SLIDING SIDEBAR
// --------------------------
AnimatedContainer(
duration: const Duration(milliseconds: 300),
curve: Curves.easeInOut,
width: sidebarOpen ? 260 : 0,
child: sidebarOpen
? Container(
decoration: BoxDecoration(
color: Theme.of(context).brightness == Brightness.light
? const Color(0xFFF5F4FA)
: const Color(0xFF1C1B20),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 6,
offset: const Offset(2, 0),
)
],
),
child: Column(
children: [
const SizedBox(height: 25),

// Collapse button
Align(
alignment: Alignment.centerLeft,
child: IconButton(
icon: const Icon(Icons.arrow_back_ios),
onPressed: () {
setState(() => sidebarOpen = false);
},
),
),

const SizedBox(height: 5),

// Create new convo button
FilledButton(
style: FilledButton.styleFrom(
backgroundColor: Theme.of(context).primaryColor,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(30)),
padding: const EdgeInsets.symmetric(
horizontal: 20, vertical: 14),
),
onPressed: createConversation,
child: const Text("Create New Conversation",
style: TextStyle(fontSize: 14)),
),

const SizedBox(height: 20),

// No conversations text
if (conversations.isEmpty)
const Padding(
padding: EdgeInsets.all(20),
child: Text(
"No conversations created.",
style: TextStyle(
fontSize: 16, fontStyle: FontStyle.italic),
),
),

// Conversations list
if (conversations.isNotEmpty)
Expanded(
child: ListView.builder(
itemCount: conversations.length,
itemBuilder: (context, index) {
final bool isSelected =
index == selectedConversation;
return Container(
decoration: BoxDecoration(
color: isSelected
? Theme.of(context)
.primaryColor
.withOpacity(0.15)
: Colors.transparent,
borderRadius: BorderRadius.circular(12),
),
margin: const EdgeInsets.symmetric(
horizontal: 10, vertical: 6),
child: ListTile(
title: Text(conversations[index]),
onTap: () {
setState(() {
selectedConversation = index;
});
},
),
);
},
),
),
],
),
)
: null,
),

// --------------------------------
// MAIN CHAT AREA
// --------------------------------
Expanded(
child: Column(
children: [
// --------------------------
// TOP APPBAR
// --------------------------
Container(
padding:
const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
color: Theme.of(context).primaryColor,
child: Row(
children: [
// Re-open sidebar button
if (!sidebarOpen)
IconButton(
icon: const Icon(Icons.arrow_forward_ios,
color: Colors.white),
onPressed: () {
setState(() => sidebarOpen = true);
},
),

Expanded(
child: Text(
selectedConversation == -1
? "No Conversations Yet"
: convoName,
style: const TextStyle(
color: Colors.white, fontSize: 18),
),
),

IconButton(
icon:
const Icon(Icons.brightness_medium, color: Colors.white),
onPressed: widget.onToggleTheme,
),
],
),
),

// If nothing selected
if (selectedConversation == -1)
const Expanded(
child: Center(
child: Text(
"Create a conversation to start messaging.",
style: TextStyle(fontSize: 18, color: Colors.grey),
),
),
)
else
Expanded(
child: Column(
children: [
const SizedBox(height: 15),

// DATE
Text(
"October 15, 2024",
style: TextStyle(
color: Colors.grey.shade600, fontSize: 13),
),

const SizedBox(height: 15),

// -----------------------
// Messages List
// -----------------------
Expanded(
child: ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: messages[convoName]!.length,
itemBuilder: (context, index) {
String msg = messages[convoName]![index];

return Align(
alignment: Alignment.centerRight,
child: Container(
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(14),
boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 4,
offset: const Offset(0, 2),
)
],
),
child: Text(msg,
style: const TextStyle(fontSize: 16)),
),
);
},
),
),

// -----------------------
// INPUT FIELD
// -----------------------
Container(
padding: const EdgeInsets.symmetric(
horizontal: 12, vertical: 10),
decoration: BoxDecoration(
color: Theme.of(context).brightness ==
Brightness.light
? const Color(0xFFF0F2F7)
: const Color(0xFF1A1C20),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.1),
blurRadius: 5)
],
),
child: Row(
children: [
Expanded(
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(25),
),
child: TextField(
controller: _controller,
decoration: const InputDecoration(
hintText: "Type a message...",
border: InputBorder.none,
),
),
),
),
const SizedBox(width: 10),

// SEND BUTTON
CircleAvatar(
radius: 25,
backgroundColor:
Theme.of(context).primaryColor,
child: IconButton(
icon: const Icon(Icons.send,
color: Colors.white),
onPressed: () {
String text = _controller.text.trim();
if (text.isEmpty ||
selectedConversation == -1) return;

setState(() {
messages[conversations[
selectedConversation]]!
.add(text);
});

sendSMS(text);
_controller.clear();
},
),
)
],
),
),
],
),
),
],
),
)
],
),
);
}
}
