import httpx

BASE_URL = "http://fastapi_app:8000"

def test_full_lifecycle():
    create_res = httpx.post(f"{BASE_URL}/items", json={
        "name": "E2E Item",
        "description": "End-to-end test"
    })
    assert create_res.status_code == 200
    item = create_res.json()
    item_id = item.get("id") or item["item"]["id"]

    get_res = httpx.get(f"{BASE_URL}/items/{item_id}")
    assert get_res.status_code == 200
    assert get_res.json()["name"] == "E2E Item"

    delete_res = httpx.delete(f"{BASE_URL}/items/{item_id}")
    assert delete_res.status_code == 200
    assert f"Item {item_id} deleted" in delete_res.json()["message"]

    get_again_res = httpx.get(f"{BASE_URL}/items/{item_id}")
    assert get_again_res.status_code == 404
