import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../services/backend.dart';
import '../../services/session.dart';
import '../../widgets/brand.dart';

/// Giriş ve kayıt — web ve mobilde aynı ekran.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.signUp, this.plan, this.period});
  final bool signUp;
  final String? plan;
  final String? period;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  bool _consent = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String get _afterAuth {
    final p = widget.plan;
    if (p != null && p != 'free') {
      return '/app/uyelik?plan=$p&donem=${widget.period ?? 'yearly'}';
    }
    return '/app/bugun';
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (widget.signUp && !_consent) {
      setState(
        () => _error = 'Devam etmek için aydınlatma metnini onaylamalısın.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final backend = context.sessionRead.backend;
    try {
      if (widget.signUp) {
        await backend.signUp(
          email: _email.text.trim(),
          password: _password.text,
          name: _name.text.trim(),
        );
      } else {
        await backend.signIn(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
      if (mounted) context.go(_afterAuth);
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Bir şeyler ters gitti. Lütfen tekrar dene.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Önce e-posta adresini yaz.');
      return;
    }
    await context.sessionRead.backend.sendPasswordReset(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifre sıfırlama bağlantısı e-postana gönderildi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final form = _buildForm(context);
    return Scaffold(
      body: wide
          ? Row(
              children: [
                Expanded(
                  child: Container(
                    color: Brand.kobalt,
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Wordmark(
                          size: 72,
                          color: Brand.krem,
                          twoLines: true,
                        ),
                        const SizedBox(height: 28),
                        const HighlightBar(Brand.slogan, size: 20),
                        const SizedBox(height: 28),
                        Text(
                          'Bu defa kendim için.',
                          style: BrandText.italic(color: Brand.krem, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Center(child: form)),
              ],
            )
          : SafeArea(child: Center(child: form)),
    );
  }

  Widget _buildForm(BuildContext context) {
    final demo = context.sessionRead.backend.isDemo;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => context.go('/'),
                    child: const Wordmark(size: 22),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  widget.signUp
                      ? 'Hayatımın yeni sezonu.'
                      : 'Tekrar hoş geldin.',
                  style: BrandText.logo(size: 36),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.signUp
                      ? 'Hesabını oluştur, “Benim Hayatım” haritanı birlikte çizelim.'
                      : 'Bugün kendin için ne var, bakalım.',
                  style: BrandText.body(),
                ),
                if (demo) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Brand.limonSoft,
                    child: Text(
                      'Demo mod: herhangi bir e-posta ve 8+ karakterli şifre ile girebilirsin.',
                      style: BrandText.body(size: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (widget.signUp) ...[
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    decoration: const InputDecoration(
                      labelText: 'Sana nasıl hitap edelim?',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Bir isim yaz' : null,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Geçerli bir e-posta gir'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  onFieldSubmitted: (_) => _submit(),
                  autofillHints: [
                    widget.signUp
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 8) ? 'En az 8 karakter' : null,
                ),
                if (widget.signUp)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _consent,
                    onChanged: (v) => setState(() => _consent = v ?? false),
                    title: Text(
                      'KVKK aydınlatma metnini okudum; verilerimin yalnızca bana öneri sunmak için işlenmesini onaylıyorum.',
                      style: BrandText.body(size: 13),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _reset,
                      child: const Text('Şifremi unuttum'),
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      style: BrandText.body(color: Brand.mercan, size: 14),
                    ),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Brand.krem,
                          ),
                        )
                      : Text(widget.signUp ? 'Hesabımı oluştur' : 'Giriş yap'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    final q = widget.plan == null
                        ? ''
                        : '?plan=${widget.plan}&donem=${widget.period ?? 'yearly'}';
                    context.go(widget.signUp ? '/giris$q' : '/kayit$q');
                  },
                  child: Text(
                    widget.signUp
                        ? 'Zaten hesabım var — giriş yap'
                        : 'Hesabın yok mu? Ücretsiz katıl',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
