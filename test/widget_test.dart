import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iventory/core/repository/inventory_repository.dart';
import 'package:iventory/main.dart';

void main() {
  testWidgets('Iventory app loads Dark UI Dashboard with dynamic metrics and items',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const IventoryApp());
    await tester.pumpAndSettle();

    // Pastikan Header Dashboard dan User "Budi" tampil
    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);

    // Pastikan Metrik Kartu Sesuai Desain image.png
    expect(find.text('SALE STOCK'), findsOneWidget);
    expect(find.text('LOW STOCK'), findsOneWidget);
    expect(find.text('TOTAL ITEMS'), findsOneWidget);

    // Pastikan Item Komoditas dari image.png tampil
    expect(find.text('Beras'), findsOneWidget);
    expect(find.text('Minyak Goreng'), findsOneWidget);
    expect(find.text('Gandum'), findsOneWidget);
    expect(find.text('Telur'), findsOneWidget);

    // Pastikan Tab Navigasi tampil
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
  });

  test('InventoryRepository updates stock quantity dynamically and recalculates metrics', () {
    final repo = InventoryRepository.instance;
    final initialTotal = repo.totalItemsCount;

    // Ubah kuantitas 'item-beras'
    repo.updateItemQuantity('item-beras', 200);

    // Pastikan kuantitas berubah dan metrik total items bertambah
    final itemBeras = repo.items.firstWhere((i) => i.id == 'item-beras');
    expect(itemBeras.quantity, equals(200));
    expect(repo.totalItemsCount, greaterThan(initialTotal));
  });
}
