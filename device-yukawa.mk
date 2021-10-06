ifndef TARGET_KERNEL_USE
TARGET_KERNEL_USE := 5.4-mod
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

ifeq ($(TARGET_VIM3), true)
TARGET_DEV_BOARD := vim3
else ifeq ($(TARGET_VIM3L), true)
TARGET_DEV_BOARD := vim3l
else ifeq ($(TARGET_DEV_BOARD),)
TARGET_DEV_BOARD := sei610
endif

ifneq ($(filter $(TARGET_DEV_BOARD),vim3),)
AUDIO_DEFAULT_OUTPUT := hdmi
GPU_TYPE := gondul_ion
else ifneq ($(filter $(TARGET_DEV_BOARD),vim3l),)
AUDIO_DEFAULT_OUTPUT := hdmi
endif

# must be before including vendor/omni
DEVICE_PACKAGE_OVERLAYS += device/amlogic/yukawa/overlay
TARGET_BOOTANIMATION_SIZE := 720p

$(call inherit-product, vendor/omni/config/common_tablet.mk)

$(call inherit-product, device/amlogic/yukawa/device-common.mk)

PRODUCT_PROPERTY_OVERRIDES += ro.product.device=$(TARGET_DEV_BOARD)
# sets pre-device in OTA meta
PRODUCT_SYSTEM_PROPERTIES += ro.product.device=$(TARGET_DEV_BOARD)
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
