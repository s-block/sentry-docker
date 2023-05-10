import logging
from logging import Logger

from aiocache import Cache
import aiohttp
from fastapi import FastAPI, Request
import ujson

logger: Logger = logging.getLogger(__file__)

cache = Cache(Cache.MEMORY)


app = FastAPI()


@app.post("/slack/webhook/{token1}/{token2}/{token3}")
async def post_to_slack_webhook(token1: str, token2: str, token3: str, request: Request):
    """
    Receive Sentry webhook and send alert to Sentry
    https://docs.sentry.io/product/integrations/integration-platform/webhooks/

    :param token1:
    :param token2:
    :param token3:
    :param request:
    :return:
    """
    hook_resource = request.headers.get("Sentry-Hook-Resource")
    if hook_resource not in ["event_alert", "metric_alert"]:
        return {
            "status": "SKIPPED",
            "reason": "Event not alert."
        }
    sentry_payload = await request.json()
    headers = {
        "content-type": "application/json",
        "accept": "application/json",
    }
    alert = sentry_payload.get("data", {}).get("event")
    web_url = alert.get("web_url")
    cached = await cache.get(alert.get("title"))
    if not cached and web_url:
        web_url = web_url.replace("http://sentry-nginx", "http://localhost:8080")
        text = f""":warning: <{web_url}|{alert.get("title")}>"""
        if alert.get("tags"):
            for key, val in alert.get("tags"):
                text += f"\n*{key}*: {val}"
        slack_payload = {
            "text": sentry_payload.get("data", {}).get("event", {}).get("title"),
            "blocks": [
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": text
                    },
                }
            ]
        }
        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.post(
                    f"https://hooks.slack.com/services/{token1}/{token2}/{token3}",
                    data=ujson.dumps(slack_payload)) as response:
                await cache.set(alert.get("title"), True, ttl=60)
                return await response.text()
    else:
        print("-----------------SKIPPED-------------------", f"Cached: {cached}, URL: {web_url}")
