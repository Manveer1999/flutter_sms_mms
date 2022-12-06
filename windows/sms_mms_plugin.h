#ifndef FLUTTER_PLUGIN_sms_mms_PLUGIN_H_
#define FLUTTER_PLUGIN_sms_mms_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace sms_mms {

class SmsMmsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SmsMmsPlugin();

  virtual ~SmsMmsPlugin();

  // Disallow copy and assign.
  SmsMmsPlugin(const SmsMmsPlugin&) = delete;
  SmsMmsPlugin& operator=(const SmsMmsPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace sms_mms

#endif  // FLUTTER_PLUGIN_sms_mms_PLUGIN_H_
