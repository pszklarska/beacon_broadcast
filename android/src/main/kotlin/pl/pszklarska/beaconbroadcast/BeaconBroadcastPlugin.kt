package pl.pszklarska.beaconbroadcast

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class BeaconBroadcastPlugin(private val beacon: Beacon) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

  private var eventSink: EventChannel.EventSink? = null
  private var advertiseCallback: (Boolean) -> Unit = { isAdvertising ->
    eventSink?.success(isAdvertising)
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: PluginRegistry.Registrar) {
      val beacon = Beacon()
      beacon.init(registrar.context())

      val methodChannel = MethodChannel(registrar.messenger(), "pl.pszklarska.beaconbroadcast/beacon_state")
      val eventChannel = EventChannel(registrar.messenger(), "pl.pszklarska.beaconbroadcast/beacon_events")

      val instance = BeaconBroadcastPlugin(beacon)
      methodChannel.setMethodCallHandler(instance)
      eventChannel.setStreamHandler(instance)
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "start" -> startBeacon(call, result)
      "stop" -> stopBeacon(result)
      "isAdvertising" -> result.success(beacon.isAdvertising())
      "isTransmissionSupported" -> isTransmissionSupported(result)
      else -> result.notImplemented()
    }
  }

  @Suppress("UNCHECKED_CAST")
  private fun startBeacon(call: MethodCall, result: MethodChannel.Result) {
    if (call.arguments !is Map<*, *>) {
      throw IllegalArgumentException("Arguments are not a map! " + call.arguments)
    }

    val arguments = call.arguments as Map<String, Any>
    val beaconData = BeaconData(
        arguments["uuid"] as String,
        arguments["majorId"] as Int,
        arguments["minorId"] as Int,
        arguments["transmissionPower"] as Int?,
        arguments["advertiseMode"] as Int?,
        arguments["layout"] as String?,
        arguments["manufacturerId"] as Int?,
        arguments["extraData"] as List<Long>?
    )

    beacon.start(beaconData, advertiseCallback)
    result.success(null)
  }

  private fun stopBeacon(result: MethodChannel.Result) {
    beacon.stop()
    result.success(null)
  }

  private fun isTransmissionSupported(result: MethodChannel.Result) {
    result.success(beacon.isTransmissionSupported())
  }

  override fun onListen(event: Any?, eventSink: EventChannel.EventSink) {
    this.eventSink = eventSink
  }

  override fun onCancel(event: Any?) {
    this.eventSink = null
  }

}

data class BeaconData(
    val uuid: String,
    val majorId: Int,
    val minorId: Int,
    val transmissionPower: Int?,
    val advertiseMode: Int?,
    val layout: String?,
    val manufacturerId: Int?,
    val extraData: List<Long>?
)