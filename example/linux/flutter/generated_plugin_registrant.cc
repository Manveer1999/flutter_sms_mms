//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <sms_mms/sms_mms_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) sms_mms_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SmsMmsPlugin");
  sms_mms_plugin_register_with_registrar(sms_mms_registrar);
}
