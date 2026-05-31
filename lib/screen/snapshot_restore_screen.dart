import 'package:expense_diary/component/common/app_background.dart';
import 'package:expense_diary/const/app_colors.dart';
import 'package:expense_diary/features/backup/data/snapshot_service.dart';
import 'package:expense_diary/features/backup/domain/snapshot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class SnapshotRestoreScreen extends StatefulWidget {
  const SnapshotRestoreScreen({super.key, required this.user});

  final User user;

  @override
  State<SnapshotRestoreScreen> createState() => _SnapshotRestoreScreenState();
}

class _SnapshotRestoreScreenState extends State<SnapshotRestoreScreen> {
  bool _loading = true;
  String? _restoringSnapshotId;
  String? _errorText;
  List<SnapshotMeta> _snapshots = const [];

  SnapshotService get _snapshotService => GetIt.I<SnapshotService>();

  @override
  void initState() {
    super.initState();
    _loadSnapshots();
  }

  Future<void> _loadSnapshots() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final items = await _snapshotService.listSnapshots(widget.user.uid);
      if (!mounted) return;
      setState(() {
        _snapshots = items;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = _firebaseMessage(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = '스냅샷 목록을 불러오지 못했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _restore(SnapshotMeta meta) async {
    if (_restoringSnapshotId != null) return;

    final confirmed = await _confirmRestore(meta);
    if (confirmed != true || !mounted) return;

    setState(() {
      _restoringSnapshotId = meta.snapshotId;
    });

    try {
      final snapshot = await _snapshotService.downloadSnapshot(
        widget.user.uid,
        meta.snapshotId,
      );
      await _snapshotService.restoreSnapshotToLocal(snapshot);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('복원이 완료되었습니다. 로컬 데이터가 갱신되었습니다.')),
      );
      Navigator.of(context).pop(true);
    } on SnapshotIntegrityException catch (e) {
      if (!mounted) return;
      _showSnackBar('무결성 검증 실패로 복원을 중단했습니다. ${e.message}');
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _showSnackBar(_firebaseMessage(e));
    } catch (e, st) {
      debugPrint('restore error: $e\n$st');
      if (!mounted) return;
      _showSnackBar('복원에 실패했습니다. $e');
    } finally {
      if (mounted) {
        setState(() {
          _restoringSnapshotId = null;
        });
      }
    }
  }

  Future<bool?> _confirmRestore(SnapshotMeta meta) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              const SizedBox(width: 8),
              const Expanded(child: Text('복원 전 확인')),
            ],
          ),
          content: Text(
            '선택한 스냅샷으로 복원하면 현재 로컬 데이터(지출/카테고리)가 모두 삭제되고 스냅샷 내용으로 덮어써집니다.\n\n'
            '스냅샷 시각: ${DateFormat('yyyy.MM.dd HH:mm').format(meta.createdAt.toLocal())}\n'
            '크기: ${meta.sizeBytes} bytes\n'
            '계속 진행할까요?',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('전체 덮어쓰기 복원'),
            ),
          ],
        );
      },
    );
  }

  String _firebaseMessage(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' => '권한 오류로 스냅샷을 조회/복원할 수 없습니다.',
      'unauthenticated' => '인증이 만료되었습니다. 다시 로그인하세요.',
      'unavailable' => '네트워크 연결 문제로 복원하지 못했습니다.',
      _ => '복원 실패 (${e.code})',
    };
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '스냅샷 복원',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: _loading ? null : _loadSnapshots,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                '모든 플랜에서 무제한 복원 가능합니다. 복원 시 현재 로컬 데이터는 전체 덮어쓰기됩니다.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedOf(context),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSnapshots,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_errorText != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('스냅샷 목록 로드 실패'),
                  const SizedBox(height: 8),
                  Text(_errorText!),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: _loadSnapshots,
                      child: const Text('다시 시도'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_snapshots.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(
              '저장된 스냅샷이 없습니다.',
              style: TextStyle(color: AppColors.mutedOf(context)),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _snapshots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _snapshots[index];
        final isRestoring = _restoringSnapshotId == item.snapshotId;
        final createdAt = DateFormat(
          'yyyy.MM.dd HH:mm',
        ).format(item.createdAt.toLocal());

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        createdAt,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('schema ${item.schemaVersion}'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('snapshotId: ${item.snapshotId}'),
                Text('appVersion: ${item.appVersion}'),
                Text('size: ${item.sizeBytes} bytes'),
                Text(
                  'hash: ${item.dataHash.length >= 12 ? item.dataHash.substring(0, 12) : item.dataHash}...',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isRestoring ? null : () => _restore(item),
                    icon:
                        isRestoring
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.restore_rounded),
                    label: Text(isRestoring ? '복원 중...' : '이 스냅샷으로 복원'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
