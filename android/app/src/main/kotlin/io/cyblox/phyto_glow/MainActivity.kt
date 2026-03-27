package io.cyblox.phyto_glow

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "io.cyblox.phyto_glow/downloads",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveBytes" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    val mimeType = call.argument<String>("mimeType")

                    if (bytes == null || bytes.isEmpty()) {
                        result.error("invalid_bytes", "ไม่มีข้อมูลไฟล์สำหรับบันทึก", null)
                        return@setMethodCallHandler
                    }

                    if (fileName.isNullOrBlank() || mimeType.isNullOrBlank()) {
                        result.error("invalid_args", "ข้อมูลไฟล์ไม่ครบถ้วน", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val savedUri = saveImageToMediaStore(
                            bytes = bytes,
                            fileName = fileName,
                            mimeType = mimeType,
                        )
                        result.success(savedUri.toString())
                    } catch (error: UnsupportedOperationException) {
                        result.error("unsupported_android", error.message, null)
                    } catch (error: IOException) {
                        result.error("save_failed", error.message, null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    @Throws(IOException::class, UnsupportedOperationException::class)
    private fun saveImageToMediaStore(
        bytes: ByteArray,
        fileName: String,
        mimeType: String,
    ): android.net.Uri {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            throw UnsupportedOperationException(
                "รองรับการบันทึกอัตโนมัติบน Android 10 ขึ้นไปเท่านั้น",
            )
        }

        val resolver = applicationContext.contentResolver
        val collection = MediaStore.Images.Media.getContentUri(
            MediaStore.VOLUME_EXTERNAL_PRIMARY,
        )
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(
                MediaStore.MediaColumns.RELATIVE_PATH,
                "${Environment.DIRECTORY_PICTURES}/Phyto Glow",
            )
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }

        val itemUri = resolver.insert(collection, values)
            ?: throw IOException("ไม่สามารถสร้างไฟล์ปลายทางได้")

        try {
            resolver.openOutputStream(itemUri)?.use { outputStream ->
                outputStream.write(bytes)
                outputStream.flush()
            } ?: throw IOException("ไม่สามารถเปิดไฟล์ปลายทางเพื่อเขียนข้อมูลได้")

            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(itemUri, values, null, null)
            return itemUri
        } catch (error: Exception) {
            resolver.delete(itemUri, null, null)
            throw IOException(error.message ?: "บันทึกไฟล์ไม่สำเร็จ", error)
        }
    }
}
