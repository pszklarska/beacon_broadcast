package pl.pszklarska.beaconbroadcast

import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.os.Build
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

  fun start(advertiseCallback: ((Boolean) -> Unit)? = null) {
    this.advertiseCallback = advertiseCallback

    val beacon = Beacon.Builder()
        .setId1("2f234454-cf6d-4a0f-adf2-f4911ba9ffa6")
        .setId2("1")
        .setId3("2")
        .setManufacturer(0x0118)
        .setTxPower(-59)
        .setDataFields(Arrays.asList(0L))
        .build()

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && advertiseCallback != null) {
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
    } else {
      beaconTransmitter.startAdvertising(beacon)
    }
  }

  fun isStarted(): Boolean {
    return beaconTransmitter.isStarted
  }

  fun stop() {
    beaconTransmitter.stopAdvertising()
    advertiseCallback?.invoke(false)
  }

}