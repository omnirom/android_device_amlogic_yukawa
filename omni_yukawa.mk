ifndef TARGET_KERNEL_USE
TARGET_KERNEL_USE := 5.4-mod
endif

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

# Inherit the full_base and device configurations
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# must be before including vendor/omni
DEVICE_PACKAGE_OVERLAYS += device/amlogic/yukawa/overlay
TARGET_BOOTANIMATION_SIZE := 720p

$(call inherit-product, vendor/omni/config/common_tablet.mk)
$(call inherit-product, device/amlogic/yukawa/device-yukawa.mk)
$(call inherit-product, device/amlogic/yukawa/yukawa-common.mk)

PRODUCT_DEVICE := yukawa
PRODUCT_NAME := omni_yukawa
PRODUCT_BRAND := Khadas
PRODUCT_MODEL := VIM3
PRODUCT_MANUFACTURER := Khadas
