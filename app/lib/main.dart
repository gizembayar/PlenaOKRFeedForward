import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'services/backend.dart';
import 'services/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // notdulbutcool.com/uyelik (# olmadan)
  await Backend.init();
  await Backend.instance.restore();
  runApp(NotDulButCoolApp(session: Session(Backend.instance)));
}

class NotDulButCoolApp extends StatefulWidget {
  const NotDulButCoolApp({super.key, required this.session});
  final Session session;

  @override
  State<NotDulButCoolApp> createState() => _NotDulButCoolAppState();
}

class _NotDulButCoolAppState extends State<NotDulButCoolApp> {
  late final GoRouter _router = buildRouter(widget.session);

  @override
  void dispose() {
    _router.dispose();
    widget.session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SessionScope(
    session: widget.session,
    child: MaterialApp.router(
      title: 'NOT DUL, BUT COOL.',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    ),
  );
}
