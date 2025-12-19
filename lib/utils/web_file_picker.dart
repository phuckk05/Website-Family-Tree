import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

/// Web implementation to pick images using a native file input element.
/// Returns a list of [PlatformFile] with bytes populated.
Future<List<PlatformFile>?> pickImagesWeb() {
  final completer = Completer<List<PlatformFile>?>();

  final input =
      html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = true;

  input.click();

  input.onChange.listen(
    (_) async {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }

      final result = <PlatformFile>[];

      try {
        for (final f in files) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(f);
          await reader.onLoad.first;
          final buffer = reader.result;
          if (buffer is ByteBuffer) {
            final bytes = buffer.asUint8List();
            result.add(
              PlatformFile(name: f.name, size: bytes.length, bytes: bytes),
            );
          } else if (buffer is List<int>) {
            final bytes = Uint8List.fromList(buffer);
            result.add(
              PlatformFile(name: f.name, size: bytes.length, bytes: bytes),
            );
          } else {
            // Fallback: try to get blob and convert
            final br = html.FileReader();
            br.readAsArrayBuffer(f);
            await br.onLoad.first;
            final b = br.result as ByteBuffer;
            final bytes = b.asUint8List();
            result.add(
              PlatformFile(name: f.name, size: bytes.length, bytes: bytes),
            );
          }
        }
        completer.complete(result);
      } catch (e, s) {
        completer.completeError(e, s);
      }
    },
    onError: (e) {
      completer.completeError(e);
    },
  );

  return completer.future;
}
