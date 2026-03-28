import 'package:image_picker/image_picker.dart';
import 'package:phyto_glow/classes/data/picked_image_data.dart';

Future<PickedImageData?> pickImageBytes() async {
  final picker = ImagePicker();
  final file = await picker.pickImage(source: ImageSource.gallery);

  if (file == null) {
    return null;
  }

  final bytes = await file.readAsBytes();

  if (bytes.isEmpty) {
    return null;
  }

  return PickedImageData(
    name: file.name.isEmpty ? 'เลือกรูปภาพแล้ว' : file.name,
    bytes: bytes,
  );
}
