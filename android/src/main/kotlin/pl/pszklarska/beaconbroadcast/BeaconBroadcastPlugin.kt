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
      "isStarted" -> result.success(beacon.isStarted())
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
        arguments["uuid"] as String
    )

    beacon.start(beaconData, advertiseCallback)
    result.success(null)
  }

  private fun stopBeacon(result: MethodChannel.Result) {
    beacon.stop()
    result.success(null)
  }

  override fun onListen(event: Any?, eventSink: EventChannel.EventSink) {
    print("calling onEventListen")
    this.eventSink = eventSink
  }

  override fun onCancel(event: Any?) {
    print("calling onEventCancel")
    this.eventSink = null
  }

}

data class BeaconData(
    val uuid: String
)