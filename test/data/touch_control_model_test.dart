import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/data/models/touch_control_model.dart';
import 'package:sm64cdpy/domain/entities/touch_control_entity.dart';

void main() {
  test('legacy, blank, null and malformed author use the requested credit', () {
    for (final author in [null, '', '  ', 42, <String>[]]) {
      final entity = TouchControlModel.fromJson('touch-id', {
        'title': 'Original title',
        'author': author,
      }).toEntity();
      expect(entity.author, 'Release Soon');
      expect(entity.id, 'touch-id');
      expect(entity.title, 'Original title');
    }
  });

  test('author survives parsing without becoming catalog identity', () {
    final credited = TouchControlModel.fromJson('same-id', {
      'title': 'Layout',
      'author': '  Créateur italiano  ',
    }).toEntity();
    expect(credited.author, 'Créateur italiano');
    expect(
      credited,
      const TouchControlEntity(
        id: 'same-id',
        title: 'Layout',
        downloadUrl: '',
        addedAt: '',
      ),
    );
  });
}
