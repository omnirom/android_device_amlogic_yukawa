MKDTIMG := system/libufdt/utils/src/mkdtboimg.py
DTBIMAGE := $(PRODUCT_OUT)/dtb.img
DTBOIMAGE := $(PRODUCT_OUT)/$(DTBO_UNSIGNED)
LOCAL_DTB := $(DTB_OUT)/arch/arm64/boot/dts/amlogic
LOCAL_DTBO := $(DTBO_OUT)/arch/arm64/boot/dts/amlogic

# Please keep this list fixed: add new files in the end of the list
DTB_FILES := \
	$(LOCAL_DTB)/meson-g12a-sei510.dtb \
	$(LOCAL_DTB)/meson-sm1-sei610.dtb \
	$(LOCAL_DTB)/meson-sm1-khadas-vim3l.dtb \
	$(LOCAL_DTB)/meson-g12b-a311d-khadas-vim3.dtb

# Please keep this list fixed: add new files in the end of the list
DTBO_FILES := \
	$(LOCAL_DTBO)/meson-g12a-sei510-android.dtb \
	$(LOCAL_DTBO)/meson-sm1-sei610-android.dtb \
	$(LOCAL_DTBO)/meson-sm1-khadas-vim3l-android.dtb \
	$(LOCAL_DTBO)/meson-g12b-a311d-khadas-vim3-android.dtb \

$(BOARD_PREBUILT_DTBOIMAGE): $(DTC) $(MKDTIMG)
	@echo "Building custom dtbo.img"
	$(call make-dtbo-target,$(KERNEL_DEFCONFIG))
	$(call make-dtbo-target,dtbs)
	$(MKDTIMG) create $@ $(DTBO_FILES)

$(INSTALLED_DTBIMAGE_TARGET): $(DTC)
	@echo "Building custom dtb.img"
	$(call make-dtb-target,$(KERNEL_DEFCONFIG))
	$(call make-dtb-target,dtbs)
	cat $(DTB_FILES) > $@
