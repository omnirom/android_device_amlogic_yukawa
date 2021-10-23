ifndef TARGET_KERNEL_USE
TARGET_KERNEL_USE = 5.4-mod
endif

ifndef TARGET_USE_TABLET_LAUNCHER
TARGET_USE_TABLET_LAUNCHER = true
endif

ifndef TARGET_VIM3
TARGET_VIM3 = true
endif

ifndef TARGET_USE_AB_SLOT
TARGET_USE_AB_SLOT = true
endif

ifndef TARGET_AVB_ENABLE
TARGET_AVB_ENABLE = true
endif

# must be before including vendor/omni
DEVICE_PACKAGE_OVERLAYS += device/amlogic/yukawa/overlay
TARGET_BOOTANIMATION_SIZE := 720p

$(call inherit-product, vendor/omni/config/common_tablet.mk)

$(call inherit-product, device/amlogic/yukawa/device-common.mk)

ifeq ($(TARGET_VIM3), true)
PRODUCT_PROPERTY_OVERRIDES += ro.product.device=vim3
# sets pre-device in OTA meta
PRODUCT_SYSTEM_PROPERTIES += ro.product.device=vim3
AUDIO_DEFAULT_OUTPUT := hdmi
GPU_TYPE := gondul_ion
else ifeq ($(TARGET_VIM3L), true)
PRODUCT_PROPERTY_OVERRIDES += ro.product.device=vim3l
AUDIO_DEFAULT_OUTPUT := hdmi
else
PRODUCT_PROPERTY_OVERRIDES += ro.product.device=sei610
endif
GPU_TYPE ?= dvalin_ion

BOARD_KERNEL_DTB := device/amlogic/yukawa-kernel/$(TARGET_KERNEL_USE)

ifeq ($(TARGET_PREBUILT_DTB),)
LOCAL_DTB := $(BOARD_KERNEL_DTB)
else
LOCAL_DTB := $(TARGET_PREBUILT_DTB)
endif

# Feature permissions
PRODUCT_COPY_FILES += \
    device/amlogic/yukawa/permissions/yukawa.xml:/system/etc/sysconfig/yukawa.xml

# Speaker EQ
PRODUCT_COPY_FILES += \
    device/amlogic/yukawa/hal/audio/speaker_eq_sei610.fir:$(TARGET_COPY_OUT_VENDOR)/etc/speaker_eq_sei610.fir
