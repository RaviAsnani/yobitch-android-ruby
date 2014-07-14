#!/bin/bash

# Test for install referrer
#adb shell am broadcast -a com.android.vending.INSTALL_REFERRER -n com.rum.yobitch/.InstallReferrerBroadcastReceiver --es  "referrer" "%7B%22sender_id%22%3A%2212%22%7D"


# Test for BOOT_COMPLETED broadcast
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED -n com.rum.yobitch/.OnBootLoadBroadcastReceiver