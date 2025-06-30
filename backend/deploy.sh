#!/bin/bash

# プロジェクトIDとリージョンを設定
PROJECT_ID="xxxxxx"
REGION="asia-northeast1"

echo "=== Cloud Run functions へのデプロイを開始します ==="

# Google Cloud プロジェクトを設定
gcloud config set project $PROJECT_ID

echo "=== health-check 関数をデプロイしています ==="
# ヘルスチェック関数をデプロイ
gcloud functions deploy health-check \
    --gen2 \
    --runtime python311 \
    --source . \
    --entry-point health_check \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --memory 512Mi \
    --timeout 60s \
    --max-instances 10 \
    --set-env-vars PROJECT_ID=$PROJECT_ID,LOCATION=$REGION

echo "=== estimate-price 関数をデプロイしています ==="
# 価格推測関数をデプロイ
gcloud functions deploy estimate-price \
    --gen2 \
    --runtime python311 \
    --source . \
    --entry-point estimate_price \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --memory 1Gi \
    --timeout 300s \
    --max-instances 10 \
    --set-env-vars PROJECT_ID=$PROJECT_ID,LOCATION=$REGION

echo "=== デプロイが完了しました ==="

# デプロイされたURLを取得
HEALTH_URL=$(gcloud functions describe health-check --region $REGION --gen2 --format="value(serviceConfig.uri)")
ESTIMATE_URL=$(gcloud functions describe estimate-price --region $REGION --gen2 --format="value(serviceConfig.uri)")

echo "Health Check URL: $HEALTH_URL"
echo "Estimate Price URL: $ESTIMATE_URL"

echo "=== フロントエンドの設定を更新してください ==="
echo "frontend/lib/config/config.dart の設定を以下のように変更してください:"
echo "healthCheckUrl: '$HEALTH_URL'"
echo "estimatePriceUrl: '$ESTIMATE_URL'"
