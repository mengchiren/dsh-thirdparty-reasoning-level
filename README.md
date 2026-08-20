# DSH 第三方模型推理等级配置（火山方舟 Coding Plan）

为 DSH（DeepSeek Harness）的第三方自定义厂商配置**模型推理等级**的完整方案：
配置模板、使用说明、以及 pi-ai 方舟兼容补丁。

## 背景

DSH 原生支持第三方模型推理等级，链路为：`settings.yaml` 声明 → 模型选择器
UI 下拉 → 按等级映射线上参数。缺的只是厂商配置里的能力声明：

- 每个模型须声明 `reasoningEfforts`（等级 → 线上参数值），未声明 = 不支持推理等级；
- 推理方言 `compat.thinkingFormat`（deepseek / qwen / openai 等）仅对
  `openai-completions` 协议生效；
- 方舟 coding 端点须走 OpenAI 兼容面 `https://ark.cn-beijing.volces.com/api/coding/v3`。

## 文件清单

| 文件 | 说明 |
|---|---|
| `fangzhou-coding-plan-provider.yaml` | 可复用厂商配置模板（deepseek / glm / kimi 配方，含注释） |
| `使用说明.md` | 完整文档：原理、验证步骤、坑位清单、迁移指南 |
| `reapply-pi-ai-ark-patch.ps1` | pi-ai 方舟兼容补丁重打脚本（DSH 升级后一键重打，幂等） |
| `openai-completions.js.original` | pi-ai 原始文件备份（补丁前状态） |
| `settings.yaml.backup-*` | settings.yaml 修改前备份（无密钥，仅配置） |

## 快速开始

1. 把 `fangzhou-coding-plan-provider.yaml` 的 `fangzhou:` 段粘贴进
   `%USERPROFILE%\.dsh\settings.yaml` 的 `llm-pi-ai.providers:` 下（保存即热生效）；
2. 确保环境变量 `FANGZHOU_API_KEY` 存在；
3. 若 DSH 更新过 node_modules，运行 `reapply-pi-ai-ark-patch.ps1` 重打补丁并重启 DSH；
4. 打开模型选择器：deepseek 模型可选 Low/High/Max，glm-5.3 可选
   Off/Low/Medium/High/Max。

## 推理等级速查（方舟 Coding Plan，实测/官方文档）

| 模型 | 档位 | 线上参数 |
|---|---|---|
| deepseek-v4-flash / pro | Low / High / Max | `thinking:{type:"enabled"}` + `reasoning_effort` |
| glm-5.3 | Off(low) / Low / Medium / High / Max | `reasoning_effort`（思考不可关闭，low≈off） |
| kimi-k2.7-code | High | `enable_thinking`（thinkingFormat: qwen） |

详见 `使用说明.md`（含 7 个坑位、设置页写回、GBK 乱码、agent-default-model 注意事项等）。
