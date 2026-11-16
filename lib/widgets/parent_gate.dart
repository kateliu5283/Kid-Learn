import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 兩步驟計算，避免低、中年級直接心算通過。
class ParentGateProblem {
  const ParentGateProblem({
    required this.a,
    required this.b,
    required this.c,
  });

  final int a;
  final int b;
  final int c;

  int get answer => a * b + c;

  String get prompt => '$a × $b + $c = ?';

  static ParentGateProblem random(Random rng) {
    return ParentGateProblem(
      a: 12 + rng.nextInt(8),
      b: 6 + rng.nextInt(4),
      c: 13 + rng.nextInt(37),
    );
  }
}

/// 答錯次數與鎖定時間寫在本機，關掉 App 再打開也不會重來。
class ParentGateLock {
  ParentGateLock._();

  static const untilKey = 'parent_gate_locked_until_v1';
  static const failuresKey = 'parent_gate_failures_v1';
  static const duration = Duration(minutes: 3);
  static const failureLimit = 3;

  static DateTime? lockedUntil;
  static int failures = 0;

  static bool get isLocked {
    final until = lockedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  @visibleForTesting
  static void debugReset() {
    lockedUntil = null;
    failures = 0;
  }

  static Future<void> hydrate() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(untilKey);
    final until = raw == null ? null : DateTime.tryParse(raw);
    if (until != null && until.isAfter(DateTime.now())) {
      lockedUntil = until;
    } else {
      lockedUntil = null;
      if (raw != null) {
        await sp.remove(untilKey);
      }
    }
    failures = sp.getInt(failuresKey) ?? 0;
  }

  static Future<void> persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(failuresKey, failures);
    if (lockedUntil != null) {
      await sp.setString(untilKey, lockedUntil!.toIso8601String());
    } else {
      await sp.remove(untilKey);
    }
  }

  static Future<void> registerFailure() async {
    failures += 1;
    if (failures >= failureLimit) {
      failures = 0;
      lockedUntil = DateTime.now().add(duration);
    }
    await persist();
  }

  static Future<void> registerSuccess() async {
    failures = 0;
    lockedUntil = null;
    await persist();
  }
}

/// 家長專區成人閘道。通過後本次 App 進程內保持解鎖，
/// 離開「家長」分頁後會重新上鎖。
class ParentGateOverlay extends StatefulWidget {
  const ParentGateOverlay({
    super.key,
    required this.onUnlocked,
    required this.onCancel,
  });

  final VoidCallback onUnlocked;
  final VoidCallback onCancel;

  @override
  State<ParentGateOverlay> createState() => _ParentGateOverlayState();
}

class _ParentGateOverlayState extends State<ParentGateOverlay> {
  ParentGateProblem? _problem;
  final _controller = TextEditingController();
  String? _error;
  Timer? _ticker;
  bool _loaded = false;

  bool get _locked => ParentGateLock.isLocked;

  @override
  void initState() {
    super.initState();
    _loadLock();
  }

  Future<void> _loadLock() async {
    try {
      await ParentGateLock.hydrate();
    } catch (_) {}
    if (!mounted) return;
    if (_locked) {
      _startTicker();
    } else {
      _problem = ParentGateProblem.random(Random());
    }
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      if (!_locked) {
        _ticker?.cancel();
        _ticker = null;
        ParentGateLock.lockedUntil = null;
        await ParentGateLock.persist();
        if (!mounted) return;
        _problem = ParentGateProblem.random(Random());
        _controller.clear();
        _error = null;
      }
      setState(() {});
    });
  }

  Future<void> _submit() async {
    if (_locked || _problem == null) return;
    final value = int.tryParse(_controller.text.trim());
    if (value != null && value == _problem!.answer) {
      await ParentGateLock.registerSuccess();
      if (!mounted) return;
      widget.onUnlocked();
      return;
    }
    await ParentGateLock.registerFailure();
    if (!mounted) return;
    _controller.clear();
    if (_locked) {
      _problem = null;
      _error = null;
      _startTicker();
      setState(() {});
      return;
    }
    setState(() => _error = '答案不正確，請再試一次');
  }

  @override
  Widget build(BuildContext context) {
    final locked = _loaded && _locked;
    final remain = ParentGateLock.lockedUntil
            ?.difference(DateTime.now())
            .inSeconds ??
        0;
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '家長確認',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '請完成這題計算，才能進入家長專區（避免孩子誤觸帳號與邀請碼）。',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    if (!_loaded)
                      const Center(child: CircularProgressIndicator())
                    else if (locked)
                      Text(
                        '答錯太多次，請 ${remain.clamp(1, ParentGateLock.duration.inSeconds)} 秒後再試',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        _problem?.prompt ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      enabled: _loaded && !locked,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: '答案',
                        errorText: _error,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) {
                        if (_loaded && !locked) _submit();
                      },
                      autofocus: _loaded && !locked,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: widget.onCancel,
                          child: const Text('取消'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: !_loaded || locked ? null : _submit,
                          child: const Text('確認'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
