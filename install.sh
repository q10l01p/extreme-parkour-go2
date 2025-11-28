#!/usr/bin/env bash
set -e

# 一键创建并配置 conda 环境（默认名：parkour）
# 使用方式：
#   bash install.sh            # 使用默认环境名 parkour
#   bash install.sh my_env     # 使用自定义环境名 my_env

ENV_NAME="${1:-parkour_go2}"
PYTHON_VERSION="3.8"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v conda >/dev/null 2>&1; then
  echo "未找到 conda，请先安装 Miniconda/Anaconda 并在当前 shell 中可用。"
  exit 1
fi

echo ">>> 使用 conda 环境: ${ENV_NAME}"

# 创建环境（如果不存在）
if conda env list | awk '{print $1}' | grep -Fxq "${ENV_NAME}"; then
  echo "conda 环境 '${ENV_NAME}' 已存在，跳过创建。"
else
  echo "创建 conda 环境 '${ENV_NAME}' (python=${PYTHON_VERSION})..."
  conda create -n "${ENV_NAME}" "python=${PYTHON_VERSION}" -y
fi

CONDARUN="conda run -n ${ENV_NAME}"

echo ">>> 安装 PyTorch 1.10.0 + cu113 ..."
${CONDARUN} python -m pip install --upgrade pip
${CONDARUN} python -m pip install \
  torch==1.10.0+cu113 \
  torchvision==0.11.1+cu113 \
  torchaudio==0.10.0+cu113 \
  -f https://download.pytorch.org/whl/cu113/torch_stable.html

echo ">>> 安装项目依赖包 ..."
${CONDARUN} python -m pip install "numpy<1.24" pydelatin wandb tqdm opencv-python ipdb pyfqmr flask

echo ">>> 安装 Isaac Gym Python 绑定（需提前将 Isaac Gym 解压到 ${ROOT_DIR}/isaacgym）..."
${CONDARUN} python -m pip install -e "${ROOT_DIR}/isaacgym/python"

echo ">>> 安装 rsl_rl (editable 模式) ..."
${CONDARUN} python -m pip install -e "${ROOT_DIR}/rsl_rl"

echo ">>> 安装 legged_gym (editable 模式) ..."
${CONDARUN} python -m pip install -e "${ROOT_DIR}/legged_gym"

echo
echo "================ 安装完成 ================"
echo "已准备好 conda 环境: ${ENV_NAME}"
echo "请在新终端中执行："
echo "  conda activate ${ENV_NAME}"
echo "然后进入工程目录运行训练/测试脚本。"
