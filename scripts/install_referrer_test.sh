#!/bin/bash
adb shell am broadcast -a com.android.vending.INSTALL_REFERRER -n com.rum.yobitch/.InstallReferrerBroadcastReceiver --es  "referrer" "%7B%22sender_id%22%3A%2212%22%7D"
