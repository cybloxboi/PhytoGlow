import 'package:phyto_glow/classes/data/picked_image_data.dart';
import 'package:phyto_glow/functions/files/pick_image_bytes_io.dart'
    if (dart.library.html) 'package:phyto_glow/functions/files/pick_image_bytes_web.dart'
    as picker_impl;

Future<PickedImageData?> pickImageBytes() => picker_impl.pickImageBytes();
