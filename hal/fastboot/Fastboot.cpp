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

#include "fastboot/Fastboot.h"

#include <string>
#include <unordered_map>
#include <vector>

#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/strings.h>
#include <android-base/unique_fd.h>

namespace android {
namespace hardware {
namespace fastboot {
namespace V1_1 {
namespace implementation {

static bool starts_with(const std::string str, const std::string prefix)
{
    return ((prefix.size() <= str.size()) && std::equal(prefix.begin(), prefix.end(), str.begin()));
}

// Methods from ::android::hardware::fastboot::V1_1::IFastboot follow.
Return<void> Fastboot::getPartitionType(const hidl_string&  partitionName,
                                        getPartitionType_cb _hidl_cb) {
    if (partitionName == "userdata") {
        _hidl_cb(FileSystemType::F2FS, {Status::SUCCESS, ""});
    } else if (starts_with(partitionName, "system")) {
        _hidl_cb(FileSystemType::EXT4, {Status::SUCCESS, ""});
    } else if (starts_with(partitionName, "vendor")) {
        _hidl_cb(FileSystemType::EXT4, {Status::SUCCESS, ""});
    } else {
        _hidl_cb(FileSystemType::RAW, {Status::SUCCESS, ""});
    }
    return Void();
}

Return<void> Fastboot::doOemCommand(const hidl_string& /* oemCmd */, doOemCommand_cb _hidl_cb) {
    _hidl_cb({Status::FAILURE_UNKNOWN, "Command not supported in default implementation"});
    return Void();
}

Return<void> Fastboot::getVariant(getVariant_cb _hidl_cb) {
    _hidl_cb("NA", {Status::SUCCESS, ""});
    return Void();
}

Return<void> Fastboot::getOffModeChargeState(getOffModeChargeState_cb _hidl_cb) {
    _hidl_cb(false, {Status::SUCCESS, ""});
    return Void();
}

Return<void> Fastboot::getBatteryVoltageFlashingThreshold(
        getBatteryVoltageFlashingThreshold_cb _hidl_cb) {
    _hidl_cb(0, {Status::SUCCESS, ""});
    return Void();
}

Return<void> Fastboot::doOemSpecificErase(doOemSpecificErase_cb _hidl_cb) {
    _hidl_cb({Status::NOT_SUPPORTED, "Command not supported in default implementation"});
    return Void();
}

Fastboot::Fastboot() {}

extern "C" IFastboot* HIDL_FETCH_IFastboot(const char* /* name */) {
    return new Fastboot();
}


}  // namespace implementation
}  // namespace V1_1
}  // namespace fastboot
}  // namespace hardware
}  // namespace android
