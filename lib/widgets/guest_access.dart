// lib/widgets/guest_access.dart
// Shared helpers for restricting guest (not-logged-in) users to a view-only
// experience. Reused across every screen so the behaviour stays consistent.

import 'package:flutter/material.dart';
import 'package:helpinghand/services/auth_service.dart';

const Color _kTeal = Color(0xFF2A9D8F);

class GuestAccess {
  /// If the user is a guest, shows a "log in / sign up" prompt and returns
  /// true (meaning: block this action). Returns false for logged-in users, so
  /// callers can simply do: `if (GuestAccess.blockIfGuest(context)) return;`
  static bool blockIfGuest(BuildContext context) {
    if (!AuthService.isGuest()) return false;
    _showPrompt(context);
    return true;
  }

  static void _showPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: _kTeal, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Login Required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You're browsing as a guest. Log in or create an account to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kTeal,
                      side: const BorderSide(color: _kTeal),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacementNamed(context, '/signin');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Slim always-visible strip telling guests they're restricted, with a Login
/// shortcut. Place at the top of a screen body for guests.
class GuestBanner extends StatelessWidget {
  const GuestBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isGuest()) return const SizedBox.shrink();
    return Material(
      color: _kTeal.withOpacity(0.10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.visibility_outlined, size: 18, color: _kTeal),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Viewing as guest — log in to access all features',
                style: TextStyle(fontSize: 12.5, color: Colors.black87),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/signin'),
              style: TextButton.styleFrom(
                foregroundColor: _kTeal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 0),
              ),
              child: const Text('Login',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Locked placeholder shown where records/details/forms would appear for a
/// guest. Use it in place of real content.
class GuestLockedView extends StatelessWidget {
  final String message;
  const GuestLockedView({
    super.key,
    this.message = 'Log in to view this content',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/signin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kTeal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Login / Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen locked page (AppBar + locked body) — for detail/form screens a
/// guest should not see at all. Keeps the title so the layout is still visible.
class GuestLockedScaffold extends StatelessWidget {
  final String title;
  final String message;
  const GuestLockedScaffold({
    super.key,
    required this.title,
    this.message = 'Log in to view this content',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(title,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: GuestLockedView(message: message),
    );
  }
}
