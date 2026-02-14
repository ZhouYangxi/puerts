# Switch 平台编译成功！

## 生成的文件

已成功为 Nintendo Switch 平台编译生成以下静态库:

1. **PuertsCore**: `native/puerts/lib/libPuertsCore.a` (85 KB)
2. **PapiQuickjs**: `native/papi-quickjs/build_switch/libPapiQuickjs.a` (1.8 MB)

## 快速编译命令

在 `native` 目录下运行:

```powershell
# 一键编译所有库 (推荐)
.\build_switch_direct.ps1

# 或者单独编译
cd puerts
.\make_switch_direct.ps1
cd ..\papi-quickjs
.\make_switch_direct.ps1
```

## Unity 集成步骤

1. 在 Unity 项目中创建目录:
   ```
   Assets/Plugins/Switch/
   ```

2. 复制静态库文件:
   ```
   native/puerts/lib/libPuertsCore.a          -> Assets/Plugins/Switch/
   native/papi-quickjs/build_switch/libPapiQuickjs.a -> Assets/Plugins/Switch/
   ```

3. 在 Unity Inspector 中配置:
   - 选中两个 .a 文件
   - Platform 设置为 "Switch"
   - 勾选 "Load on startup"

4. 构建 Switch 平台时，Unity 会自动链接这些库

## 技术信息

- **编译器**: Nintendo Clang (来自 Nintendo SDK)
- **目标架构**: aarch64-nintendo-nx-elf (ARMv8-A, Cortex-A57)
- **库类型**: 静态库 (.a)
- **优化级别**: -O2 (Release)
- **特殊配置**:
  - 禁用 C++ 异常和 RTTI
  - 位置无关代码 (PIC)
  - 函数和数据段分离

## 重新编译

如果需要重新编译，脚本会自动清理旧的构建文件。

## 依赖关系

- PapiQuickjs 依赖 PuertsCore
- 在 Unity 中链接时，两个库都需要

## 注意事项

- 这些是静态库 (.a)，不是动态库 (.so)
- Switch 平台不支持动态链接
- 已修改 EASTL 配置以支持 Switch 平台
- WSPPAddon (WebSocket 支持) 未编译，如需要请单独处理
