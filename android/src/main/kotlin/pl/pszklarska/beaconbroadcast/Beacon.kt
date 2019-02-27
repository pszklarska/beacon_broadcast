package pl.pszklarska.beaconbroadcast

import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import org.altbeacon.beacon.Beacon
import org.altbeacon.beacon.BeaconParser
import org.altbeacon.beacon.BeaconTransmitter
import java.util.*

const val ALT_BEACON_LAYOUT = "m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25"
const val RADIUS_NETWORK_MANUFACTURER = 0x0118

class Beacon {

  private lateinit var beaconTransmitter: BeaconTransmitter
  private var advertiseCallback: ((Boolean) -> Unit)? = null

  fun init(context: Context) {
    val beaconParser = BeaconParser().setBeaconLayout(ALT_BEACON_LAYOUT)
    beaconTransmitter = BeaconTransmitter(context, beaconParser)
  }

  fun start(beaconData: BeaconData, advertiseCallback: ((Boolean) -> Unit)) {
    this.advertiseCallback = advertiseCallback

    val beacon = Beacon.Builder()
        .setId1(beaconData.uuid)
        .setId2(beaconData.majorId.toString())
        .setId3(beaconData.minorId.toString())
        .setManufacturer(RADIUS_NETWORK_MANUFACTURER)
        .setTxPower(beaconData.transmissionPower ?: -59)
        .setDataFields(Arrays.asList(0L))
        .build()

    beaconTransmitter.startAdvertising(beacon, object : AdvertiseCallback() {
      override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
        super.onStartSuccess(settingsInEffect)
        advertiseCallback(true)
      }

      override fun onStartFailure(errorCode: Int) {
        super.onStartFailure(errorCode)
        advertiseCallback(false)
      }
    })
  }

  fun isAdvertising(): Boolean {
    return beaconTransmitter.isStarted
  }

  fun stop() {
    beaconTransmitter.stopAdvertising()
    advertiseCallback?.invoke(false)
  }

}