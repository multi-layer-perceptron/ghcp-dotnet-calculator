import os
import requests

OWNER = os.getenv("GH_OWNER")
REPO = os.getenv("GH_REPO")
TOKEN = os.getenv("GH_TOKEN")

HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Accept": "application/vnd.github+json"
}

def get_alerts():
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/dependabot/alerts"
    resp = requests.get(url, headers=HEADERS)
    data = resp.json()
    if isinstance(data, list):
        return data
    else:
        print("Unexpected response:", data)
        return []

def dismiss_alert(alert_id, reason="tolerable_risk"):
    url = f"https://api.github.com/repos/{OWNER}/{REPO}/dependabot/alerts/{alert_id}"
    data = {
        "state": "dismissed",
        "dismissed_reason": reason,
        "dismissed_comment": "Auto-triaged: accepted by policy"
    }
    requests.patch(url, headers=HEADERS, json=data)

for alert in get_alerts():
    print(f"Alert #{alert.get('number', 'N/A')}: {alert.get('security_advisory', {}).get('summary', 'No summary')} - Severity: {alert.get('security_advisory', {}).get('severity', 'Unknown')}")
    if isinstance(alert, dict) and alert.get('security_advisory', {}).get('severity') == "low":
        print(f"  -> Low severity alert found: #{alert.get('number', 'N/A')} - Auto-dismissing")
        dismiss_alert(alert["number"])