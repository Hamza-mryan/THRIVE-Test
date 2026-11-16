import 'package:flutter/material.dart';

import '../core/network/thrive_api.dart';
import '../l10n/app_localizations.dart';
import 'thrive_widgets.dart';

String requestError(BuildContext context, Object? error) {
  final l = AppLocalizations.of(context);
  if (error is ApiFailure && error.kind == ApiFailureKind.connection) {
    return l.connectionError;
  }
  if (error is ApiFailure && error.kind == ApiFailureKind.unauthorized) {
    return l.sessionError;
  }
  return l.actionError;
}

/// Keeps loading/error/retry behavior consistent without sharing feature rules.
class AsyncContent<T> extends StatefulWidget {
  const AsyncContent({required this.load, required this.builder, super.key});
  final Future<T> Function() load;
  final Widget Function(BuildContext, T, VoidCallback) builder;

  @override
  State<AsyncContent<T>> createState() => _AsyncContentState<T>();
}

class _AsyncContentState<T> extends State<AsyncContent<T>> {
  late Future<T> pending = widget.load();
  void reload() {
    if (!mounted) return;
    final next = widget.load();
    setState(() {
      pending = next;
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: pending,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return Center(
          child: Semantics(
            label: AppLocalizations.of(context).loading,
            child: const CircularProgressIndicator(),
          ),
        );
      }
      if (snapshot.hasError) {
        return PageContent(
          children: [
            const SizedBox(height: 24),
            InlineNotice(
              text: requestError(context, snapshot.error),
              isError: true,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: reload,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        );
      }
      return widget.builder(context, snapshot.data as T, reload);
    },
  );
}

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    required this.title,
    required this.body,
    this.icon = Icons.inbox_outlined,
    super.key,
  });
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(body),
      ],
    ),
  );
}

String displayDate(BuildContext context, DateTime value) =>
    MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
