import functions_framework
from flask import request, jsonify
import json
import os
from vertexai.generative_models import GenerativeModel
import vertexai

# 環境変数の設定
PROJECT_ID = os.environ.get("PROJECT_ID", "xxxxxx")
LOCATION = os.environ.get("LOCATION", "asia-northeast1")

# Vertex AIの初期化
vertexai.init(project=PROJECT_ID, location=LOCATION)


@functions_framework.http
def health_check(request):
    """ヘルスチェックエンドポイント"""
    # CORSヘッダーを設定
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    # OPTIONSリクエストの場合（プリフライト）
    if request.method == "OPTIONS":
        return ("", 204, headers)

    return (jsonify({"status": "healthy"}), 200, headers)


@functions_framework.http
def estimate_price(request):
    """商品の価格を推測するエンドポイント"""
    # CORSヘッダーを設定
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    # OPTIONSリクエストの場合（プリフライト）
    if request.method == "OPTIONS":
        return ("", 204, headers)

    try:
        data = request.get_json()
        if not data:
            return (
                jsonify({"success": False, "error": "JSONデータが必要です"}),
                400,
                headers,
            )

        item_description = data.get("description", "")

        if not item_description:
            return (
                jsonify({"success": False, "error": "商品の説明が必要です"}),
                400,
                headers,
            )

        # Gemini モデルを初期化
        model = GenerativeModel("gemini-1.5-flash")

        # プロンプトを作成
        prompt = f"""
        以下の商品の価格を日本円で推測してください。
        一般的な市場価格を参考に、できるだけ正確な価格を提示してください。

        商品: {item_description}

        回答は以下のJSON形式で返してください：
        {{
            "estimated_price": 価格（数値のみ）
        }}
        """

        # Geminiで価格を推測
        response = model.generate_content(prompt)

        try:
            # JSONレスポンスをパース
            result = json.loads(response.text.strip())

            return (
                jsonify(
                    {
                        "success": True,
                        "estimated_price": result.get("estimated_price", 0),
                    }
                ),
                200,
                headers,
            )

        except json.JSONDecodeError:
            # JSONパースに失敗した場合、テキストから価格を抽出
            text_response = response.text

            # 簡単な価格抽出ロジック
            import re

            price_match = re.search(r"(\d+(?:,\d{3})*)", text_response)
            estimated_price = (
                int(price_match.group(1).replace(",", "")) if price_match else 1000
            )

            return (
                jsonify(
                    {
                        "success": True,
                        "estimated_price": estimated_price,
                    }
                ),
                200,
                headers,
            )

    except Exception as e:
        return (jsonify({"success": False, "error": str(e)}), 500, headers)
