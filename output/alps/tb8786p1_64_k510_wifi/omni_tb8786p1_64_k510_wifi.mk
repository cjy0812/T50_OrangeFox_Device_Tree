#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff.
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from tb8786p1_64_k510_wifi device
$(call inherit-product, device/alps/tb8786p1_64_k510_wifi/device.mk)

PRODUCT_DEVICE := tb8786p1_64_k510_wifi
PRODUCT_NAME := omni_tb8786p1_64_k510_wifi
PRODUCT_BRAND := alps
PRODUCT_MODEL := tb8786p1_64_k510_wifi
PRODUCT_MANUFACTURER := alps

PRODUCT_GMS_CLIENTID_BASE := android-alps

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="vnd_tb8786p1_64_k510_wifi-userdebug 12 SP1A.210812.016 9UV7 test-keys"

BUILD_FINGERPRINT := alps/vnd_tb8786p1_64_k510_wifi/tb8786p1_64_k510_wifi:12/SP1A.210812.016/9UV7:userdebug/test-keys
