import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../application/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await widget.authController.login(
      _identifierController.text,
      _passwordController.text,
    );
  }

  Future<void> _showForgotPassword() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var submitting = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reset password'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (!email.contains('@') || !email.contains('.')) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final messenger = ScaffoldMessenger.of(context);
                          setDialogState(() => submitting = true);
                          try {
                            final message = await widget.authController
                                .requestPasswordReset(emailController.text);
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            messenger.showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          } catch (_) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() => submitting = false);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password reset could not be requested. Please retry.',
                                ),
                              ),
                            );
                          }
                        },
                  child: submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send reset link'),
                ),
              ],
            );
          },
        );
      },
    );
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.authController.isBusy;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.church_rounded,
                      size: 68,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Bahasha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Church Contribution Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextFormField(
                      controller: _identifierController,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Username or phone number',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Enter your username or phone number.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!isLoading) _handleLogin();
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password.'
                          : null,
                    ),
                    if (widget.authController.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          widget.authController.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _handleLogin,
                      icon: isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(isLoading ? 'Signing in...' : 'Sign in'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: isLoading ? null : _showForgotPassword,
                      child: const Text('Forgot password?'),
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
