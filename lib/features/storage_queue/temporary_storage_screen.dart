import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/temporary_storage_service.dart';

class TemporaryStorageScreen extends StatefulWidget {
  const TemporaryStorageScreen({super.key});

  @override
  State<TemporaryStorageScreen> createState() => _TemporaryStorageScreenState();
}

class _TemporaryStorageScreenState extends State<TemporaryStorageScreen> {
  final TemporaryStorageService _storageService = TemporaryStorageService();
  bool _isLoading = true;
  String? _syncingId;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    await _storageService.initialize();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSync(String id) async {
    setState(() => _syncingId = id);
    await _storageService.syncRecord(id);
    if (mounted) {
      setState(() => _syncingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item berhasil disinkronkan ke server pusat!'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _storageService.pendingRecords;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temporary Storage',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${records.length} antrean foto & audit tersimpan secara lokal',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : records.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                CupertinoIcons.tray,
                                size: 54,
                                color: AppColors.textMuted,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada data pindaian di storage sementara',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Gunakan tombol scanner untuk memindai barang.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final item = records[index];
                            final bool isWarning = item.trustLevel == 'WARNING';
                            final bool isSynced =
                                item.syncStatus == SyncStatus.synced;
                            final formattedDate = DateFormat('dd MMM yyyy, HH:mm')
                                .format(item.capturedAt.toLocal());

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isWarning
                                      ? AppColors.orangeWarning.withValues(alpha: 0.4)
                                      : AppColors.border.withValues(alpha: 0.6),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x06000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.category,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSynced
                                              ? AppColors.greenLight
                                              : const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isSynced ? 'SYNCED' : 'PENDING SYNC',
                                          style: TextStyle(
                                            color: isSynced
                                                ? AppColors.green
                                                : AppColors.textSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Jumlah: ${item.finalCount} pcs (AI: ${item.detectedCount})',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Location & Mock Badge
                                  Row(
                                    children: [
                                      Icon(
                                        isWarning
                                            ? Icons.warning_amber_rounded
                                            : Icons.location_on_outlined,
                                        size: 14,
                                        color: isWarning
                                            ? AppColors.orangeWarning
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)} ${isWarning ? '(FLAGGED: FAKE GPS)' : '(VERIFIED)'}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isWarning
                                                ? AppColors.orangeWarning
                                                : AppColors.textSecondary,
                                            fontWeight: isWarning
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (!isSynced)
                                        TextButton(
                                          onPressed: _syncingId == item.id
                                              ? null
                                              : () => _handleSync(item.id),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            backgroundColor:
                                                AppColors.primaryBlue,
                                            foregroundColor: Colors.white,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: _syncingId == item.id
                                              ? const SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text(
                                                  'Sync',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
