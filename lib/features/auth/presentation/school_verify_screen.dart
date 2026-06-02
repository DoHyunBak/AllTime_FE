import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';

enum VerifyStep { enterEmail, enterCode, done }

final _verifyStepProvider = StateProvider<VerifyStep>((ref) => VerifyStep.enterEmail);
final _verifyEmailProvider = StateProvider<String>((ref) => '');

class SchoolVerifyScreen extends ConsumerStatefulWidget {
  const SchoolVerifyScreen({super.key});

  @override
  ConsumerState<SchoolVerifyScreen> createState() => _SchoolVerifyScreenState();
}

class _SchoolVerifyScreenState extends ConsumerState<SchoolVerifyScreen> {
  final _emailController = TextEditingController();
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _codeControllers) c.dispose();
    for (final f in _codeFocusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('올바른 학교 이메일을 입력해주세요')));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ref.read(_verifyEmailProvider.notifier).state = email;
    ref.read(_verifyStepProvider.notifier).state = VerifyStep.enterCode;
    setState(() { _loading = false; _resendSeconds = 180; });
    _startResendTimer();
    _codeFocusNodes[0].requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$email 로 인증 코드를 발송했습니다 (데모: 123456)')));
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) t.cancel();
      else setState(() => _resendSeconds--);
    });
  }

  Future<void> _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length < 6) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (code == '123456') {
      ref.read(authProvider.notifier).verifySchool();
      ref.read(_verifyStepProvider.notifier).state = VerifyStep.done;
      setState(() => _loading = false);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) context.go('/');
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증 코드가 일치하지 않습니다'), backgroundColor: AppColors.error),
      );
      for (final c in _codeControllers) c.clear();
      _codeFocusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(_verifyStepProvider);
    final email = ref.watch(_verifyEmailProvider);

    if (step == VerifyStep.done) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 80),
                SizedBox(height: 24),
                Text('학교 인증 완료!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      );
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: step == VerifyStep.enterCode
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () {
                    ref.read(_verifyStepProvider.notifier).state = VerifyStep.enterEmail;
                    for (final c in _codeControllers) c.clear();
                  },
                )
              : null,
          title: const Text('학교 인증', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: step == VerifyStep.enterEmail
                  ? _EmailStep(controller: _emailController, loading: _loading, onSend: _sendCode)
                  : _CodeStep(
                      email: email,
                      controllers: _codeControllers,
                      focusNodes: _codeFocusNodes,
                      loading: _loading,
                      resendSeconds: _resendSeconds,
                      onVerify: _verifyCode,
                      onResend: _resendSeconds == 0 ? _sendCode : null,
                      onCodeChanged: (i, val) {
                        if (val.length == 1 && i < 5) _codeFocusNodes[i + 1].requestFocus();
                        if (val.isEmpty && i > 0) _codeFocusNodes[i - 1].requestFocus();
                        if (_codeControllers.every((c) => c.text.length == 1)) _verifyCode();
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailStep extends StatelessWidget {
  const _EmailStep({required this.controller, required this.loading, required this.onSend});
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('학교 이메일을\n입력해주세요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.3)),
        const SizedBox(height: 10),
        const Text('재학생 인증을 위해 학교에서 발급한\n이메일이 필요합니다', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 28),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'example@univ.ac.kr',
            suffixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: loading ? null : onSend,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('인증 코드 발송'.toUpperCase()),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(text: '졸업생이거나 이메일이 없다면 ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                TextSpan(text: '학생증으로 인증', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700, decoration: TextDecoration.underline, decorationColor: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.email,
    required this.controllers,
    required this.focusNodes,
    required this.loading,
    required this.resendSeconds,
    required this.onVerify,
    required this.onCodeChanged,
    this.onResend,
  });
  final String email;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool loading;
  final int resendSeconds;
  final VoidCallback onVerify;
  final void Function(int index, String val) onCodeChanged;
  final VoidCallback? onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('인증 코드를\n입력해주세요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, height: 1.3)),
        const SizedBox(height: 10),
        Text('$email 로 발송된\n6자리 코드를 입력해주세요', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => SizedBox(
            width: 42, height: 52,
            child: TextField(
              controller: controllers[i],
              focusNode: focusNodes[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (val) => onCodeChanged(i, val),
            ),
          )),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              resendSeconds > 0 ? '${resendSeconds ~/ 60}:${(resendSeconds % 60).toString().padLeft(2, '0')} 후 재발송 가능' : '코드를 받지 못하셨나요?',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            if (onResend != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onResend,
                child: const Text('재발송', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700, decoration: TextDecoration.underline, decorationColor: AppColors.primary)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: loading ? null : onVerify,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('인증 완료'.toUpperCase()),
          ),
        ),
        const SizedBox(height: 32),
        const Center(child: Text('[데모] 인증 코드: 123456', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
      ],
    );
  }
}
