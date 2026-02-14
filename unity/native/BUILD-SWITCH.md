# Nintendo Switch 平台编译指南

本指南说明如何为 Nintendo Switch 平台编译 PuertsCore 和 PapiQuickjs 静态库。

## 前置要求

1. **Nintendo Switch SDK** (必需)
   - 必须安装官方的 Nintendo Switch SDK
   - 设置环境变量 `NINTENDO_SDK_ROOT` 指向 SDK 安装目录
   - 例如: `C:\Nintendo\NintendoSDK\`

2. **PowerShell** (必需)
   - Windows 10/11 自带

3. **CMake** (可选 - 仅用于 CMake 方式编译)
   - 版本 3.9 或更高
   - 添加到系统 PATH

4. **Ninja Build System** (可选 - 仅用于 CMake 方式编译)
   - 下载: https://github.com/ninja-build/ninja/releases
   - 添加到系统 PATH

## 编译步骤

### 方法 1: 直接编译 (推荐 - 不需要 CMake)

这种方法直接使用 Nintendo SDK 的编译器，不需要安装 CMake 或 Ninja。

#### 一键编译所有库

在 `native` 目录下运行:

```powershell
# Release 版本 (默认)
.\build_switch_direct.ps1

# Debug 版本
.\build_switch_direct.ps1 Debug
```

#### 单独编译

编译 PuertsCore:
```powershell
cd native\puerts
.\make_switch_direct.ps1          # Release 版本
.\make_switch_direct.ps1 Debug    # Debug 版本
```

编译 PapiQuickjs:
```powershell
cd native\papi-quickjs
.\make_switch_direct.ps1          # Release 版本
.\make_switch_direct.ps1 Debug    # Debug 版本
```

输出文件:
- `native\puerts\lib\libPuertsCore.a`
- `native\papi-quickjs\build_switch\libPapiQuickjs.a`

### 方法 2: 使用 CMake 编译 (需要安装 CMake)

如果你已经安装了 CMake 和 Ninja，可以使用这种方法。

#### 一键编译所有库

在 `native` 目录下运行:

```powershell
# Release 版本 (默认)
.\build_switch_all.ps1

# Debug 版本
.\build_switch_all.ps1 Debug
```

#### 单独编译

编译 PuertsCore:
```powershell
cd native\puerts
.\make_switch.ps1          # Release 版本
.\make_switch.ps1 Debug    # Debug 版本
```

编译 PapiQuickjs:
```powershell
cd native\papi-quickjs
.\make_switch.ps1          # Release 版本
.\make_switch.ps1 Debug    # Debug 版本
```

输出文件:
- `native\puerts\lib\libPuertsCore.a`
- `native\papi-quickjs\build_switch\libPapiQuickjs.a`

## 输出文件

编译成功后，会生成以下静态库:

- `native/puerts/lib/libPuertsCore.a` - Puerts 核心库
- `native/papi-quickjs/build_switch/libPapiQuickjs.a` - QuickJS PAPI 适配层

## Unity 集成

1. 在 Unity 项目中创建目录: `Assets/Plugins/Switch/`

2. 复制静态库文件到该目录:
   ```
   Assets/Plugins/Switch/libPuertsCore.a
   Assets/Plugins/Switch/libPapiQuickjs.a
   ```

3. 在 Unity 中选中这些 .a 文件，在 Inspector 中:
   - 设置 Platform 为 Switch
   - 确保 "Load on startup" 已勾选

4. 构建 Switch 平台时，Unity 会自动链接这些静态库

## 技术细节

### 编译器配置

- **Target**: `aarch64-nintendo-nx-elf`
- **Architecture**: ARMv8-A (Cortex-A57)
- **Compiler**: Nintendo Clang (来自 Nintendo SDK)
- **优化级别**:
  - Release: `-O2` with function/data sections
  - Debug: `-O0 -g`

### 编译选项

- `-fPIC`: 位置无关代码
- `-D__SWITCH__`: Switch 平台宏定义
- `-fno-exceptions`: 禁用 C++ 异常
- `-fno-rtti`: 禁用运行时类型信息
- `-march=armv8-a -mtune=cortex-a57`: 针对 Switch 硬件优化

### CMake 工具链

工具链文件位于: `native/cmake/switch.toolchain.cmake`

该文件配置了:
- Switch 平台的编译器路径
- 目标架构和编译标志
- Nintendo SDK 包含路径
- 静态库构建设置

## 故障排除

### 错误: NINTENDO_SDK_ROOT 未设置

确保已安装 Nintendo Switch SDK 并设置环境变量:

```powershell
$env:NINTENDO_SDK_ROOT = "C:\Nintendo\NintendoSDK"
```

或在系统环境变量中永久设置。

### 错误: 找不到编译器

检查 Nintendo SDK 安装是否完整，编译器应该位于:
```
%NINTENDO_SDK_ROOT%\Compilers\NintendoClang\bin\clang.exe
```

### 错误: CMake 配置失败

1. 确认 CMake 版本 >= 3.9
2. 检查工具链文件路径是否正确
3. 查看详细错误信息

### 编译警告

某些警告是正常的，只要最终生成了 .a 文件即可。

## 注意事项

1. **静态库**: Switch 平台使用静态库 (.a)，不是动态库 (.so)
2. **依赖关系**: PapiQuickjs 依赖 PuertsCore，必须先编译 PuertsCore
3. **EASTL**: 项目使用 EASTL 库，已包含在源码中
4. **QuickJS**: QuickJS 源码位于 `papi-quickjs/quickjs/` 目录

## 参考

- CMakeLists.txt 中已配置 Switch 平台支持 (第 42 行和第 150 行)
- 当 `SWITCH_PLATFORM` 为 ON 时，自动构建静态库
- 工具链文件参考了之前 QuickJS 项目的 Switch 编译配置
