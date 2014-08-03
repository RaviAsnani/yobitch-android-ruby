# Module to create & handle views for Ads - primarily Admob for now

# TODO : currently the code is very HARD bound with the view of YoBitch app. Needs to be more abstract

java_import 'com.google.android.gms.ads.AdRequest'
java_import 'com.google.android.gms.ads.AdSize'
java_import 'com.google.android.gms.ads.AdView'
java_import 'android.widget.RelativeLayout'
java_import 'android.view.ViewGroup'


module Ads

  # Needs the context, the parentl layout (currently only supports RelativeLayout) and the Ad ID.
  def get_admob_ad_view(context, layout, ad_unit_id)
    # Create an ad.
    ad_view = AdView.new(context)
    ad_view.set_ad_size(AdSize::SMART_BANNER)
    ad_view.set_ad_unit_id(ad_unit_id)


    # Add the AdView to the view hierarchy. The view will have no size
    # until the ad is loaded.
    # params = RelativeLayout::LayoutParams.new(ViewGroup::LayoutParams::MATCH_PARENT, 
    #                                           ViewGroup::LayoutParams::WRAP_CONTENT)
    # params.add_rule(RelativeLayout::ALIGN_PARENT_BOTTOM, ad_view.get_id())
    # ad_view.set_layout_params(params)
    layout.find_view_by_id(Ruboto::R::id::admob_layout).add_view(ad_view)

    # Create an ad request. Check logcat output for the hashed device ID to
    # get test ads on a physical device.
    ad_request = AdRequest::Builder.new()
        .add_test_device(AdRequest::DEVICE_ID_EMULATOR)
        .build()

    # Start loading the ad in the background.
    ad_view.load_ad(ad_request)
  end



  # Renders an intersitital ad - should be moved to its own class/module
  def get_appnext_interstitial_ad(context, placement_id)
    appnext = Appnext.new(context)
    appnext.set_app_id(placement_id)
    appnext.show_bubble
    return appnext
  end  

end