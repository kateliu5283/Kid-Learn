import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 家長專區成人閘道（算術題）。通過後本次 App 進程內保持解鎖，
/// 離開「家長」分頁後會重新上鎖，避免孩子隨意操作雲端帳號／QR。
/// 連續答錯 3 次會鎖定 45 秒，關掉畫面再進來也不會重來。
class ParentGateOverlay extends StatefulWidget {
  const ParentGateOverlay({
    super.key,
    required this.onUnlocked,
    required this.onCancel,
  });

  final VoidCallback onUnlocked;
  final VoidCallback onCancel;

  static DateTime? lockedUntil;
  static int failures = 0;

  static bool get isLocked {
    final until = lockedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  @override
  State<ParentGateOverlay> createState() => _ParentGateOverlayState();
}

class _ParentGateOverlayState extends State<ParentGateOverlay> {
  static const _lockout = Duration(seconds: 45);

  int? _a;
  int? _b;
  int? _answer;
  final _controller = TextEditingController();
  String? _error;
  Timer? _ticker;

  bool get _locked => ParentGateOverlay.isLocked;

  @override
  void initState() {
    super.initState();
    if (_locked) {
      _startTicker();
    } else {
      _newProblem();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _newProblem() {
    final rng = Random();
    final a = 11 + rng.nextInt(19);
    final b = 11 + rng.nextInt(19);
    _a = a;
    _b = b;
    _answer = a + b;
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_locked) {
        _ticker?.cancel();
        _ticker = null;
        _newProblem();
        _controller.clear();
        _error = null;
      }
      setState(() {});
    });
  }

  void _submit() {
    if (_locked) return;
    final raw = _controller.text.trim();
    final value = int.tryParse(raw);
    if (value != null && value == _answer) {
      ParentGateOverlay.failures = 0;
      widget.onUnlocked();
      return;
    }
    ParentGateOverlay.failures++;
    _controller.clear();
    if (ParentGateOverlay.failures >= 3) {
      ParentGateOverlay.failures = 0;
      ParentGateOverlay.lockedUntil = DateTime.now().add(_lockout);
      _a = null;
      _b = null;
      _answer = null;
      _error = null;
      _startTicker();
      setState(() {});
      return;
    }
    setState(() => _error = '答案不正確，請再試一次');
  }

  @override
  Widget build(BuildContext context) {
    final locked = _locked;
    final remain = ParentGateOverlay.lockedUntil
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
                      '請完成這題加法，才能進入家長專區（避免孩子誤觸帳號與邀請碼）。',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    if (locked)
                      Text(
                        '答錯太多次，請 ${remain.clamp(1, 45)} 秒後再試',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        '${_a ?? ''} + ${_b ?? ''} = ?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      enabled: !locked,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: '答案',
                        errorText: _error,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) {
                        if (!locked) _submit();
                      },
                      autofocus: !locked,
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
                          onPressed: locked ? null : _submit,
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
