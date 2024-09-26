
import CoreAudio
import AudioToolbox

func listAirPlayDevices() {
    var propertySize = UInt32(0)
    var deviceListPropertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMaster
    )

    // Get the size of the device list
    let result = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &deviceListPropertyAddress, 0, nil, &propertySize)
    if result != noErr {
        print("Error getting device list size: \(result)")
        return
    }

    let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
    var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

    // Get the actual list of devices
    AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &deviceListPropertyAddress, 0, nil, &propertySize, &deviceIDs)

    for deviceID in deviceIDs {
        var deviceNamePropertySize = UInt32(MemoryLayout<CFString?>.size)
        var deviceName: CFString = "" as CFString
        var deviceNamePropertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMaster
        )

        // Get the device name
        AudioObjectGetPropertyData(deviceID, &deviceNamePropertyAddress, 0, nil, &deviceNamePropertySize, &deviceName)

        // Print the device name
        print("Device name: \(deviceName)")

        // Check if the device supports AirPlay
//        if deviceName.localizedStandardContains("AirPlay") {
//            print("This device supports AirPlay: \(deviceName)")
//        }
    }
}
