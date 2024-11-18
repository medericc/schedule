import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
 
  final DateTime date;
  final String player;

  Event({ required this.date, required this.player});
}

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Event> events = [
 ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUpcomingEvent();
    });
  }

  void _scrollToUpcomingEvent() {
    final now = DateTime.now();
    final index = events.indexWhere((event) => event.date.isAfter(now));
    if (index != -1) {
      _scrollController.animateTo(
        index * 100.0, // Ajustez cette valeur en fonction de la hauteur des éléments
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _addEvent( DateTime date, String player) {
    setState(() {
      events.add(Event( date: date, player: player));
      events.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  void _deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
  }
Color _getPlayerColor(String player) {
  switch (player) {
    case 'Carla':
      return Colors.red.shade700;
    case 'Inès':
      return Colors.blue;
    case 'Lou':
      return Colors.blue.shade900;
    case 'Jojo':
      return Colors.orange;
    case 'Lulu':
      return Colors.red;
    case 'Lena':
      return Colors.purple;
    case 'Maelys':
      return Colors.pink;
    case 'Messi':
      return Colors.black;
    default:
      return Colors.grey; // Couleur par défaut
  }
}
Icon _getPlayerIcon(String player) {
  if (player == 'Messi') {
    return Icon(Icons.sports_soccer, color: _getPlayerColor(player));
  }
  return Icon(Icons.sports_basketball, color: _getPlayerColor(player));
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newEvent = await _showAddEventDialog(context);
              if (newEvent != null) {
                _addEvent(newEvent['date'], newEvent['player']);
              }
            },
          ),
        ],
      ),
      body: events.isEmpty
          ? Center(child: Text('Aucun événement pour le moment.'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
  leading: _getPlayerIcon(event.player),
  title: Text(event.player),
  subtitle: Text('${DateFormat('EEEE HH:mm').format(event.date)}'),
  trailing: IconButton(
    icon: Icon(Icons.delete, color: Colors.red),
    onPressed: () => _deleteEvent(index),
  ),
),


                );
              },
            ),
    );
  }

  Future<Map<String, dynamic>?> _showAddEventDialog(BuildContext context) async {
  
    final _players = ['Lou', 'Inès', 'Carla','Jojo','Lulu','Lena','Maelys','Messi'];
    String? selectedPlayer;
    DateTime? selectedDate;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un événement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
               
                DropdownButtonFormField<String>(
                  value: selectedPlayer,
                  items: _players
                      .map((player) => DropdownMenuItem(value: player, child: Text(player)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedPlayer = value),
                  decoration: InputDecoration(labelText: 'Joueur'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );

                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        setState(() {
                          selectedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Text('Sélectionner la date et l\'heure'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (
                    selectedPlayer != null &&
                    selectedDate != null) {
                  Navigator.pop(context, {
                 
                    'date': selectedDate!,
                    'player': selectedPlayer!,
                  });
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
