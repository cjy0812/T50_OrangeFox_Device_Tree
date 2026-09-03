# T50 OrangeFox 项目完整上下文摘要

## 【背景信息】

用户拥有台电 T50 平板（MT8786/MT6768, codename: tb8786p1_64_k510_wifi），目标构建 OrangeFox R12.1 Recovery。设备为 Virtual A/B 架构、Dynamic Partitions、vendor_boot recovery 模式。用户从设备提取了原始 boot/vendor_boot/init_boot/lk 镜像，通过静态分析获取了关键参数。

## 【讨论主题】

为 T50 构建最小可编译的 OrangeFox R12.1 vendor_boot recovery，通过 CI (GitHub Actions) 自动构建，并通过构建产物验证之前无法确认的参数。

## 【重要信息】

### 设备硬件/固件参数
- SoC: MediaTek MT8786 (MT6768), 8核
- codename: tb8786p1_64_k510_wifi
- 架构: Virtual A/B, Dynamic Partitions
- boot header version: 4
- kernel pagesize: 4096
- kernel base: 0x40078000
- kernel offset: 0x00008000
- ramdisk offset: 0x07c08000
- kernel tags offset: 0x07c08000
- dtb offset: 0x07c08000
- cmdline: bootopt=64S3,32N2,64N2 androidboot.selinux=permissive androidboot.mmitest=true buildvariant=userdebug
- kernel_load_addr: 0x40080000
- tags_addr: 0x47c80000 (MTK非标准: 存储vendor_ramdisk_size)

### 原始镜像分析结果
- boot_a.bin: header v4, kernel_size=4 (无效值), 含ramdisk
- vendor_boot_a.bin: header v4, 含DTB + vendor ramdisk + recovery ramdisk fragment
- init_boot_a.bin: header v4, 含GKI kernel
- lk_a.bin: MediaTek LK bootloader
- DTB: MTK DTBO池结构 (magic=0xd7b7ab1e)

### BoardConfig.mk 关键变量
- FOX_VENDOR_BOOT_RECOVERY := 1
- TARGET_NO_KERNEL := true
- TARGET_NO_RECOVERY := true
- BOARD_BOOT_HEADER_VERSION := 4
- BOARD_KERNEL_PAGESIZE := 4096
- BOARD_KERNEL_BASE := 0x40078000
- BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
- BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
- BOARD_KERNEL_SEPARATED_DTBO := true
- TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
- ALLOW_MISSING_DEPENDENCIES := true
- BOARD_INCLUDE_DTB_IN_BOOTIMG: 已移除

### 仓库分工
| 仓库 | 角色 | 可见性 |
|------|------|--------|
| cjy0812/T50_OrangeFox_Device_Tree | 设备树文件 | public |
| cjy0812/T50-OrangeFox | CI workflow + 文档 | public |

### CI Workflow
- 源码同步: orangefox_sync.sh --branch 12.1
- 构建命令: mka adbd vendorbootimage
- lunch目标: twrp_tb8786p1_64_k510_wifi-eng
- 构建步骤开头: set +e
- SSH调试: ENABLE_SSH参数控制

## 【已经确认的结论】
1. vendor_boot不含kernel → TARGET_NO_KERNEL=true
2. vendor_boot recovery模式下DTB通过--dtb传入 → 移除BOARD_INCLUDE_DTB_IN_BOOTIMG
3. OrangeFox使用twrp_前缀 → omni_改为twrp_
4. add_lunch_combo在AOSP 12.1已obsolete → 使用COMMON_LUNCH_CHOICES
5. GitHub Actions shell:bash无效仍用bash -e → set +e是唯一可靠方式
6. 设备树文件必须在仓库根目录
7. MTK非标准vendor_boot头部: tags_addr存储vendor_ramdisk_size
8. klee (MT6899) 是参考设备树

## 【未解决问题】
1. CI构建source build/envsetup.sh后exit 1根因未完全确认 (set +e应已修复待Run5验证)
2. UNKNOWN变量待构建产物验证: BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE, BOARD_MKBOOTIMG_ARGS等
3. 构建产物尚未生成

## 【后续继续对话时需要知道】
- 当前CI Run#5 (33717652107) 带SSH调试正在运行
- 构建步骤已加set +e 这是第5次尝试
- 前四次失败已全部修复
- Memory MCP有路径bug 项目记忆用ck skill
- 不要重新分析已确认参数 直接进入构建结果分析
- 本轮约束：不刷机、不修改LK、不猜测未知参数
- 用户GitHub: cjy0812

## 【CI失败历史】
| Run | 原因 | 修复 |
|-----|------|------|
| #1 (33641623825) | 设备树private无法clone | 改为public |
| #2 (33643280942) | 设备树文件在子目录路径不匹配 | 重构到根目录 |
| #3 (33646063664) | add_lunch_combo obsolete导致bash -e退出 | 清空vendorsetup.sh |
| #4 (33716315517) | shell:bash无效GA仍用bash -e | 改用set +e |
| #5 (33717652107) | 运行中 带SSH调试 | 待验证 |