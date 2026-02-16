import 'package:flutter/material.dart';
import '../core/models/report.dart';
import 'fullscreen_image_page.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;
  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (report.status) {
      case 1:
        statusColor = Colors.green;
        break;
      case 2:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Reporte')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Imagen con loader y zoom
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImagePage(imageUrl: report.imageUrl),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 300,
                child: Image.network(
                  report.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black12,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Campos con estilo uniforme
          _buildField("Título", report.title),
          _buildField("Folio", report.folio),
          _buildField("Fecha de creación",
              report.createdAt.toLocal().toString().split(' ')[0]),
          _buildField("Descripción", report.description),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Estatus: ${report.status == 1 ? "Aceptado" : report.status == 2 ? "Rechazado" : "Pendiente"}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}