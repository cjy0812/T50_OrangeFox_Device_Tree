#
# OrangeFox Recovery - Teclast T50 (tb8786p1_64_k510_wifi)
# Platform: MediaTek MT8786 / MT6768 (Helio G80)
# V1: minimal, build-first, evidence-based
#

DEVICE_PATH := device/alps/tb8786p1_64_k510_wifi

# Architecture
# Evidence: boot_a.bin kernel magic 0x644d5241 (ARM64), DTB: arm,cortex-a75 + arm,cortex-a55
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Platform
# Evidence: ramdisk ro.board.platform=mt6768
TARGET_BOARD_PLATFORM := mt6768
TARGET_BOOTLOADER_BOARD_NAME := tb8786p1_64_k510_wifi
TARGET_NO_BOOTLOADER := true
BOARD_USES_MTK_HARDWARE := true

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    vendor_boot \
    dtbo \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    system \
    system_ext \
    vendor \
    product

# Kernel & vendor_boot recovery
# Evidence: vendor_boot_a.bin header_v4 parsed with AOSP vendor_boot_img_hdr_v3 layout
# Evidence: kernel_addr=0x40080000, ramdisk_addr=0x47c80000
# Evidence: tags_addr=0x4bc80000, dtb_addr=0x4bc80000 (from stock vendor_boot_a.bin)
# Evidence: page_size=4096, header_size=2128
TARGET_NO_KERNEL := true
TARGET_NO_RECOVERY := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x07c08000
BOARD_KERNEL_TAGS_OFFSET := 0x0bc08000
BOARD_DTB_OFFSET := 0x0bc08000

# DTB
# Evidence: vendor_boot_a.bin contains MTK DTBO pool (magic=0xd7b7ab1e)
# Evidence: prebuilt/dtb.img already extracted from vendor_boot
# NOTE: BOARD_INCLUDE_DTB_IN_BOOTIMG removed — in vendor_boot recovery mode,
# DTB is passed via BOARD_MKBOOTIMG_ARGS --dtb, not embedded in boot image.
# klee (MT6899, same vendor_boot recovery pattern) does not set this.
BOARD_KERNEL_SEPARATED_DTBO := true
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img

# vendor_cmdline
# Evidence: extracted from vendor_boot_a.bin header offset 0x1C
BOARD_VENDOR_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.selinux=permissive

# MKBOOTIMG args
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_MKBOOTIMG_ARGS += --vendor_cmdline "$(BOARD_VENDOR_CMDLINE)"
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE) --board ""
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)

# vendor_boot recovery (OrangeFox)
# Evidence: stock vendor_boot has 1 PLATFORM fragment (20.9 MB), no RECOVERY fragment
# Evidence: MediaTek bootloader only loads PLATFORM fragment on normal boot
# Evidence: Setting BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT empty → no RECOVERY fragment
#   BUT vendor_ramdisk (PLATFORM) is also empty (20 bytes) → bootloop
# Evidence: Setting BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT true → RECOVERY fragment created
#   → PLATFORM is empty → bootloop (MediaTek doesn't load RECOVERY fragment)
# Solution: Build with BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
#   → Creates both PLATFORM (vendor) + RECOVERY (recovery) fragments
#   → Post-process with repack_vendor_boot.py to merge into single PLATFORM fragment
#   → MediaTek bootloader can load PLATFORM normally, recovery content included
FOX_VENDOR_BOOT_RECOVERY := 1
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

# Partitions
# Evidence: boot_a.bin = 33554432 bytes (32 MiB)
# Evidence: vendor_boot_a.bin = 67108864 bytes (64 MiB)
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_SUPER_PARTITION_GROUPS := alps_dynamic_partitions
BOARD_ALPS_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext vendor product
BOARD_ALPS_DYNAMIC_PARTITIONS_SIZE := 9122611200

# File systems
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
TARGET_COPY_OUT_VENDOR := vendor

# Recovery
# Pixel format fix (2026-09-05): BGRA_8888 → RGBA_8888
# Evidence: Vernee M5 (MTK platform, same as T50) uses RGBA_8888
# BGRA caused red-blue channel swap → blue/purple tint on display
TARGET_RECOVERY_PIXEL_FORMAT := RGBA_8888
TARGET_USES_LOGD := true
BOARD_HAS_NO_SELECT_BUTTON := true

# Build workarounds
ALLOW_MISSING_DEPENDENCIES := true

# AVB
BOARD_AVB_ENABLE := true

# TWRP / OrangeFox UI
# Screen for landscape tablet (2400x1600)
# NOTE: OrangeFox R12.1 only has portrait_hdpi and watch_mdpi themes
#       landscape_hdpi does NOT exist → causes "Theme selection failed" build error
#
# Rotation history (2026-09-05):
#   v1: TW_ROTATION=270 → 180° upside-down (confirmed)
#   v2: TW_ROTATION=0   → portrait/vertical (wrong for landscape device)
#   v3: TW_ROTATION=90  → attempting correct landscape orientation
#
# MTK graphics stack may have additional rotation layer that
# differs from standard TWRP behavior
TW_THEME            := portrait_hdpi
TW_ROTATION         := 90
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 128

# Touchscreen: DISABLED for v3
# v2: SWAP_XY + FLIP_Y caused complete touch failure
# Strategy: Fix screen rotation first, then calibrate touch coordinates
# RECOVERY_TOUCHSCREEN_SWAP_XY := true
# RECOVERY_TOUCHSCREEN_FLIP_Y := true
TW_EXTRA_LANGUAGES := true
TW_INCLUDE_REPACKTOOLS := true