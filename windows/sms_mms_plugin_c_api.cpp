#include "include/sms_mms/sms_mms_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "sms_mms_plugin.h"

void SmsMmsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  sms_mms::SmsMmsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
