import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/route_observer.dart';
import '../core/services/reports_service.dart';
import '../core/models/report.dart';
import '../core/widgets/app_drawer.dart';
import 'report_detail_page.dart';

final myReportsProvider = FutureProvider.autoDispose<List<Report>>((ref) async {
  return await ref.read(reportsServiceProvider).getMyReports();
});

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modal = ModalRoute.of(context);
    if (modal != null) {
      routeObserver.subscribe(this, modal);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this route (another route was popped).
    // Invalidate so reports are refreshed.
    ref.invalidate(myReportsProvider);
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Botón destacado arriba
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF042A80), // azul solicitado
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/newReport');
                },
                child: const Text(
                  "Crear nuevo reporte",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          Expanded(
            child: reportsAsync.when(
              data: (reports) => GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
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

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailPage(report: report),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusColor, // fondo según status
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.network(
                                report.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white, // texto blanco
                                  ),
                                ),
                                Text(
                                  report.createdAt.toLocal().toString().split(
                                    ' ',
                                  )[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(
                child: Text(
                  "Error al cargar reportes: $err",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
