#For QSSI, we build only the system image. Here we explicitly set the images
#we build so there is no confusion.

TARGET_BOARD_PLATFORM := qssi
TARGET_BOOTLOADER_BOARD_NAME := qssi_au_64
TARGET_BOARD_TYPE := auto
TARGET_BOARD_SUFFIX := _au_64

TARGET_BOARD_AUTO := true
TARGET_NO_TELEPHONY := true

DEVICE_SUPPORTS_64_BIT_APPS_ONLY := true

# Skip VINTF checks for kernel configs since we do not have kernel source
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

#Enable product partition Native I/F. It is automatically set to current if
#the shipping API level for the target is greater than 29
PRODUCT_PRODUCT_VNDK_VERSION := current
#TODO(amutyala) to revert once QSSI 15 component created
#This change requires to build super image (QSSI15 + V14)
ifeq (,$(filter VanillaIceCream V 35, $(PLATFORM_VNDK_VERSION)))
PRODUCT_EXTRA_VNDK_VERSIONS := 32 33
else
PRODUCT_EXTRA_VNDK_VERSIONS := 33 34
endif
RELAX_USES_LIBRARY_CHECK := true

#Enable product partition Java I/F. It is automatically set to true if
#the shipping API level for the target is greater than 29
PRODUCT_ENFORCE_PRODUCT_PARTITION_INTERFACE := true

PRODUCT_BUILD_SYSTEM_IMAGE := true
PRODUCT_BUILD_SYSTEM_OTHER_IMAGE := false
PRODUCT_BUILD_VENDOR_IMAGE := false
PRODUCT_BUILD_SYSTEM_EXT_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := false
PRODUCT_BUILD_CACHE_IMAGE := false
PRODUCT_BUILD_USERDATA_IMAGE := false

# Enable debugfs restrictions
PRODUCT_SET_DEBUGFS_RESTRICTIONS := true

#Also, there is no need to build an OTA package as this will be done later
#when we combine this system build with the non-system images.
TARGET_SKIP_OTA_PACKAGE := true
# Enable AVB 2.0
BOARD_AVB_ENABLE := true

BOARD_HAVE_QCOM_FM := false

#### Dynamic Partition Handling

####

# Retain the earlier default behavior i.e. ota config (dynamic partition was disabled if not set explicitly), so set
# SHIPPING_API_LEVEL to 28 if it was not set earlier (this is generally set earlier via build.sh per-target)
SHIPPING_API_LEVEL := 34

$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/cne_url*.mk)

#### Turning BOARD_DYNAMIC_PARTITION_ENABLE flag to TRUE will enable dynamic partition/super image creation.
BOARD_DYNAMIC_PARTITION_ENABLE ?= true
PRODUCT_SHIPPING_API_LEVEL := $(SHIPPING_API_LEVEL)

ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
# Enable chain partition for system, to facilitate system-only OTA in Treble.
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
PRODUCT_BUILD_RAMDISK_IMAGE := false
PRODUCT_BUILD_PRODUCT_IMAGE := false
else
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# Disable building the SUPER partition in this build. SUPER should be built
# after QSSI has been merged with the SoC build.
PRODUCT_BUILD_SYSTEM_EXT_IMAGE := true
PRODUCT_BUILD_PRODUCT_IMAGE := true
PRODUCT_BUILD_SUPER_PARTITION := false
PRODUCT_BUILD_RAMDISK_IMAGE := true
endif
#### Dynamic Partition Handling

PRODUCT_PRODUCT_PROPERTIES += \
    remote_provisioning.enable_rkpd=true \
    remote_provisioning.hostname=remoteprovisioning.googleapis.com \

PRODUCT_SOONG_NAMESPACES += \
    frameworks/base/boot \
    cts/tests/signature/api-check \
    hardware/google/av \
    hardware/google/interfaces

VENDOR_QTI_PLATFORM := qssi_au_64
VENDOR_QTI_DEVICE := qssi_au_64

#QSSI configuration
#Single system image project structure
TARGET_USES_QSSI := true

TARGET_USES_NEW_ION := true

TARGET_USES_GAS := false

ENABLE_AB ?= true

TARGET_DEFINES_DALVIK_HEAP := true
$(call inherit-product, device/qcom/qssi_au_64/common64.mk)
$(call inherit-product, packages/services/Car/car_product/build/car.mk)

#Inherit all except heap growth limit from phone-xhdpi-2048-dalvik-heap.mk
PRODUCT_PROPERTY_OVERRIDES  += \
     dalvik.vm.heapstartsize=8m \
     dalvik.vm.heapsize=512m \
     dalvik.vm.heaptargetutilization=0.75 \
     dalvik.vm.heapminfree=512k \
     dalvik.vm.heapmaxfree=8m


PRODUCT_NAME := $(VENDOR_QTI_DEVICE)
PRODUCT_DEVICE := $(VENDOR_QTI_DEVICE)
PRODUCT_BRAND := qti
PRODUCT_MODEL := qssi system image for arm64

#Initial bringup flags
TARGET_USES_AOSP := false
TARGET_USES_AOSP_FOR_AUDIO := false
TARGET_USES_QCOM_BSP := false

# RRO configuration
TARGET_USES_RRO := true


# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard
BOARD_FRP_PARTITION_NAME := frp

#Android EGL implementation
PRODUCT_PACKAGES += libGLES_android

PRODUCT_PACKAGES_DEBUG += avbctl

ifneq ($(TARGET_NO_TELEPHONY), true)
PRODUCT_BOOT_JARS += telephony-ext
PRODUCT_PACKAGES += telephony-ext
endif

TARGET_ENABLE_QC_AV_ENHANCEMENTS := false

TARGET_SYSTEM_PROP += device/qcom/qssi_au_64/system.prop

TARGET_DISABLE_DASH := true
TARGET_DISABLE_QTI_VPP := true

ifneq ($(TARGET_DISABLE_DASH), true)
    PRODUCT_BOOT_JARS += qcmediaplayer
endif

#Project is missing on sdm845, comment it for now
#ifneq ($(strip $(QCPATH)),)
#    PRODUCT_BOOT_JARS += libprotobuf-java_mls
#endif

PRODUCT_PACKAGES += android.hardware.media.omx@1.0-impl

# Audio configuration file
-include $(TOPDIR)vendor/qcom/opensource/audio-hal/primary-hal/configs/qssi/qssi.mk
-include $(TOPDIR)vendor/qcom/opensource/commonsys/audio/configs/qssi/qssi.mk
AUDIO_FEATURE_ENABLED_SVA_MULTI_STAGE := true
USE_LIB_PROCESS_GROUP := true

PRODUCT_PACKAGES += fs_config_files

ifeq ($(ENABLE_AB), true)
#A/B related packages
PRODUCT_PACKAGES += update_engine \
    update_engine_client \
    update_verifier \
    bootctrl.msmnile \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service

PRODUCT_HOST_PACKAGES += \
    brillo_update_payload

#Boot control HAL test app
PRODUCT_PACKAGES_DEBUG += bootctl
endif

#Healthd packages
PRODUCT_PACKAGES += \
    android.hardware.health@1.0-impl \
    android.hardware.health@1.0-convert \
    android.hardware.health@1.0-service \
    libhealthd.msm

DEVICE_FRAMEWORK_MANIFEST_FILE := device/qcom/qssi_au_64/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml

PRODUCT_PRODUCT_PROPERTIES += persist.adb.tcp.port=5555

#audio related module
PRODUCT_PACKAGES += libvolumelistener

# Display/Graphics
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.0-service \
    android.hardware.broadcastradio@1.0-impl

# Camera configuration file. Shared by passthrough/binderized camera HAL
PRODUCT_PACKAGES += camera.device@3.2-impl
PRODUCT_PACKAGES += camera.device@1.0-impl
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl
# Enable binderized camera HAL
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service_64

# Ethernet configuration file
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml

# Context hub HAL
PRODUCT_PACKAGES += \
    android.hardware.contexthub@1.0-impl.generic \
    android.hardware.contexthub@1.0-service

PRODUCT_SYSTEM_PROPERTIES += \
    persist.device_config.runtime_native_boot.iorap_perfetto_enable=true

PRODUCT_SYSTEM_PROPERTIES += ro.android.car.audio.enableaudiopatch=true

# USB default HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

#PASR HAL and APP
PRODUCT_PACKAGES += \
    vendor.qti.power.pasrmanager@1.0-service \
    vendor.qti.power.pasrmanager@1.0-impl \
    pasrservice

# CAN utils
PRODUCT_PACKAGES += candump \
                    cansend \
                    bcmserver \
                    can-calc-bit-timing \
                    canbusload \
                    canfdtest \
                    cangen \
                    cangw \
                    canlogserver \
                    canplayer \
                    cansniffer \
                    isotpdump \
                    isotprecv \
                    isotpsend \
                    isotpserver \
                    isotptun \
                    log2asc \
                    log2long \
                    slcan_attach \
                    slcand \
                    slcanpty

# Ethernet tools
PRODUCT_PACKAGES_DEBUG += ethtool \
                          tcpdump

# HS-I2S test app
PRODUCT_PACKAGES += hsi2s_test

# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/$(PRODUCT_NAME)/$(KERNEL_MODULES_INSTALL)/lib/modules

ifneq ($(strip $(TARGET_BUILD_VARIANT)),user)
PRODUCT_COPY_FILES += \
    device/qcom/qssi_au_64/init.qcom.testscripts.sh:$(TARGET_COPY_OUT_PRODUCT)/etc/init.qcom.testscripts.sh \
    device/qcom/qssi_au_64/init.qcom.testscripts.sh:$(TARGET_COPY_OUT_SYSTEM)/etc/init.qcom.testscripts.sh
endif

# copy system_ext specific whitelisted libraries to system_ext/etc
PRODUCT_COPY_FILES += \
    device/qcom/qssi_au_64/public.libraries.system_ext-qti.txt:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/public.libraries-qti.txt

#Enable full treble flag
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

ifneq ($(strip $(TARGET_USES_RRO)),true)
DEVICE_PACKAGE_OVERLAYS += device/qcom/qssi_au_64/overlay
endif

#Enable vndk-sp Libraries
PRODUCT_PACKAGES += vndk_package

PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE:=true


TARGET_MOUNT_POINTS_SYMLINKS := false

TARGET_USES_MKE2FS := true

PRODUCT_PROPERTY_OVERRIDES += \
ro.crypto.volume.filenames_mode = "aes-256-cts" \
ro.crypto.allow_encrypt_override = true

TARGET_USES_QCOM_DISPLAY_BSP := true

ifeq ($(TARGET_USES_NEW_ION),true)
AUDIO_FEATURE_ENABLED_DLKM := true
else
AUDIO_FEATURE_ENABLED_DLKM := false
endif

ifeq ($(ENABLE_VIRTUAL_AB), true)
    $(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
endif

# Include mainline components and QSSI whitelist
ifeq (true,$(call math_gt_or_eq,$(SHIPPING_API_LEVEL),29))
  $(call inherit-product, device/qcom/qssi_au_64/qssi_au_64_whitelist.mk)
  PRODUCT_ARTIFACT_PATH_REQUIREMENT_IGNORE_PATHS := /system/system_ext/
  PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := true
endif

PRODUCT_PACKAGES += vendor.qti.qesdsys

PRODUCT_PACKAGES += network_config_default

PRODUCT_COPY_FILES += \
    vendor/qcom/proprietary/commonsys/cne/automs_vlan/network_config_default.sh:$(TARGET_COPY_OUT_SYSTEM_EXT)/bin/network_config_default.sh

# Enable support for APEX updates
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Enable allowlist for some aosp packages that should not be scanned in a "stopped" state
# # Some CTS test case failed after enabling feature config_stopSystemPackagesByDefault
PRODUCT_PACKAGES += initial-package-stopped-states-aosp.xml

###################################################################################
# This is the End of target.mk file.
# Now, Pickup other split product.mk files:
###################################################################################
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/*.mk)
###################################################################################
