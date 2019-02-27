package pl.pszklarska.beaconbroadcast

import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import org.altbeacon.beacon.Beacon
import org.altbeacon.beacon.BeaconParser
import org.altbeacon.beacon.BeaconTransmitter
import java.util.*


class Beacon {

  private lateinit var beaconTransmitter: BeaconTransmitter
  private var advertiseCallback: ((Boolean) -> Unit)? = null

  fun init(context: Context) {
    val beaconParser = BeaconParser()
        .setBeaconLayout("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25")
    beaconTransmitter = BeaconTransmitter(context, beaconParser)
  }

  fun start(beaconData: BeaconData, advertiseCallback: ((Boolean) -> Unit)) {
    this.advertiseCallback = advertiseCallback

    val beacon = Beacon.Builder()
        .setId1(beaconData.uuid)
        .setId2("1")
        .setId3("2")
        .setManufacturer(0x0118)
        .setTxPower(-59)
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

  fun isStarted(): Boolean {
    return beaconTransmitter.isStarted
  }

  fun stop() {
    beaconTransmitter.stopAdvertising()
    advertiseCallback?.invoke(false)
  }

}