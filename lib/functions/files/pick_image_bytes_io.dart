import 'package:file_picker/file_picker.dart';
import 'package:phyto_glow/classes/data/picked_image_data.dart';

Future<PickedImageData?> pickImageBytes() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true,
  );

  final files = result?.files;
  final file = files == null || files.isEmpty ? null : files.first;
  if (file == null || file.bytes == null || file.bytes!.isEmpty) {
    return null;
  }

  return PickedImageData(
    name: file.name.isEmpty ? 'เลือกรูปภาพแล้ว' : file.name,
    bytes: file.bytes!,
  );
}
