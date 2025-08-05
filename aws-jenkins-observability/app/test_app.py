from fastapi.testclient import TestClient
from main import app, SessionLocal, ItemModel

client = TestClient(app)

def test_create_and_get_item():
    response = client.post("/items", json={"name": "Test Item", "description": "Test Desc"})
    assert response.status_code == 200
    item = response.json()
    assert "id" in item
    assert item["name"] == "Test Item" or item.get("item", {}).get("name") == "Test Item"

    item_id = item["id"] if "id" in item else item["item"]["id"]

    get_response = client.get(f"/items/{item_id}")
    assert get_response.status_code == 200
    assert get_response.json()["name"] == "Test Item"

def test_item_is_persisted_in_db():
    response = client.post("/items", json={"name": "DB Test", "description": "From test"})
    assert response.status_code == 200
    item_id = response.json().get("id") or response.json()["item"]["id"]

    db = SessionLocal()
    item = db.query(ItemModel).filter(ItemModel.id == item_id).first()
    db.close()

    assert item is not None
    assert item.name == "DB Test"
    assert item.description == "From test"

def test_delete_item():
    response = client.post("/items", json={"name": "To Delete", "description": "Gone soon"})
    assert response.status_code == 200
    item_id = response.json().get("id") or response.json()["item"]["id"]

    delete_response = client.delete(f"/items/{item_id}")
    assert delete_response.status_code == 200
    assert f"Item {item_id} deleted" in delete_response.json()["message"]

def test_item_is_removed_from_db():
    response = client.post("/items", json={"name": "To Be Deleted", "description": "Temporary"})
    item_id = response.json().get("id") or response.json()["item"]["id"]
    client.delete(f"/items/{item_id}")

    db = SessionLocal()
    item = db.query(ItemModel).filter(ItemModel.id == item_id).first()
    db.close()

    assert item is None
