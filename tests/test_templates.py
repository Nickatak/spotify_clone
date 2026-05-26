from bs4 import BeautifulSoup


def test_index_renders_hello(client):
    response = client.get("/")
    soup = BeautifulSoup(response.data, "html.parser")
    assert "hello" in soup.get_text()
