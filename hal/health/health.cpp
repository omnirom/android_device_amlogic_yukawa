/*
 * Copyright (C) 2018 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#define LOG_TAG "android.hardware.health@2.1-service.yukawa"

#include <memory>
#include <string_view>

#include <android-base/logging.h>
#include <health/utils.h>
#include <health2impl/Health.h>
#include <cutils/properties.h>

using ::android::sp;
using ::android::hardware::Return;
using ::android::hardware::Void;
using ::android::hardware::health::InitHealthdConfig;
using ::android::hardware::health::V1_0::BatteryStatus;
using ::android::hardware::health::V2_0::Result;
using ::android::hardware::health::V2_1::IHealth;
using namespace std::literals;

namespace android {
namespace hardware {
namespace health {
namespace V2_1 {
namespace implementation {

// Health HAL implementation for cuttlefish. Note that in this implementation, cuttlefish
// pretends to be a device with a battery being charged. Implementations on real devices
// should not insert these fake values. For example, a battery-less device should report
// batteryPresent = false and batteryStatus = UNKNOWN.

#define FAKE_BATTERY_CAPACITY 42
#define FAKE_BATTERY_TEMPERATURE 424

class HealthImpl : public Health {
 public:
  HealthImpl(std::unique_ptr<healthd_config>&& config)
    : Health(std::move(config)) {}
 protected:
  void UpdateHealthInfo(HealthInfo* health_info) override;
};

void HealthImpl::UpdateHealthInfo(HealthInfo* health_info) {
  auto* battery_props = &health_info->legacy.legacy;
  battery_props->batteryStatus = BatteryStatus::UNKNOWN;
  battery_props->batteryPresent = false;

  char property[PROPERTY_VALUE_MAX] = {0};
  if (property_get("persist.vendor.fake_battery", property, NULL)) {
    if (strcmp(property, "1") == 0) {
      battery_props->batteryPresent = true;
      battery_props->batteryTemperature = FAKE_BATTERY_TEMPERATURE;
      battery_props->batteryLevel = FAKE_BATTERY_CAPACITY;
      battery_props->batteryStatus = BatteryStatus::DISCHARGING;
    } else if (strcmp(property, "2") == 0) {
      battery_props->batteryPresent = true;
      battery_props->batteryTemperature = FAKE_BATTERY_TEMPERATURE;
      battery_props->batteryLevel = FAKE_BATTERY_CAPACITY;
      battery_props->batteryStatus = BatteryStatus::CHARGING;
      battery_props->chargerAcOnline = true;
      battery_props->chargerUsbOnline = false;
      battery_props->chargerWirelessOnline = false;
    }
  }
}

}  // namespace implementation
}  // namespace V2_1
}  // namespace health
}  // namespace hardware
}  // namespace android


extern "C" IHealth* HIDL_FETCH_IHealth(const char* instance) {
  using ::android::hardware::health::V2_1::implementation::HealthImpl;
  if (instance != "default"sv) {
      return nullptr;
  }
  auto config = std::make_unique<healthd_config>();
  InitHealthdConfig(config.get());

  return new HealthImpl(std::move(config));
}
