ifndef TARGET_USE_TABLET_LAUNCHER
TARGET_USE_TABLET_LAUNCHER := true
endif

ifndef TARGET_VIM3
TARGET_VIM3 := true
endif

ifndef TARGET_USE_AB_SLOT
TARGET_USE_AB_SLOT := true
endif

ifndef TARGET_AVB_ENABLE
TARGET_AVB_ENABLE := true
endif

TARGET_BUILD_KERNEL := true

# Inherit the full_base and device configurations
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# must be before including vendor/omni
DEVICE_PACKAGE_OVERLAYS += device/amlogic/yukawa/overlay
TARGET_BOOTANIMATION_SIZE := 720p

$(call inherit-product, vendor/omni/config/common_tablet.mk)
$(call inherit-product, device/amlogic/yukawa/device-yukawa.mk)
$(call inherit-product, device/amlogic/yukawa/yukawa-common.mk)

PRODUCT_DEVICE := yukawa
PRODUCT_NAME := omni_yukawa
PRODUCT_BRAND := Android
PRODUCT_MODEL := VIM3
PRODUCT_MANUFACTURER := Khadas

# make it a tablet
PRODUCT_COPY_FILES +=  \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml

# just set a default
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.cpufreq.governor=conservative

# just here as reference
#PRODUCT_PROPERTY_OVERRIDES += debug.sf.disable_hwc_overlays=1 \
    vendor.hwc.drm.scale_with_gpu=1

# graphics
PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.egl=mali

PRODUCT_VENDOR_PROPERTIES += \
    ro.hardware.vulkan=mali

# Configure EGL blobcache
PRODUCT_VENDOR_PROPERTIES += \
    ro.egl.blobcache.multifile=true \
    ro.egl.blobcache.multifile_limit=33554432 \

PRODUCT_VENDOR_PROPERTIES += \
    ro.opengles.version=196610 \
    debug.renderengine.backend=skiaglthreaded
    
# Wifi
PRODUCT_PROPERTY_OVERRIDES += ro.boot.wificountrycode=00

# gps
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

PRODUCT_PACKAGES += \
    gps.yukawa

PRODUCT_PROPERTY_OVERRIDES += gps.device.path=/dev/ttyACM0

PRODUCT_PROPERTY_OVERRIDES += ro.surface_flinger.use_color_management=false \
    ro.surface_flinger.has_wide_color_display=false \
    ro.surface_flinger.has_HDR_display=false

# Additional apps
PRODUCT_PACKAGES += \
    DeviceParts \
    OmniProvision \
    Terminal

ifeq ($(ROM_BUILDTYPE),GAPPS)
PRODUCT_PACKAGES += \
    DeviceRegistration
endif

PRODUCT_PACKAGES += \
    RemovePackages

# widevine
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/binaries/drm/vendor/lib/mediadrm/libwvdrmengine.so:$(TARGET_COPY_OUT_VENDOR)/lib/mediadrm/libwvdrmengine.so \
    $(LOCAL_PATH)/binaries/drm/vendor/lib64/mediadrm/libwvdrmengine.so:$(TARGET_COPY_OUT_VENDOR)/lib64/mediadrm/libwvdrmengine.so \
    $(LOCAL_PATH)/binaries/drm/vendor/bin/hw/android.hardware.drm@1.3-service.widevine:$(TARGET_COPY_OUT_VENDOR)/bin/hw/android.hardware.drm@1.3-service.widevine \
    $(LOCAL_PATH)/binaries/drm/vendor/etc/init/android.hardware.drm@1.3-service.widevine.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/android.hardware.drm@1.3-service.widevine.rc \
    $(LOCAL_PATH)/binaries/drm/vendor/lib64/libwvhidl.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libwvhidl.so \
    $(LOCAL_PATH)/binaries/drm/vendor/lib64/libprotobuf-cpp-lite-3.9.1.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libprotobuf-cpp-lite-3.9.1.so

PRODUCT_PACKAGES += \
    android.hardware.drm@1.0.vendor \
    android.hardware.drm@1.1.vendor \
    android.hardware.drm@1.2.vendor \
    android.hardware.drm@1.3.vendor

PRODUCT_PACKAGES += \
    android.hardware.configstore@1.1-service

# power HAL
PRODUCT_PACKAGES += \
    android.hardware.power@1.1-impl \
    android.hardware.power@1.1-service.yukawa

# WiringPi
PRODUCT_PACKAGES += \
    gpio \
    adxl345

PRODUCT_PACKAGES += \
    androidx.window.extensions \
    androidx.window.sidecar

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.system.yukawa.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.yukawa.rc

# Enable USB Camera
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml

# for bringup to disable secure adb - copy adbkey.pub from ~/.android
#PRODUCT_ADB_KEYS := device/amlogic/yukawa/adbkey.pub
#PRODUCT_PACKAGES += \
    adb_keys

#PRODUCT_COPY_FILES += \
    device/amlogic/yukawa/input/Vendor_1fd2_Product_6003.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/Vendor_1fd2_Product_6003.idc
