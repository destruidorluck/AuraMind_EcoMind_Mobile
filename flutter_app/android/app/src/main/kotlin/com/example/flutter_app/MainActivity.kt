package com.example.flutter_app

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.provider.CallLog
import android.provider.Telephony
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "auramind/native_telephony"
    private val requestCodeTelephony = 4042

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestTelephonyPermissions" -> {
                        requestTelephonyPermissions()
                        result.success(permissionSnapshot())
                    }
                    "placeCall" -> {
                        val number = call.argument<String>("number").orEmpty()
                        result.success(placeCall(number))
                    }
                    "sendSms" -> {
                        val number = call.argument<String>("number").orEmpty()
                        val body = call.argument<String>("body").orEmpty()
                        result.success(sendSms(number, body))
                    }
                    "loadSmsThread" -> {
                        val number = call.argument<String>("number").orEmpty()
                        result.success(loadSmsThread(number))
                    }
                    "loadCallLog" -> {
                        val number = call.argument<String>("number").orEmpty()
                        result.success(loadCallLog(number))
                    }
                    "vibrateAlert" -> {
                        vibrateAlert()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestTelephonyPermissions() {
        val permissions = arrayOf(
            Manifest.permission.CALL_PHONE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.SEND_SMS,
            Manifest.permission.READ_SMS,
            Manifest.permission.RECEIVE_SMS,
        )
        val missing = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, missing.toTypedArray(), requestCodeTelephony)
        }
    }

    private fun permissionSnapshot(): Map<String, Boolean> {
        return mapOf(
            "callPhone" to hasPermission(Manifest.permission.CALL_PHONE),
            "readPhoneState" to hasPermission(Manifest.permission.READ_PHONE_STATE),
            "readCallLog" to hasPermission(Manifest.permission.READ_CALL_LOG),
            "sendSms" to hasPermission(Manifest.permission.SEND_SMS),
            "readSms" to hasPermission(Manifest.permission.READ_SMS),
            "receiveSms" to hasPermission(Manifest.permission.RECEIVE_SMS),
        )
    }

    private fun hasPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
    }

    private fun placeCall(number: String): Boolean {
        if (number.isBlank()) return false
        return try {
            val action = if (hasPermission(Manifest.permission.CALL_PHONE)) {
                Intent.ACTION_CALL
            } else {
                Intent.ACTION_DIAL
            }
            val intent = Intent(action, Uri.parse("tel:$number"))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun sendSms(number: String, body: String): Boolean {
        if (number.isBlank() || body.isBlank()) return false
        return try {
            if (!hasPermission(Manifest.permission.SEND_SMS)) {
                val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:$number"))
                intent.putExtra("sms_body", body)
                startActivity(intent)
                return false
            }
            val sms = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
            val parts = sms.divideMessage(body)
            sms.sendMultipartTextMessage(number, null, parts, null, null)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun loadSmsThread(number: String): List<Map<String, Any>> {
        if (number.isBlank() || !hasPermission(Manifest.permission.READ_SMS)) return emptyList()
        val normalized = onlyDigits(number)
        val rows = mutableListOf<Map<String, Any>>()
        var cursor: Cursor? = null
        return try {
            cursor = contentResolver.query(
                Telephony.Sms.CONTENT_URI,
                arrayOf(
                    Telephony.Sms._ID,
                    Telephony.Sms.ADDRESS,
                    Telephony.Sms.BODY,
                    Telephony.Sms.DATE,
                    Telephony.Sms.TYPE,
                ),
                null,
                null,
                "${Telephony.Sms.DATE} DESC",
            )
            while (cursor != null && cursor.moveToNext() && rows.size < 80) {
                val address = cursor.getString(1).orEmpty()
                if (!onlyDigits(address).endsWith(normalized.takeLast(8))) continue
                val type = cursor.getInt(4)
                rows.add(
                    mapOf(
                        "id" to cursor.getString(0).orEmpty(),
                        "address" to address,
                        "body" to cursor.getString(2).orEmpty(),
                        "date" to cursor.getLong(3),
                        "direction" to if (type == Telephony.Sms.MESSAGE_TYPE_SENT) "outgoing" else "incoming",
                    )
                )
            }
            rows.reversed()
        } catch (_: Exception) {
            emptyList()
        } finally {
            cursor?.close()
        }
    }

    private fun loadCallLog(number: String): List<Map<String, Any>> {
        if (number.isBlank() || !hasPermission(Manifest.permission.READ_CALL_LOG)) return emptyList()
        val normalized = onlyDigits(number)
        val rows = mutableListOf<Map<String, Any>>()
        var cursor: Cursor? = null
        return try {
            cursor = contentResolver.query(
                CallLog.Calls.CONTENT_URI,
                arrayOf(
                    CallLog.Calls._ID,
                    CallLog.Calls.NUMBER,
                    CallLog.Calls.TYPE,
                    CallLog.Calls.DATE,
                    CallLog.Calls.DURATION,
                ),
                null,
                null,
                "${CallLog.Calls.DATE} DESC",
            )
            while (cursor != null && cursor.moveToNext() && rows.size < 40) {
                val phone = cursor.getString(1).orEmpty()
                if (!onlyDigits(phone).endsWith(normalized.takeLast(8))) continue
                rows.add(
                    mapOf(
                        "id" to cursor.getString(0).orEmpty(),
                        "number" to phone,
                        "type" to callTypeLabel(cursor.getInt(2)),
                        "date" to cursor.getLong(3),
                        "duration" to cursor.getLong(4),
                    )
                )
            }
            rows
        } catch (_: Exception) {
            emptyList()
        } finally {
            cursor?.close()
        }
    }

    private fun vibrateAlert() {
        try {
            @Suppress("DEPRECATION")
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator ?: return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(
                    VibrationEffect.createWaveform(longArrayOf(0, 500, 250, 500), -1)
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(longArrayOf(0, 500, 250, 500), -1)
            }
        } catch (_: Exception) {
        }
    }

    private fun onlyDigits(value: String): String {
        return value.filter { it.isDigit() }
    }

    private fun callTypeLabel(type: Int): String {
        return when (type) {
            CallLog.Calls.INCOMING_TYPE -> "recebida"
            CallLog.Calls.OUTGOING_TYPE -> "realizada"
            CallLog.Calls.MISSED_TYPE -> "perdida"
            else -> "ligacao"
        }
    }
}
