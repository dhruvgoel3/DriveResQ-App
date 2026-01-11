import 'package:flutter/material.dart';

class ActiveRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const ActiveRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Active Request",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    request['status'].toString().toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: request['status'] == 'accepted'
                      ? Colors.green
                      : Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 12),

            _infoRow(Icons.location_on, request['locationName']),
            _infoRow(Icons.place, "Landmark: ${request['landmark']}"),
            _infoRow(
              Icons.directions_car,
              "Vehicle: ${request['vehicleType']}",
            ),
            _infoRow(Icons.warning, "Problem: ${request['problem']}"),

            if (request['description'] != null &&
                request['description'].toString().isNotEmpty)
              _infoRow(Icons.notes, request['description']),

            const SizedBox(height: 12),

            if (request['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  request['imageUrl'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
