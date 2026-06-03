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
  bool _deleting = false;
  String? _restoringSnapshotId;
  String? _errorText;
  List<SnapshotMeta> _snapshots = const [];
  final Set<String> _selectedSnapshotIds = {};

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
        _snapshots = items.take(5).toList(growable: false);
        _selectedSnapshotIds.removeWhere(
          (id) => !_snapshots.any((item) => item.snapshotId == id),
        );
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

  Future<void> _deleteSelectedSnapshots() async {
    if (_selectedSnapshotIds.isEmpty || _deleting) return;

    final count = _selectedSnapshotIds.length;
    final confirmed = await _confirmDelete(
      title: '선택한 스냅샷 삭제',
      content: '선택한 스냅샷 $count개를 삭제합니다. 삭제 후에는 복원할 수 없습니다.',
      actionLabel: '선택 삭제',
    );
    if (confirmed != true || !mounted) return;

    final ids = _selectedSnapshotIds.toList(growable: false);
    await _runDelete(() async {
      for (final snapshotId in ids) {
        await _snapshotService.deleteSnapshot(widget.user.uid, snapshotId);
      }
    }, '선택한 스냅샷을 삭제했습니다.');
  }

  Future<void> _deleteAllSnapshots() async {
    if (_snapshots.isEmpty || _deleting) return;

    final confirmed = await _confirmDelete(
      title: '전체 스냅샷 삭제',
      content: '저장된 스냅샷을 모두 삭제합니다. 삭제 후에는 복원할 수 없습니다.',
      actionLabel: '전체 삭제',
    );
    if (confirmed != true || !mounted) return;

    await _runDelete(
      () => _snapshotService.deleteAllSnapshots(widget.user.uid),
      '전체 스냅샷을 삭제했습니다.',
    );
  }

  Future<void> _runDelete(
    Future<void> Function() deleteAction,
    String successMessage,
  ) async {
    setState(() {
      _deleting = true;
    });

    try {
      await deleteAction();
      if (!mounted) return;
      _selectedSnapshotIds.clear();
      _showSnackBar(successMessage);
      await _loadSnapshots();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _showSnackBar(_firebaseMessage(e));
    } catch (e, st) {
      debugPrint('snapshot delete error: $e\n$st');
      if (!mounted) return;
      _showSnackBar('스냅샷 삭제에 실패했습니다. $e');
    } finally {
      if (mounted) {
        setState(() {
          _deleting = false;
        });
      }
    }
  }

  Future<bool?> _confirmDelete({
    required String title,
    required String content,
    required String actionLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
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
    final snapshotName =
        meta.name.trim().isEmpty ? '이름 없는 스냅샷' : meta.name.trim();
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
            '스냅샷 이름: $snapshotName\n'
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

  void _toggleSnapshotSelection(String snapshotId, bool selected) {
    setState(() {
      if (selected) {
        _selectedSnapshotIds.add(snapshotId);
      } else {
        _selectedSnapshotIds.remove(snapshotId);
      }
    });
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
                  onPressed: _loading || _deleting ? null : _loadSnapshots,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            if (_snapshots.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          _selectedSnapshotIds.isEmpty || _deleting
                              ? null
                              : _deleteSelectedSnapshots,
                      icon:
                          _deleting
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.delete_outline_rounded),
                      label: Text('선택 삭제 (${_selectedSnapshotIds.length})'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      ),
                      onPressed: _deleting ? null : _deleteAllSnapshots,
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('전체 삭제'),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                '최근 스냅샷은 최대 5개까지 보관됩니다. 복원 시 현재 로컬 데이터는 전체 덮어쓰기됩니다.',
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
        final isSelected = _selectedSnapshotIds.contains(item.snapshotId);
        final createdAt = DateFormat(
          'yyyy.MM.dd HH:mm',
        ).format(item.createdAt.toLocal());
        final snapshotName =
            item.name.trim().isEmpty ? '이름 없는 스냅샷' : item.name.trim();

        return Card(
          margin: EdgeInsets.zero,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color:
                  isSelected
                      ? AppColors.primary.withValues(alpha: 0.55)
                      : Theme.of(context).dividerColor.withValues(alpha: 0.20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged:
                          _deleting || isRestoring
                              ? null
                              : (checked) => _toggleSnapshotSelection(
                                item.snapshotId,
                                checked ?? false,
                              ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.cloud_done_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshotName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '백업 시간 $createdAt',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.mutedOf(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SnapshotInfoRow(label: '이름', value: snapshotName),
                _SnapshotInfoRow(label: '앱 버전', value: item.appVersion),
                _SnapshotInfoRow(
                  label: '크기',
                  value: _formatBytes(item.sizeBytes),
                ),
                _SnapshotInfoRow(label: '스냅샷 ID', value: item.snapshotId),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '복원하면 현재 기기의 로컬 데이터가 이 스냅샷으로 교체됩니다.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        isRestoring || _deleting ? null : () => _restore(item),
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

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes bytes';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}

class _SnapshotInfoRow extends StatelessWidget {
  const _SnapshotInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedOf(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: label == '스냅샷 ID' ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
