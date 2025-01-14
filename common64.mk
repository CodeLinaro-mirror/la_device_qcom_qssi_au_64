$(call inherit-product, device/qcom/qssi_au_64/base.mk)

# For PRODUCT_COPY_FILES, the first instance takes precedence.
# Since we want use QC specific files, we should inherit
# device-vendor.mk first to make sure QC specific files gets installed.
$(call inherit-product-if-exists, $(QCPATH)/common/config/device-vendor-qssi.mk)
ifeq ($(DEVICE_SUPPORTS_64_BIT_APPS_ONLY),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
endif
ifeq ($(TARGET_BOARD_AUTO), true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)
endif

PRODUCT_BRAND := qcom
PRODUCT_AAPT_CONFIG += hdpi mdpi

PRODUCT_MANUFACTURER := QTI

PRODUCT_PROPERTY_OVERRIDES += \
    persist.backup.ntpServer=0.pool.ntp.org \
    sys.vendor.shutdown.waittime=500

ifneq ($(ENABLE_HYP),true)
ifneq ($(BOARD_FRP_PARTITION_NAME),)
    PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/bootdevice/by-name/$(BOARD_FRP_PARTITION_NAME)
else
    PRODUCT_PROPERTY_OVERRIDES += ro.frp.pst=/dev/block/bootdevice/by-name/config
endif
endif

# whitelisted app
PRODUCT_COPY_FILES += \
    device/qcom/qssi/qti_whitelist.xml:system/etc/sysconfig/qti_whitelist.xml \

PRODUCT_COPY_FILES += \
    device/qcom/qssi/privapp-permissions-qti.xml:system/etc/permissions/privapp-permissions-qti.xml \

PRODUCT_PRIVATE_KEY := vendor/qcom/opensource/core-utils/build/qcom.key

ifneq ($(TARGET_DEFINES_DALVIK_HEAP), true)
ifneq ($(TARGET_HAS_LOW_RAM), true)
$(call inherit-product, frameworks/native/build/phone-xhdpi-1024-dalvik-heap.mk)
endif
endif

#$(call inherit-product, frameworks/base/data/fonts/fonts.mk)
#$(call inherit-product, frameworks/base/data/keyboards/keyboards.mk)
