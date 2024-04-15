package com.example.bahiascanner

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.Intent.getIntent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.VectorDrawable
import android.os.Build
import androidx.annotation.DrawableRes
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.Calendar
import android.app.ActivityManager

/** BahiascannerPlugin */
class BahiascannerPlugin:FlutterPlugin, MethodCallHandler, ActivityAware, io.flutter.plugin.common.PluginRegistry.ActivityResultListener {
  private val INTENT_VENTA = 108
//  private val INTENT_ANULACION = 101
//  private val INTENT_REIMPRIMIR = 102
//  private val INTENT_CIERRE = 103
//  private val INTENT_VENTAC2P = 104
//  private val INTENT_ANULACIONC2P = 105
//   private val INTENT_PRINTLOGO = 106
//   private val INTENT_PRINTTEXTO = 107
private val BARCODE_SCANNER_REQUEST_CODE = 123

  private lateinit var activity: Activity
  private lateinit var binding: ActivityPluginBinding
  private var pendingResult: Result? = null
  private var printData: Map<String, Any?>? = null
  private var isMovilPay: Int = 0
  private var contratoId: String? = null
  private var monto: Double? = null



  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

 

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    // TODO: your plugin is no longer associated with an Activity.
    // Clean up references.
    binding.removeActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // Dejar vacío ya que no se requiere ninguna acción específica
}

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

 override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bahiascanner")
    channel.setMethodCallHandler(this)
}


  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
        "getPlatformVersion" -> {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        "invokeVenta" -> {
            val monto = call.argument<Double>("monto")
            val cedula = call.argument<String>("cedula")
            val soloTD = call.argument<Boolean>("soloTD") ?: false
            val soloTC = call.argument<Boolean>("soloTC") ?: false
            val montoEditable = call.argument<Boolean>("montoEditable") ?: false
            pendingResult = result

            invokeVenta(monto, cedula ?: "", soloTD, soloTC, montoEditable)
        }
        "closeAppByPid" -> {
          val processId = call.argument<Int>("processId")
          if (processId != null) {
              closeAppByPid(processId)
              result.success(true)
          } else {
              result.error("INVALID_ARGUMENT", "Process ID argument is null", null)
          }
      }
       
        else -> {
          result.notImplemented()
        }
    }
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun invokeVenta(
    monto: Double?,
    cedula: String,
    soloTD: Boolean,
    soloTC: Boolean,
    montoEditable: Boolean
) {
    val appURL = "com.digipay.digimpos.bnc.qa"

    val intent = Intent("android.intent.action.MAIN")
    val cn = ComponentName(appURL, "com.digipay.digimpos" + ".InvokeActivity")
    intent.component = cn

    val finalAmountLong = (monto!! * 100).toLong()

    try {
      if (monto != null) {
        intent.putExtra("OPERACION", "VENTA")
        intent.putExtra("MONTO", finalAmountLong) // Pasando como String
        intent.putExtra("MONTO_EDITABLE", false)
        // intent.putExtra("CEDULA", cedula)
        if(!cedula.equals(""))
            intent.putExtra("CEDULA", cedula)
        activity.startActivityForResult(intent, INTENT_VENTA)
      } else {
        pendingResult?.error("INTENT_START_FAILED", "Failed to start payment intent.", "monto is null.")
      }
    } catch (e: Exception) {
      pendingResult?.error("INTENT_START_FAILED", "Failed to start payment intent.", e.message)
      pendingResult = null
    }
  }


  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    println(requestCode);
    println(resultCode);

    when (requestCode) {
      INTENT_VENTA -> {
        if (resultCode == Activity.RESULT_OK){
            resultForCardPayment(requestCode, resultCode, data)

          pendingResult?.success(data)
        }

        return true
      }
   
 
      else -> return false
    }
  }

  private fun getCurrentDateTime(): Calendar {
    return Calendar.getInstance()
  }

  private fun resultForCardPayment(requestCode: Int, resultCode: Int, data: Intent?): String {
    val responseCode = data?.getStringExtra("RESPONSE_CODE")
    val responseMessage = data?.getStringExtra("RESPONSE_MESSAGE")
    val allData= data?.extras
    val recibo = data!!.getStringExtra("RECIBO") ?: "000000"
    val stan =data!!.getStringExtra("STAN") ?: "000000"
    val lote = data!!.getStringExtra("LOTE") ?: "000000"
    val pan = data!!.getStringExtra("PAN") ?: "000000"
    val maskedPan = maskCardNumber(pan)
    val merchant_id = data!!.getStringExtra("MERCHANT_ID") ?: "000000"
    val terminal_id = data!!.getStringExtra("TERMINAL_ID") ?: "000000"
    val autorizacion = data!!.getStringExtra("AUTORIZACION") ?: "000000"
    // Construye una cadena con la información relevante de la respuesta
    val resultString = "Response Code: $responseCode\nResponse Message: $responseMessage\nMasked PAN: $maskedPan"
    val pago = mapOf(
        "code" to responseCode,
        "message" to responseMessage,
        "resultCode" to resultCode,
        "pan" to maskedPan,
        "recibo" to recibo,
        "stan" to stan,
        "lote" to lote,
        "merchantId" to merchant_id,
        "terminalId" to terminal_id,
        "autorizacion" to autorizacion,
        "source" to "payment_gateway"
      
      )
    pendingResult?.success(pago)
    pendingResult = null
    // Imprime la respuesta en la consola
    // println("Resultado del pago: $resultString")
    println("Resultado del pago: $allData")

   

    // Devuelve la cadena de respuesta
    return resultString
}

private fun closeAppByPid(processId: Int) {
  android.os.Process.killProcess(processId)
  val packageName = "camerahalserver"
  killAppByPackageName(activity.applicationContext, packageName)
}

private fun killAppByPackageName(context: Context, packageName: String) {
  val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
  activityManager.killBackgroundProcesses(packageName)
}

  private fun maskCardNumber(pan: String?): String? {
    return pan?.let {
      if (it.length > 8) {
        val start = it.substring(0, 4)
        val end = it.substring(it.length - 4)
        val middle = "*".repeat(it.length - 8)
        "$start$middle$end"
      } else {
        it // Si la longitud es menor a 8, simplemente regresa el valor original
      }
    }
  }





}