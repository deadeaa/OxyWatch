"""
firebase_service.py
Wrapper Firebase Admin SDK: verifikasi token, Firestore, dan FCM.
"""

import os
import json
import datetime
from typing import Optional

import firebase_admin
from firebase_admin import credentials, auth, firestore, messaging

_app = None


def init_firebase():
    global _app
    if _app is not None:
        return _app
    cred_json = os.environ.get("FIREBASE_CREDENTIALS_JSON")
    if not cred_json:
        raise RuntimeError("FIREBASE_CREDENTIALS_JSON tidak ditemukan di environment variables.")
    cred_dict = json.loads(cred_json)
    cred = credentials.Certificate(cred_dict)
    _app = firebase_admin.initialize_app(cred)
    return _app


def get_db():
    init_firebase()
    return firestore.client()


def verify_id_token(id_token: str) -> Optional[dict]:
    init_firebase()
    try:
        return auth.verify_id_token(id_token)
    except Exception:
        return None


def save_sensor_reading(child_id: str, reading: dict, prediction: dict) -> str:
    db = get_db()
    doc_ref = db.collection("children").document(child_id).collection("history").document()
    payload = {**reading, **prediction, "timestamp": datetime.datetime.utcnow().isoformat()}
    doc_ref.set(payload)
    return doc_ref.id


def get_history(child_id: str, limit: int = 50) -> list:
    db = get_db()
    docs = (
        db.collection("children").document(child_id).collection("history")
        .order_by("timestamp", direction=firestore.Query.DESCENDING)
        .limit(limit).stream()
    )
    return [d.to_dict() for d in docs]


def save_recommendation(child_id: str, doctor_id: str, note: str) -> str:
    db = get_db()
    doc_ref = db.collection("recommendations").document(child_id).collection("notes").document()
    doc_ref.set({"doctor_id": doctor_id, "note": note, "timestamp": datetime.datetime.utcnow().isoformat()})
    return doc_ref.id


def send_fcm_alert(device_token: str, child_name: str, level: str, score: int) -> str:
    init_firebase()
    message = messaging.Message(
        notification=messaging.Notification(
            title=f"Peringatan: {child_name}",
            body=f"Status risiko: {level} (skor {score}). Segera periksa kondisi anak.",
        ),
        data={"level": level, "score": str(score)},
        token=device_token,
    )
    return messaging.send(message)