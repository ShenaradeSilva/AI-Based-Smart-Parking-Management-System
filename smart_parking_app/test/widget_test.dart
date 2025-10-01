import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Driver flow test', (WidgetTester tester) async {
    // Load app
    await tester.pumpWidget(const MyApp() as Widget);
    await tester.pumpAndSettle();

    // Tap login button
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    // Tap "Scan QR Code" button
    await tester.tap(find.byKey(const Key('scanQRCode')));
    await tester.pumpAndSettle();

    // Simulate QR Scan
    await tester.tap(find.byKey(const Key('simulateQRScan')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify SnackBar
    expect(find.text('QR Code Scanned Successfully!'), findsOneWidget);

    // Go back and tap "Reserve Slot"
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reserveA1')));
    await tester.pumpAndSettle();

    // Verify reservation text
    expect(find.textContaining('Slot reserved for: A1'), findsOneWidget);

    // Go back and tap "Booking History"
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bookingHistory')));
    await tester.pumpAndSettle();

    expect(find.text('No past bookings yet'), findsOneWidget);
  });
}

class MyApp {
  const MyApp();
}
