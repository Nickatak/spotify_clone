import pytest
from sqlalchemy.exc import IntegrityError

from app import db, User


def test_create_user(client):
    user = User(username="alice", password_hash="hash-alice")
    db.session.add(user)
    db.session.commit()

    assert User.query.count() == 1
    assert User.query.first().username == "alice"


def test_username_must_be_unique(client):
    db.session.add(User(username="alice", password_hash="hash-1"))
    db.session.commit()

    db.session.add(User(username="alice", password_hash="hash-2"))
    with pytest.raises(IntegrityError):
        db.session.commit()
