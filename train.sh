#!/usr/bin/env bash

# Go2 两阶段训练脚本：
# 1）教师策略（无相机，RL 训练）
# 2）学生策略（开相机，视觉蒸馏学习）
# 使用前请先：conda activate parkour_go2

PROJ_NAME="rough_go2"
TEACHER_EXPTID="go2_teacher"
STUDENT_EXPTID="go2_student"

echo ">>> 阶段一：训练 Go2 教师策略（${TEACHER_EXPTID}）..."
python legged_gym/legged_gym/scripts/train.py \
  --task go2 \
  --num_envs 8196 \
  --proj_name "${PROJ_NAME}" \
  --exptid "${TEACHER_EXPTID}" \
  --max_iterations 100 \
  --wandb_offline

echo ">>> 阶段二：在教师策略基础上训练 Go2 学生策略（${STUDENT_EXPTID}，视觉蒸馏）..."
python legged_gym/legged_gym/scripts/train.py \
  --task go2 \
  --num_envs 8196 \
  --proj_name "${PROJ_NAME}" \
  --exptid "${STUDENT_EXPTID}" \
  --resumeid "${TEACHER_EXPTID}" \
  --use_camera \
  --max_iterations 100 \
  --wandb_offline

echo ">>> 两阶段训练完成。教师 run: ${TEACHER_EXPTID}，学生 run: ${STUDENT_EXPTID}"
