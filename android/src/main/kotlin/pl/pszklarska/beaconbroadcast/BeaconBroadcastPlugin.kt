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
      "start" -> {
        beacon.start(advertiseCallback)
        result.success(null)
      }
      "stop" -> {
        beacon.stop()
        result.success(null)
      }
      "isStarted" -> result.success(beacon.isStarted())
      else -> result.notImplemented()
    }
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
